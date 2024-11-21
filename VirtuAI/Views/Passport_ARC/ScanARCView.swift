import SwiftUI
import VComponents
import SwiftKeychainWrapper

// API 엔드포인트 상수
private enum APIEndpoint {
    static let base = "http://43.203.237.202:18080/api/v1/identity"
    static let update = "\(base)/update"
}

// API 요청 데이터 모델
struct ARCIdentityData: Codable {
    var foreignRegistrationNumber: String
    var birthDate: String
    var gender: String
    var name: String
    var nationality: String
    var region: String
    var residenceStatus: String
    var visaType: String
    var permitDate: String
    var expirationDate: String
    var issueCity: String
    var reportDate: String
    var residence: String
}

struct ScanARCView: View {
    // State variables
    @State private var foreignRegistrationNumber: String = ""
    @State private var dateOfBirth: String = ""
    @State private var gender: String?
    @State private var name: String = ""
    @State private var country: String = ""
    @State private var region: String = "California"
    @State private var residenceStatus: String = "Permanent Resident"
    @State private var visaType: String = "D-8"
    @State private var permitDate: String = "20220115"
    @State private var expirationDate: String = "20320115"
    @State private var issueCity: String = "Los Angeles"
    @State private var reportDate: String = "20231012"
    @State private var residence: String = "1234 Elm St, Los Angeles, CA"
    
    @State private var residenceCategory1 = "A"
    @State private var residenceCategory2 = "1"
    
    // UI State
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @FocusState private var isFocused: Bool
    
    // Navigation State
    @State private var navigateToAFARCView = false
    @State private var navigateToPassportView = false
    @State private var showAlertInfo = false
    @State private var navigateToScanPreARCView = false
    @State private var showAlertARC = false
    @State private var navigateToScanPrePassView = false
    @State private var navigateToMyInfoView = false
    
    // App Storage
    @AppStorage("arcDataSaved") private var arcDataSaved: Bool = false {
        didSet {
            print("arcDataSaved changed to: \(arcDataSaved)")
        }
    }
    
    // Constants
    let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")
    let countries = [
        "South Korea", "Japan", "China", "India", "Thailand", "United States", "Canada", "Germany", "France", "United Kingdom",
        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria",
        "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Bhutan", "Bolivia",
        "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cabo Verde",
        "Cambodia", "Canada", "Chad", "Chile", "China", "Colombia", "Costa Rica", "Czechia (Czech Republic)", "Denmark",
        "Djibouti", "Dominica", "Dominican Republic", "Egypt", "France", "Germany", "Ghana", "India", "Indonesia", "Iran",
        "Ireland", "Italy", "Japan", "Kazakhstan", "Kyrgyzstan", "Laos", "Malaysia", "Mongolia", "Morocco", "Myanmar (Burma)",
        "Nepal", "Netherlands", "New Zealand", "Nigeria", "Pakistan", "Peru", "Philippines", "Poland", "Russia", "Saudi Arabia",
        "Singapore", "South Africa", "Spain", "Sri Lanka", "Sweden", "Switzerland", "Taiwan", "Thailand", "Turkey", "United Kingdom",
        "United States", "Uzbekistan", "Vietnam"
    ]
    let residenceCategories1 = (65...90).map { String(UnicodeScalar($0)!) }
    let residenceCategories2 = (1...9).map { String($0) }
    
    init(result: OCRARCResult? = nil) {
        print("\n🔄 Starting ScanARCView initialization...")
        
        if let result = result {
            print("\n📝 Initializing with OCR result:")
            // OCR 결과로 초기화하는 기존 코드 유지
            self._foreignRegistrationNumber = State(initialValue: result.data?.foreignRegistrationNumber ?? "")
            self._dateOfBirth = State(initialValue: result.data?.dateOfBirth ?? "")
            self._gender = State(initialValue: result.data?.gender)
            self._name = State(initialValue: result.data?.name ?? "")
            self._country = State(initialValue: result.data?.nationality ?? "")
            
            // Visa type parsing
            if let visaType = result.data?.visaType, visaType.count >= 3 {
                let firstPart = String(visaType.prefix(1))
                let secondPart = String(visaType.suffix(1))
                self._residenceCategory1 = State(initialValue: firstPart)
                self._residenceCategory2 = State(initialValue: secondPart)
                self._visaType = State(initialValue: visaType)
            }
            
            print("✅ OCR data initialization completed")
            
        } else {
            print("\n📦 No OCR result, checking saved ARC data...")
            if let savedData = UserDefaults.standard.data(forKey: "SavedARCData") {
                do {
                    let arcData = try JSONDecoder().decode([String: String].self, from: savedData)
                    print("📦 Loading saved ARC Data:")
                    arcData.forEach { key, value in
                        print("  \(key): \(value)")
                    }
                    
                    // InputARCField 데이터 매핑
                    self._foreignRegistrationNumber = State(initialValue: arcData["foreignRegistrationNumber"] ?? "")
                    self._dateOfBirth = State(initialValue: arcData["birthDate"] ?? "")
                    self._name = State(initialValue: arcData["name"] ?? "")
                    
                    // RadioARCButton 데이터 매핑 (성별)
                    if let savedGender = arcData["gender"] {
                        self._gender = State(initialValue: savedGender)
                        print("  Setting gender to: \(savedGender)")
                    } else {
                        self._gender = State(initialValue: nil)
                        print("  No saved gender found")
                    }
                    
                    // DropdownARCField 데이터 매핑
                    self._country = State(initialValue: arcData["nationality"] ?? "")
                    self._region = State(initialValue: arcData["region"] ?? "California")
                    self._residenceStatus = State(initialValue: arcData["residenceStatus"] ?? "Permanent Resident")
                    
                    // Visa 관련 필드 매핑
                    if let visaType = arcData["visaType"] {
                        self._visaType = State(initialValue: visaType)
                        
                        // Visa 카테고리 파싱
                        if visaType.count >= 3 {
                            self._residenceCategory1 = State(initialValue: String(visaType.prefix(1)))
                            self._residenceCategory2 = State(initialValue: String(visaType.suffix(1)))
                            print("  Setting visa categories: \(String(visaType.prefix(1)))-\(String(visaType.suffix(1)))")
                        } else {
                            self._residenceCategory1 = State(initialValue: "A")
                            self._residenceCategory2 = State(initialValue: "1")
                            print("  Using default visa categories: A-1")
                        }
                    }
                    
                    // 나머지 필드 매핑
                    self._permitDate = State(initialValue: arcData["permitDate"] ?? "20220115")
                    self._expirationDate = State(initialValue: arcData["expirationDate"] ?? "20320115")
                    self._issueCity = State(initialValue: arcData["issueCity"] ?? "Los Angeles")
                    self._reportDate = State(initialValue: arcData["reportDate"] ?? "20231012")
                    self._residence = State(initialValue: arcData["residence"] ?? "1234 Elm St, Los Angeles, CA")
                    
                    print("✅ Successfully loaded and mapped saved ARC data to UI fields")
                    
                } catch {
                    print("❌ Error loading saved ARC data: \(error)")
                    initializeWithDefaults()
                }
            } else {
                print("ℹ️ No saved data found, initializing with defaults")
                initializeWithDefaults()
            }
        }
    }
    
    private mutating func initializeWithDefaults() {
        print("\n🔄 Initializing UI fields with default values")
        // InputARCField 기본값
        self._foreignRegistrationNumber = State(initialValue: "")
        self._dateOfBirth = State(initialValue: "")
        self._name = State(initialValue: "")
        
        // RadioARCButton 기본값
        self._gender = State(initialValue: nil)
        
        // DropdownARCField 기본값
        self._country = State(initialValue: "")
        self._region = State(initialValue: "California")
        self._residenceStatus = State(initialValue: "Permanent Resident")
        
        // Visa 관련 기본값
        self._visaType = State(initialValue: "D-8")
        self._residenceCategory1 = State(initialValue: "A")
        self._residenceCategory2 = State(initialValue: "1")
        
        // 나머지 필드 기본값
        self._permitDate = State(initialValue: "20220115")
        self._expirationDate = State(initialValue: "20320115")
        self._issueCity = State(initialValue: "Los Angeles")
        self._reportDate = State(initialValue: "20231012")
        self._residence = State(initialValue: "1234 Elm St, Los Angeles, CA")
        
        print("✅ Default initialization of UI fields completed")
    }
    
    // Logger function
    private func logStorageState() {
        // Check arcDataSaved flag
        let savedFlag = UserDefaults.standard.bool(forKey: "arcDataSaved")
        print("Current arcDataSaved flag: \(savedFlag)")
        
        // Check saved ARC data
        if let savedData = UserDefaults.standard.data(forKey: "SavedARCData") {
            do {
                let arcData = try JSONDecoder().decode([String: String].self, from: savedData)
                print("📦 Saved ARC Data Contents:")
                arcData.forEach { key, value in
                    print("  \(key): \(value)")
                }
            } catch {
                print("❌ Error decoding saved ARC data: \(error)")
            }
        } else {
            print("❌ No saved ARC data found")
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title Section
                    Text("Please check your ID information")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("If the recognized content is different from the real thing, it will be limited to use")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                    
                    // Form Fields
                    VStack(alignment: .leading) {
                        // ID Type Field
                        Text("Type of ID")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .opacity(0.7)
                        TextField("ARC", text: .constant("ARC"))
                            .disabled(true)
                            .padding()
                            .background(Color.gray.opacity(0.7))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                        
                        Spacer()
                        
                        // Required Fields
                        InputARCField(
                            title: "Foreign Registration Number",
                            text: $foreignRegistrationNumber,
                            showError: showError && foreignRegistrationNumber.isEmpty,
                            placeholder: "Z123456789",
                            isRequired: true
                        )
                        .onChange(of: foreignRegistrationNumber) { newValue in
                            formatForeignRegistrationNumber(newValue)
                        }
                        
                        Spacer()
                        
                        InputARCField(
                            title: "Date of Birth",
                            text: $dateOfBirth,
                            showError: showError && dateOfBirth.isEmpty,
                            placeholder: "19870201",
                            isRequired: true
                        )
                        
                        Spacer()
                        
                        // Gender Selection
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Gender")
                                    .font(.system(size: 16))
                                    .opacity(0.7)
                                Text("*").foregroundColor(.red)
                            }
                            HStack {
                                RadioARCButton(text: "Female", isSelected: $gender, tag: "Female", showError: showError && gender == nil)
                                RadioARCButton(text: "Male", isSelected: $gender, tag: "Male", showError: showError && gender == nil)
                            }
                        }
                        
                        Spacer()
                        
                        // Other Required Fields
                        InputARCField(
                            title: "Name",
                            text: $name,
                            showError: showError && name.isEmpty,
                            placeholder: "TANAKA",
                            isRequired: true
                        )
                        
                        Spacer()
                        
                        DropdownARCField(
                            title: "Country",
                            selectedValue: $country,
                            options: countries,
                            showError: showError && country.isEmpty,
                            isRequired: true
                        )
                        
                        Spacer()
                        
                        // Visa Category Selection
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Visa")
                                    .font(.system(size: 16))
                                    .opacity(0.7)
                                Text("*").foregroundColor(.red)
                            }
                            HStack {
                                DropdownARCField(
                                    title: "Category",
                                    selectedValue: $residenceCategory1,
                                    options: residenceCategories1
                                )
                                Text("-")
                                    .font(.system(size: 16))
                                    .opacity(0.7)
                                DropdownARCField(
                                    title: "Type",
                                    selectedValue: $residenceCategory2,
                                    options: residenceCategories2
                                )
                            }
                            .onChange(of: residenceCategory1) { _ in updateVisaType() }
                            .onChange(of: residenceCategory2) { _ in updateVisaType() }
                        }
                    }
                    
                    Spacer()
                    
                    // Action Buttons
                    HStack {
                        Button("Retry") {
                            navigateToScanPreARCView = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
                        
                        Button("Next") {
                            handleNextButton()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            // Navigation Links
            .navigationDestination(isPresented: $navigateToPassportView) {
                PassportInfoView()
            }
            .navigationDestination(isPresented: $navigateToScanPreARCView) {
                ScanPreARCView()
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden(false)
            .onAppear {
                print("📱 ScanARCView appeared")
                logStorageState()
                
                // 저장된 데이터 로드 및 필드에 적용
                if let savedData = UserDefaults.standard.data(forKey: "SavedARCData") {
                    do {
                        let arcData = try JSONDecoder().decode([String: String].self, from: savedData)
                        print("📦 Loading saved data into fields:")
                        
                        // InputARCField 값 설정
                        foreignRegistrationNumber = arcData["foreignRegistrationNumber"] ?? ""
                        dateOfBirth = arcData["birthDate"] ?? ""
                        name = arcData["name"] ?? ""
                        
                        // RadioARCButton 값 설정
                        gender = arcData["gender"]
                        
                        // DropdownARCField 값 설정
                        country = arcData["nationality"] ?? ""
                        region = arcData["region"] ?? "California"
                        residenceStatus = arcData["residenceStatus"] ?? "Permanent Resident"
                        
                        // Visa 관련 값 설정
                        if let visaType = arcData["visaType"] {
                            if visaType.count >= 3 {
                                residenceCategory1 = String(visaType.prefix(1))
                                residenceCategory2 = String(visaType.suffix(1))
                            }
                        }
                        
                        // 기타 필드 값 설정
                        permitDate = arcData["permitDate"] ?? "20220115"
                        expirationDate = arcData["expirationDate"] ?? "20320115"
                        issueCity = arcData["issueCity"] ?? "Los Angeles"
                        reportDate = arcData["reportDate"] ?? "20231012"
                        residence = arcData["residence"] ?? "1234 Elm St, Los Angeles, CA"
                        
                        arcData.forEach { key, value in
                            print("  \(key): \(value)")
                        }
                        print("✅ Fields populated with saved data")
                    } catch {
                        print("❌ Error loading saved data: \(error)")
                    }
                }
                
                fetchData()
            }
        }
    }
    
    private func formatForeignRegistrationNumber(_ newValue: String) {
        if newValue.count == 6 && !newValue.contains("-") {
            foreignRegistrationNumber.insert("-", at: newValue.index(newValue.startIndex, offsetBy: 6))
        }
        if newValue.count > 14 {
            foreignRegistrationNumber = String(newValue.prefix(14))
        }
    }
    
    private func updateVisaType() {
        visaType = "\(residenceCategory1)-\(residenceCategory2)"
    }
    
    private func createARCIdentity() {
        guard let accessToken = accessToken else {
            print("❌ Access token not available")
            errorMessage = "Access token not available"
            showError = true
            return
        }
        
        let identityData = ARCIdentityData(
            foreignRegistrationNumber: foreignRegistrationNumber,
            birthDate: dateOfBirth,
            gender: gender ?? "",
            name: name,
            nationality: country,
            region: region,
            residenceStatus: residenceStatus,
            visaType: visaType,
            permitDate: permitDate,
            expirationDate: expirationDate,
            issueCity: issueCity,
            reportDate: reportDate,
            residence: residence
        )
        
        print("📤 Creating ARC identity with data:")
        print(identityData)
        
        performAPIRequest(endpoint: APIEndpoint.base, method: "POST", data: identityData) { success in
            print(success ? "✅ ARC identity created successfully" : "❌ Failed to create ARC identity")
            if success {
                fetchData()
            }
        }
    }
    
    private func updateARCIdentity() {
        guard let accessToken = accessToken else {
            print("❌ Access token not available")
            errorMessage = "Access token not available"
            showError = true
            return
        }
        
        let identityData = ARCIdentityData(
            foreignRegistrationNumber: foreignRegistrationNumber,
            birthDate: dateOfBirth,
            gender: gender ?? "",
            name: name,
            nationality: country,
            region: region,
            residenceStatus: residenceStatus,
            visaType: visaType,
            permitDate: permitDate,
            expirationDate: expirationDate,
            issueCity: issueCity,
            reportDate: reportDate,
            residence: residence
        )
        
        print("📤 Updating ARC identity with data:")
        print(identityData)
        
        performAPIRequest(endpoint: APIEndpoint.update, method: "POST", data: identityData) { success in
            print(success ? "✅ ARC identity updated successfully" : "❌ Failed to update ARC identity")
            if success {
                fetchData()
            }
        }
    }
    
    // fetchData 함수 수정
    private func fetchData() {
        guard let url = URL(string: APIEndpoint.base),
              let token = accessToken else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("📥 Fetching ARC data...")
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("❌ Error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Invalid response")
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(ARCIdentityData.self, from: data)
                    print("✅ Data fetched successfully:")
                    print(decodedData)
                    
                    // UI 업데이트
                    self.foreignRegistrationNumber = decodedData.foreignRegistrationNumber
                    self.dateOfBirth = decodedData.birthDate
                    self.gender = decodedData.gender
                    self.name = decodedData.name
                    self.country = decodedData.nationality
                    self.region = decodedData.region
                    self.residenceStatus = decodedData.residenceStatus
                    
                    // Visa 타입 파싱 및 설정
                    if decodedData.visaType.count >= 3 {
                        self.residenceCategory1 = String(decodedData.visaType.prefix(1))
                        self.residenceCategory2 = String(decodedData.visaType.suffix(1))
                    }
                    self.visaType = decodedData.visaType
                    
                    self.permitDate = decodedData.permitDate
                    self.expirationDate = decodedData.expirationDate
                    self.issueCity = decodedData.issueCity
                    self.reportDate = decodedData.reportDate
                    self.residence = decodedData.residence
                    
                    // 데이터 저장
                    self.saveARCData()
                    
                    print("✅ View updated with fetched data")
                } catch {
                    print("❌ Decoding error: \(error)")
                }
            }
        }.resume()
    }
    private func performAPIRequest<T: Encodable>(endpoint: String, method: String, data: T, completion: @escaping (Bool) -> Void) {
            guard let url = URL(string: endpoint),
                  let token = accessToken else {
                completion(false)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONEncoder().encode(data)
                print("📤 API Request to \(endpoint)")
                print("Request data:")
                print(data)
            } catch {
                print("❌ Encoding error: \(error)")
                completion(false)
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("❌ Network error: \(error)")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Invalid response")
                    DispatchQueue.main.async {
                        completion(false)
                    }
                    return
                }
                
                print("✅ API request successful")
                DispatchQueue.main.async {
                    completion(true)
                }
            }.resume()
        }
        
    private func handleNextButton() {
        print("\n🔄 Handle Next Button pressed")
        print("Current arcDataSaved state: \(arcDataSaved)")
        
        if validateFields() {
            print("✅ Fields validation passed")
            
            if UserDefaults.standard.data(forKey: "SavedARCData") != nil {
                print("📤 Updating existing ARC data...")
                updateARCIdentity()
            } else {
                print("📥 Creating new ARC data...")
                createARCIdentity()
            }
            
            print("📝 Saving ARC data and navigating to PassportView...")
            saveARCData()
            navigateToPassportView = true
        } else {
            print("❌ Fields validation failed")
            errorMessage = "Please fill in all required fields."
            showError = true
            
            // Log which fields are missing
            print("\nMissing required fields:")
            if foreignRegistrationNumber.isEmpty { print("- Foreign Registration Number") }
            if dateOfBirth.isEmpty { print("- Date of Birth") }
            if gender == nil { print("- Gender") }
            if name.isEmpty { print("- Name") }
            if country.isEmpty { print("- Country") }
            
            // Log current field values
            print("\nCurrent field values:")
            print("- Foreign Registration Number: \(foreignRegistrationNumber.isEmpty ? "Empty" : foreignRegistrationNumber)")
            print("- Date of Birth: \(dateOfBirth.isEmpty ? "Empty" : dateOfBirth)")
            print("- Gender: \(gender ?? "Not selected")")
            print("- Name: \(name.isEmpty ? "Empty" : name)")
            print("- Country: \(country.isEmpty ? "Empty" : country)")
        }
    }
        
        private func validateFields() -> Bool {
            let isValid = !foreignRegistrationNumber.isEmpty &&
            !dateOfBirth.isEmpty &&
            gender != nil &&
            !name.isEmpty &&
            !country.isEmpty
            
            print("🔍 Field validation result: \(isValid)")
            if !isValid {
                print("Missing fields:")
                if foreignRegistrationNumber.isEmpty { print("- Foreign Registration Number") }
                if dateOfBirth.isEmpty { print("- Date of Birth") }
                if gender == nil { print("- Gender") }
                if name.isEmpty { print("- Name") }
                if country.isEmpty { print("- Country") }
            }
            
            return isValid
        }
        
        private func saveARCData() {
            let arcData: [String: String] = [
                "foreignRegistrationNumber": foreignRegistrationNumber,
                "birthDate": dateOfBirth,
                "gender": gender ?? "",
                "name": name,
                "nationality": country,
                "region": region,
                "residenceStatus": residenceStatus,
                "visaType": visaType,
                "permitDate": permitDate,
                "expirationDate": expirationDate,
                "issueCity": issueCity,
                "reportDate": reportDate,
                "residence": residence
            ]
            
            print("🔄 Attempting to save ARC data...")
            print("Current data to save:")
            arcData.forEach { key, value in
                print("  \(key): \(value)")
            }
            
            do {
                let encodedData = try JSONEncoder().encode(arcData)
                UserDefaults.standard.set(encodedData, forKey: "SavedARCData")
                arcDataSaved = true
                print("✅ ARC data saved successfully")
                logStorageState() // Log the state after saving
            } catch {
                print("❌ Failed to encode ARC data: \(error.localizedDescription)")
            }
        }
        
        private func loadARCData() -> [String: String]? {
            print("🔄 Attempting to load ARC data...")
            guard let savedData = UserDefaults.standard.data(forKey: "SavedARCData") else {
                print("❌ No ARC data found in UserDefaults")
                return nil
            }
            
            do {
                let arcData = try JSONDecoder().decode([String: String].self, from: savedData)
                print("✅ ARC data loaded successfully")
                print("Loaded data contents:")
                arcData.forEach { key, value in
                    print("  \(key): \(value)")
                }
                return arcData
            } catch {
                print("❌ Failed to decode ARC data: \(error.localizedDescription)")
                return nil
            }
        }
        
        private func resetFields() {
            print("🔄 Resetting all fields")
            foreignRegistrationNumber = ""
            dateOfBirth = ""
            gender = nil
            name = ""
            country = ""
            region = "California"
            residenceStatus = "Permanent Resident"
            visaType = "D-8"
            permitDate = "20220115"
            expirationDate = "20320115"
            issueCity = "Los Angeles"
            reportDate = "20231012"
            residence = "1234 Elm St, Los Angeles, CA"
            residenceCategory1 = "A"
            residenceCategory2 = "1"
            showError = false
            print("✅ Fields reset completed")
        }
    }

    // Supporting Views
    struct InputARCField: View {
        var title: String
        @Binding var text: String
        var showError: Bool = false
        var placeholder: String = ""
        var isRequired: Bool = false
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.system(size: 16))
                        .opacity(0.7)
                    if isRequired { Text("*").foregroundColor(.red) }
                }
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                    }
                    TextField("", text: $text)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(showError && text.isEmpty ? Color.red : Color.gray, lineWidth: 1)
                        )
                }
            }
        }
    }

    struct DropdownARCField: View {
        var title: String
        @Binding var selectedValue: String
        var options: [String]
        var showError: Bool = false
        var isRequired: Bool = false
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.system(size: 16))
                        .opacity(0.7)
                    if isRequired { Text("*").foregroundColor(.red) }
                }
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selectedValue = option
                        }) {
                            Text(option)
                        }
                    }
                } label: {
                    HStack {
                        if selectedValue.isEmpty {
                            Text("Select \(title)")
                                .foregroundColor(.gray)
                        } else {
                            Text(selectedValue)
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).stroke(showError && selectedValue.isEmpty ? Color.red : Color.gray, lineWidth: 1))
                }
            }
        }
    }

    struct RadioARCButton: View {
        var text: String
        @Binding var isSelected: String?
        var tag: String
        var showError: Bool
        
        var body: some View {
            Button(action: {
                isSelected = tag
            }) {
                HStack {
                    Image(systemName: isSelected == tag ? "largecircle.fill.circle" : "circle")
                        .foregroundColor(showError && isSelected == nil ? .red : .blue)
                        .font(.system(size: 18))
                    
                    Text(text)
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                        .opacity(0.7)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    struct ScanARCView_Previews: PreviewProvider {
        static var previews: some View {
            ScanARCView()
        }
    }
