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

    // CodingKeys 추가
    enum CodingKeys: String, CodingKey {
        case foreignRegistrationNumber
        case birthDate
        case gender
        case name
        case nationality
        case region
        case residenceStatus
        case visaType
        case permitDate
        case expirationDate
        case issueCity
        case reportDate
        case residence
    }

    // 디코딩 이니셜라이저 추가
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 각 필드를 디코딩하되, 값이 없으면 기본값 사용
        foreignRegistrationNumber = try container.decodeIfPresent(String.self, forKey: .foreignRegistrationNumber) ?? ""
        birthDate = try container.decodeIfPresent(String.self, forKey: .birthDate) ?? ""
        gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        nationality = try container.decodeIfPresent(String.self, forKey: .nationality) ?? ""
        region = try container.decodeIfPresent(String.self, forKey: .region) ?? ""
        residenceStatus = try container.decodeIfPresent(String.self, forKey: .residenceStatus) ?? ""
        visaType = try container.decodeIfPresent(String.self, forKey: .visaType) ?? ""
        permitDate = try container.decodeIfPresent(String.self, forKey: .permitDate) ?? ""
        expirationDate = try container.decodeIfPresent(String.self, forKey: .expirationDate) ?? ""
        issueCity = try container.decodeIfPresent(String.self, forKey: .issueCity) ?? ""
        reportDate = try container.decodeIfPresent(String.self, forKey: .reportDate) ?? ""
        residence = try container.decodeIfPresent(String.self, forKey: .residence) ?? ""
    }

    // 일반 이니셜라이저 추가
    init(
        foreignRegistrationNumber: String,
        birthDate: String,
        gender: String,
        name: String,
        nationality: String,
        region: String,
        residenceStatus: String,
        visaType: String,
        permitDate: String,
        expirationDate: String,
        issueCity: String,
        reportDate: String,
        residence: String
    ) {
        self.foreignRegistrationNumber = foreignRegistrationNumber
        self.birthDate = birthDate
        self.gender = gender
        self.name = name
        self.nationality = nationality
        self.region = region
        self.residenceStatus = residenceStatus
        self.visaType = visaType
        self.permitDate = permitDate
        self.expirationDate = expirationDate
        self.issueCity = issueCity
        self.reportDate = reportDate
        self.residence = residence
    }
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
    @AppStorage("SavedarcData") private var savedARCData: Data?
    // Constants
    let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")
    let userId = KeychainWrapper.standard.string(forKey: "username")
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
    
    init(result: ARCResult? = nil) {
        print("\n🔄 Starting ScanARCView initialization...")
        
        if let result = result, let data = result.data {
            print("\n📝 Initializing with OCR result:")
            // OCR 결과로 텍스트 필드 초기화
            self._foreignRegistrationNumber = State(initialValue: data.foreignRegistrationNumber ?? "")
            self._dateOfBirth = State(initialValue: data.dateOfBirth ?? "")
            self._gender = State(initialValue: data.gender)
            self._name = State(initialValue: data.name ?? "")
            self._country = State(initialValue: data.nationality ?? "")
            
            // Visa 타입 파싱 및 설정
            if let visaType = data.visaType, visaType.count >= 3 {
                self._residenceCategory1 = State(initialValue: String(visaType.prefix(1)))
                self._residenceCategory2 = State(initialValue: String(visaType.suffix(1)))
                self._visaType = State(initialValue: visaType)
            } else {
                // 기본값 설정
                self._residenceCategory1 = State(initialValue: "D")
                self._residenceCategory2 = State(initialValue: "2")
                self._visaType = State(initialValue: "D-2")
            }
            
            print("✅ OCR data initialization completed")
        } else {
            print("\n📦 Checking saved ARC data...")
            // Try to load saved data from UserDefaults
            if let savedData = savedARCData,
               let decodedResult = try? JSONDecoder().decode(ARCResult.self, from: savedData),
               let data = decodedResult.data {
                self._foreignRegistrationNumber = State(initialValue: data.foreignRegistrationNumber ?? "")
                self._dateOfBirth = State(initialValue: data.dateOfBirth ?? "")
                self._gender = State(initialValue: data.gender)
                self._name = State(initialValue: data.name ?? "")
                self._country = State(initialValue: data.nationality ?? "")
                
                if let visaType = data.visaType, visaType.count >= 3 {
                    self._residenceCategory1 = State(initialValue: String(visaType.prefix(1)))
                    self._residenceCategory2 = State(initialValue: String(visaType.suffix(1)))
                    self._visaType = State(initialValue: visaType)
                }
            }
            
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
                loadSavedData()
            }
            .overlay(Group {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .background(Color.black.opacity(0.2))
                }
            })
        }
    }
    private func loadSavedData() {
        
        // OCR에서 저장된 userId와 현재 로그인한 username 비교
          guard let savedUserId = KeychainWrapper.standard.string(forKey: "userId"),
                let currentUsername = KeychainWrapper.standard.string(forKey: "username"),
                savedUserId == currentUsername else {
              print("❌ 사용자 검증 실패")
              print("저장된 userId: \(KeychainWrapper.standard.string(forKey: "userId") ?? "없음")")
              print("현재 username: \(KeychainWrapper.standard.string(forKey: "username") ?? "없음")")
              setDefaultPlaceholders()
              return
          }
          
          print("✅ 사용자 검증 성공")

        if let savedData = savedARCData,
           let decodedResult = try? JSONDecoder().decode(ARCResult.self, from: savedData),
           let data = decodedResult.data {
            // 데이터 로드
            foreignRegistrationNumber = data.foreignRegistrationNumber ?? ""
            dateOfBirth = data.dateOfBirth ?? ""
            gender = data.gender
            name = data.name ?? ""
            country = data.nationality ?? ""
            
            if let visaType = data.visaType, visaType.count >= 3 {
                residenceCategory1 = String(visaType.prefix(1))
                residenceCategory2 = String(visaType.suffix(1))
                self.visaType = visaType
            }
            print("✅ 데이터 로드 완료")
             print("- 이름: \(name)")
             print("- 생년월일: \(dateOfBirth)")
             print("- 성별: \(gender ?? "없음")")
             
         } else {
             print("❌ 저장된 데이터 없음 또는 디코딩 실패")
             setDefaultPlaceholders()
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
                print( "✅ ARC identity 생성 API 완료")
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
                print( "✅ ARC identity 업데이트 API 완료")
            }
        }
    }
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
                    self.setDefaultPlaceholders() // 에러 시 기본값 설정
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Invalid response")
                    self.setDefaultPlaceholders() // 잘못된 응답 시 기본값 설정
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    self.setDefaultPlaceholders() // 데이터 없을 시 기본값 설정
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(ARCIdentityData.self, from: data)
                    print("✅ Data fetched successfully:")
                    print(decodedData)
                    
                    // 서버에서 받은 데이터로 UI 업데이트
                    // nil 또는 빈 문자열인 경우 빈 값으로 설정
                    self.foreignRegistrationNumber = decodedData.foreignRegistrationNumber.isEmpty ? "" : decodedData.foreignRegistrationNumber
                    self.dateOfBirth = decodedData.birthDate.isEmpty ? "" : decodedData.birthDate
                    self.gender = decodedData.gender.isEmpty ? nil : decodedData.gender
                    self.name = decodedData.name.isEmpty ? "" : decodedData.name
                    self.country = decodedData.nationality.isEmpty ? "" : decodedData.nationality
                    self.region = decodedData.region.isEmpty ? "" : decodedData.region
                    self.residenceStatus = decodedData.residenceStatus.isEmpty ? "" : decodedData.residenceStatus
                    
                    // Visa 타입 파싱 및 설정
                    if decodedData.visaType.count >= 3 {
                        self.residenceCategory1 = String(decodedData.visaType.prefix(1))
                        self.residenceCategory2 = String(decodedData.visaType.suffix(1))
                    } else {
                        // 기본값 설정
                        self.residenceCategory1 = "D"
                        self.residenceCategory2 = "8"
                    }
                    self.visaType = decodedData.visaType.isEmpty ? "D-8" : decodedData.visaType
                    
                    // 나머지 필드 설정
                    self.permitDate = decodedData.permitDate.isEmpty ? "20220115" : decodedData.permitDate
                    self.expirationDate = decodedData.expirationDate.isEmpty ? "20320115" : decodedData.expirationDate
                    self.issueCity = decodedData.issueCity.isEmpty ? "Los Angeles" : decodedData.issueCity
                    self.reportDate = decodedData.reportDate.isEmpty ? "20231012" : decodedData.reportDate
                    self.residence = decodedData.residence.isEmpty ? "1234 Elm St, Los Angeles, CA" : decodedData.residence
                    
                    // 데이터 저장
                    self.saveARCData()
                    
                    print("✅ View updated with fetched data")
                } catch {
                    print("❌ Decoding error: \(error)")
                    self.setDefaultPlaceholders() // 디코딩 에러 시 기본값 설정
                }
            }
        }.resume()
    }

    // 기본값 설정을 위한 헬퍼 함수
    private func setDefaultPlaceholders() {
        print("📝 Setting default placeholders")
        // 필수 필드는 빈 값으로 설정 (사용자가 입력하도록)
        foreignRegistrationNumber = ""  // placeholder: "Z123456789"
        dateOfBirth = ""              // placeholder: "19870201"
        gender = nil                   // placeholder: 선택 없음
        name = ""                      // placeholder: "TANAKA"
        country = ""                   // placeholder: 국가 선택
        
        // 나머지 필드는 기본값 설정
        region = "California"
        residenceStatus = "Permanent Resident"
        residenceCategory1 = "D"
        residenceCategory2 = "2"
        visaType = "D-2"
        permitDate = "20220115"
        expirationDate = "20320115"
        issueCity = "Los Angeles"
        reportDate = "20231012"
        residence = "1234 Elm St, Los Angeles, CA"
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
        if validateFields() {
            
            if UserDefaults.standard.data(forKey: "SavedPassportData") != nil {
                print("📤 Updating existing ARCIdentity data...")
                updateARCIdentity()
            } else {
                print("📥 Creating new ARCIdentity data...")
                createARCIdentity()
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
            
            // Save to UserDefaults
            let result = ARCResult(
                status: 200,
                message: "Success",
                data: ARCData(
                    foreignRegistrationNumber: foreignRegistrationNumber,
                    dateOfBirth: dateOfBirth,
                    gender: gender,
                    name: name,
                    nationality: country,
                    issueCountry: nil,
                    visaType: visaType,
                    permitDate: permitDate,
                    expirationDate: expirationDate,
                    residence: residence
                )
            )
            
            if let encoded = try? JSONEncoder().encode(result) {
                savedARCData = encoded
                arcDataSaved = true
            }
            
            navigateToPassportView = true
        } else {
            showError = true
            errorMessage = "Please fill in all required fields."
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
