import SwiftUI
import VComponents
import SwiftKeychainWrapper

// API 엔드포인트 상수
private enum APIEndpoint {
    static let base = "http://43.203.237.202:18080/api/v1/passport"
    static let update = "\(base)/update"
}

// API 요청 데이터 모델
struct PassportData: Codable {
    var documentNumber: String
    var surName: String
    var givenName: String
    var nationality: String
    var dateOfBirth: String
    var gender: String
    var dateOfExpiry: String
    var dateOfIssue: String
    var issueCountry: String
}

struct ScanPassView: View {
    // State variables
    @State private var surname: String = ""
    @State private var givenName: String = ""
    @State private var middleName: String = ""
    @State private var dateOfBirth: String = ""
    @State private var gender: String?
    @State private var countryRegion: String = ""
    @State private var passportNumber: String = ""
    @State private var passportExpirationDate: String = ""
    @State private var passportNationality: String = ""
    @State private var dateOfIssue: String = ""
    
    // UI State
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @FocusState private var isFocused: Bool
    
    // Navigation State
    @State private var navigateToMyInfoView = false
    @State private var showAlertInfo = false
    @State private var navigateToScanPrePassView = false
    
    // App Storage
    @AppStorage("passportDataSaved") private var passportDataSaved: Bool = false {
        didSet {
            print("passportDataSaved changed to: \(passportDataSaved)")
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

    init(result: OCRPassResult? = nil) {
        print("\n🔄 Starting ScanPassView initialization...")
        
        if let result = result {
            print("\n📝 Initializing with OCR Pass result:")
            self._surname = State(initialValue: result.data?.surName ?? "")
            self._givenName = State(initialValue: result.data?.givenName ?? "")
            self._middleName = State(initialValue: result.data?.middleName ?? "")
            self._dateOfBirth = State(initialValue: result.data?.dateOfBirth ?? "")
            self._gender = State(initialValue: result.data?.gender)
            self._countryRegion = State(initialValue: result.data?.issueCountry ?? "")
            self._passportNumber = State(initialValue: result.data?.documentNumber ?? "")
            self._passportExpirationDate = State(initialValue: result.data?.dateOfExpiry ?? "")
            self._passportNationality = State(initialValue: result.data?.nationality ?? "")
            
            print("\n🔄 Initialized with OCR result:")
            print("  Surname: \(result.data?.surName ?? "empty")")
            print("  Given Name: \(result.data?.givenName ?? "empty")")
            print("  Document Number: \(result.data?.documentNumber ?? "empty")")
        } else {
            print("\n📦 No OCR result, checking saved Passport data...")
            if let savedData = UserDefaults.standard.data(forKey: "SavedpassportData") {
                do {
                    let passportData = try JSONDecoder().decode([String: String].self, from: savedData)
                    print("📦 Loading saved Passport Data:")
                    passportData.forEach { key, value in
                        print("  \(key): \(value)")
                    }
                    
                    // InputPassField 데이터 매핑
                    self._surname = State(initialValue: passportData["surName"] ?? "")
                    self._givenName = State(initialValue: passportData["givenName"] ?? "")
                    self._middleName = State(initialValue: passportData["middleName"] ?? "")
                    self._dateOfBirth = State(initialValue: passportData["dateOfBirth"] ?? "")
                    self._passportNumber = State(initialValue: passportData["documentNumber"] ?? "")
                    self._passportExpirationDate = State(initialValue: passportData["dateOfExpiry"] ?? "")
                    self._dateOfIssue = State(initialValue: passportData["dateOfIssue"] ?? "")
                    
                    // RadioPassButton 데이터 매핑
                    if let savedGender = passportData["gender"] {
                        self._gender = State(initialValue: savedGender)
                        print("  Setting gender to: \(savedGender)")
                    } else {
                        self._gender = State(initialValue: nil)
                        print("  No saved gender found")
                    }
                    
                    // DropdownPassField 데이터 매핑
                    self._countryRegion = State(initialValue: passportData["issueCountry"] ?? "")
                    self._passportNationality = State(initialValue: passportData["nationality"] ?? "")
                    
                    print("✅ Successfully loaded and mapped saved Passport data to UI fields")
                } catch {
                    print("❌ Error loading saved Passport data: \(error)")
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
        self._surname = State(initialValue: "")
        self._givenName = State(initialValue: "")
        self._middleName = State(initialValue: "")
        self._dateOfBirth = State(initialValue: "")
        self._gender = State(initialValue: nil)
        self._countryRegion = State(initialValue: "")
        self._passportNumber = State(initialValue: "")
        self._passportExpirationDate = State(initialValue: "")
        self._passportNationality = State(initialValue: "")
        self._dateOfIssue = State(initialValue: "")
        print("✅ Default initialization of UI fields completed")
    }

    // Logger function
    private func logStorageState() {
        let savedFlag = UserDefaults.standard.bool(forKey: "passportDataSaved")
        print("Current passportDataSaved flag: \(savedFlag)")
        
        if let savedData = UserDefaults.standard.data(forKey: "SavedpassportData") {
            do {
                let passportData = try JSONDecoder().decode([String: String].self, from: savedData)
                print("📦 Saved Passport Data Contents:")
                passportData.forEach { key, value in
                    print("  \(key): \(value)")
                }
            } catch {
                print("❌ Error decoding saved passport data: \(error)")
            }
        } else {
            print("❌ No saved passport data found")
        }
    }
    var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Title Section
                        Text("Please check your ID information")
                            .font(.system(size: 32, weight: .bold))
                        
                        Text("If the recognized content is different from the real thing, usage may be restricted.")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                        
                        // Form Fields
                        VStack(alignment: .leading) {
                            // ID Type Field
                            Text("Type of ID")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .opacity(0.7)
                            TextField("Passport", text: .constant("Passport"))
                                .disabled(true)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            // Required Fields
                            InputPassField(
                                title: "Surname",
                                text: $surname,
                                showError: showError && surname.isEmpty,
                                placeholder: "SMITH",
                                isRequired: true
                            )
                            
                            Spacer()
                            
                            InputPassField(
                                title: "Given Name",
                                text: $givenName,
                                showError: showError && givenName.isEmpty,
                                placeholder: "JOHN",
                                isRequired: true
                            )
                            
                            Spacer()
                            
                            InputPassField(
                                title: "Middle Name",
                                text: $middleName,
                                placeholder: "ROBERT"
                            )
                            
                            Spacer()
                            
                            InputPassField(
                                title: "Date of Birth",
                                text: $dateOfBirth,
                                showError: showError && dateOfBirth.isEmpty,
                                placeholder: "19820201",
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
                                    RadioPassButton(text: "Female", isSelected: $gender, tag: "F", showError: showError && gender == nil)
                                    RadioPassButton(text: "Male", isSelected: $gender, tag: "M", showError: showError && gender == nil)
                                }
                            }
                            
                            Spacer()
                            
                            // Other Required Fields
                            DropdownPassField(
                                title: "Country / Region",
                                selectedValue: $countryRegion,
                                options: countries,
                                showError: showError && countryRegion.isEmpty,
                                isRequired: true
                            )
                            
                            Spacer()
                            
                            InputPassField(
                                title: "Passport Number",
                                text: $passportNumber,
                                showError: showError && passportNumber.isEmpty,
                                placeholder: "M12345678",
                                isRequired: true
                            )
                            
                            Spacer()
                            
                            InputPassField(
                                title: "Passport Expiration Date",
                                text: $passportExpirationDate,
                                showError: showError && passportExpirationDate.isEmpty,
                                placeholder: "20301231",
                                isRequired: true
                            )
                            
                            Spacer()
                            
                            InputPassField(
                                title: "Date of Issue",
                                text: $dateOfIssue,
                                showError: false,
                                placeholder: "20201231"
                            )
                            
                            Spacer()
                            
                            DropdownPassField(
                                title: "Nationality",
                                selectedValue: $passportNationality,
                                options: countries,
                                showError: showError && passportNationality.isEmpty,
                                isRequired: true
                            )
                        }
                        
                        Spacer()
                        
                        // Action Buttons
                        HStack {
                            Button("Retry") {
                                navigateToScanPrePassView = true
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
                .navigationDestination(isPresented: $navigateToMyInfoView) {
                    MyInfoView()
                }
                .navigationDestination(isPresented: $navigateToScanPrePassView) {
                    ScanPrePassView()
                }
                .navigationTitle("")
                .navigationBarBackButtonHidden(false)
                .onAppear {
                    print("📱 ScanPassView appeared")
                    logStorageState()
                    
                    // 저장된 데이터 로드 및 필드에 적용
                    if let savedData = UserDefaults.standard.data(forKey: "SavedpassportData") {
                        do {
                            let passportData = try JSONDecoder().decode([String: String].self, from: savedData)
                            print("📦 Loading saved data into fields:")
                            
                            // InputPassField 값 설정
                            surname = passportData["surName"] ?? ""
                            givenName = passportData["givenName"] ?? ""
                            middleName = passportData["middleName"] ?? ""
                            dateOfBirth = passportData["dateOfBirth"] ?? ""
                            passportNumber = passportData["documentNumber"] ?? ""
                            passportExpirationDate = passportData["dateOfExpiry"] ?? ""
                            dateOfIssue = passportData["dateOfIssue"] ?? ""
                            
                            // RadioPassButton 값 설정
                            gender = passportData["gender"]
                            
                            // DropdownPassField 값 설정
                            countryRegion = passportData["issueCountry"] ?? ""
                            passportNationality = passportData["nationality"] ?? ""
                            
                            passportData.forEach { key, value in
                                print("  \(key): \(value)")
                            }
                            print("✅ Fields populated with saved data")
                        } catch {
                            print("❌ Error loading saved data: \(error)")
                        }
                    }
                    
                    fetchData()
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
        print("\n🔄 Loading saved data...")
        if let savedData = UserDefaults.standard.data(forKey: "SavedpassportData") {
            do {
                let passportData = try JSONDecoder().decode([String: String].self, from: savedData)
                print("📦 Found saved data:")
                
                DispatchQueue.main.async {
                    // InputPassField 값 업데이트
                    self.surname = passportData["surName"] ?? ""
                    self.givenName = passportData["givenName"] ?? ""
                    self.middleName = passportData["middleName"] ?? ""
                    self.dateOfBirth = passportData["dateOfBirth"] ?? ""
                    self.passportNumber = passportData["documentNumber"] ?? ""
                    self.passportExpirationDate = passportData["dateOfExpiry"] ?? ""
                    self.dateOfIssue = passportData["dateOfIssue"] ?? ""
                    
                    // RadioPassButton 값 업데이트
                    self.gender = passportData["gender"]
                    
                    // DropdownPassField 값 업데이트
                    self.countryRegion = passportData["issueCountry"] ?? ""
                    self.passportNationality = passportData["nationality"] ?? ""
                    
                    print("✅ Fields updated with saved data:")
                    print("  Surname: \(self.surname)")
                    print("  Given Name: \(self.givenName)")
                    print("  Date of Birth: \(self.dateOfBirth)")
                    print("  Gender: \(self.gender ?? "not set")")
                    print("  Country: \(self.countryRegion)")
                    print("  Passport Number: \(self.passportNumber)")
                }
            } catch {
                print("❌ Error loading saved data: \(error)")
            }
        } else {
            print("ℹ️ No saved data found")
        }
    }
        // API Methods
        private func createPassportData() {
            print("\n🔄 Starting createPassportData...")
            
            let passportData = PassportData(
                documentNumber: passportNumber,
                surName: surname,
                givenName: givenName,
                nationality: passportNationality,
                dateOfBirth: dateOfBirth,
                gender: gender ?? "",
                dateOfExpiry: passportExpirationDate,
                dateOfIssue: dateOfIssue,
                issueCountry: countryRegion
            )
            
            print("\n📤 Creating passport with data:")
            print("  Document Number: \(passportData.documentNumber)")
            print("  Name: \(passportData.surName) \(passportData.givenName)")
            print("  Nationality: \(passportData.nationality)")
            print("  Birth Date: \(passportData.dateOfBirth)")
            print("  Gender: \(passportData.gender)")
            
            performAPIRequest(endpoint: APIEndpoint.base, method: "POST", data: passportData) { success in
                print(success ? "✅ Passport created successfully" : "❌ Failed to create passport")
                if success {
                    DispatchQueue.main.async {
                        self.savePassportData()
                        self.fetchData()
                        self.navigateToMyInfoView = true
                    }
                }
            }
        }
        
        private func updatePassportData() {
            print("\n🔄 Starting updatePassportData...")
            
            let passportData = PassportData(
                documentNumber: passportNumber,
                surName: surname,
                givenName: givenName,
                nationality: passportNationality,
                dateOfBirth: dateOfBirth,
                gender: gender ?? "",
                dateOfExpiry: passportExpirationDate,
                dateOfIssue: dateOfIssue,
                issueCountry: countryRegion
            )
            
            print("\n📤 Updating passport with data:")
            print("  Document Number: \(passportData.documentNumber)")
            print("  Name: \(passportData.surName) \(passportData.givenName)")
            print("  Nationality: \(passportData.nationality)")
            print("  Birth Date: \(passportData.dateOfBirth)")
            print("  Gender: \(passportData.gender)")
            
            performAPIRequest(endpoint: APIEndpoint.update, method: "POST", data: passportData) { success in
                print(success ? "✅ Passport updated successfully" : "❌ Failed to update passport")
                if success {
                    DispatchQueue.main.async {
                        self.savePassportData()
                        self.fetchData()
                        self.navigateToMyInfoView = true
                    }
                }
            }
        }
        
        private func fetchData() {
            print("\n🔄 Starting fetchData...")
            
            guard let url = URL(string: APIEndpoint.base),
                  let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") else {
                print("❌ Missing URL or access token")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            print("📥 Fetching passport data...")
            isLoading = true
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                
                if let error = error {
                    print("❌ Error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("❌ Invalid response status code")
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(PassportData.self, from: data)
                    print("✅ Data fetched successfully:")
                    print("  Document Number: \(decodedData.documentNumber)")
                    print("  Name: \(decodedData.surName) \(decodedData.givenName)")
                    print("  Nationality: \(decodedData.nationality)")
                    
                    DispatchQueue.main.async {
                        // UI 업데이트
                        self.surname = decodedData.surName
                        self.givenName = decodedData.givenName
                        self.dateOfBirth = decodedData.dateOfBirth
                        self.gender = decodedData.gender
                        self.countryRegion = decodedData.issueCountry
                        self.passportNumber = decodedData.documentNumber
                        self.passportExpirationDate = decodedData.dateOfExpiry
                        self.passportNationality = decodedData.nationality
                        self.dateOfIssue = decodedData.dateOfIssue
                        
                        // 데이터 저장
                        self.savePassportData()
                        print("✅ UI updated with fetched data")
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                }
            }.resume()
        }
        
        private func performAPIRequest<T: Encodable>(endpoint: String, method: String, data: T, completion: @escaping (Bool) -> Void) {
            print("\n🔄 Performing API Request to: \(endpoint)")
            print("Method: \(method)")
            
            guard let url = URL(string: endpoint),
                  let accessToken = accessToken else {
                print("❌ Missing URL or access token")
                completion(false)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONEncoder().encode(data)
                print("📤 Request payload encoded successfully")
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
                    print("❌ Invalid response status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
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
            print("Current passportDataSaved state: \(passportDataSaved)")
            
            // Log current field values
            print("\n📝 Current Field Values:")
            print("  Surname: \(surname)")
            print("  Given Name: \(givenName)")
            print("  Middle Name: \(middleName)")
            print("  Date of Birth: \(dateOfBirth)")
            print("  Gender: \(gender ?? "not set")")
            print("  Country/Region: \(countryRegion)")
            print("  Passport Number: \(passportNumber)")
            print("  Passport Expiration Date: \(passportExpirationDate)")
            print("  Passport Nationality: \(passportNationality)")
            print("  Date of Issue: \(dateOfIssue)")
            
            if validateFields() {
                print("✅ Fields validation passed")
                
                if UserDefaults.standard.data(forKey: "SavedpassportData") != nil {
                    print("📤 Updating existing passport data...")
                    updatePassportData()
                } else {
                    print("📥 Creating new passport data...")
                                    createPassportData()
                                }
                                
                                print("📝 Saving Passport data and navigating to MyInfoView...")
                                savePassportData()
                                navigateToMyInfoView = true
                            } else {
                                print("❌ Fields validation failed")
                                errorMessage = "Please fill in all required fields."
                                showError = true
                                
                                // Log which fields are missing
                                print("Missing required fields:")
                                if surname.isEmpty { print("- Surname") }
                                if givenName.isEmpty { print("- Given Name") }
                                if dateOfBirth.isEmpty { print("- Date of Birth") }
                                if gender == nil { print("- Gender") }
                                if countryRegion.isEmpty { print("- Country/Region") }
                                if passportNumber.isEmpty { print("- Passport Number") }
                                if passportExpirationDate.isEmpty { print("- Passport Expiration Date") }
                            }
                        }
                        
                        private func validateFields() -> Bool {
                            let isValid = !surname.isEmpty &&
                            !givenName.isEmpty &&
                            !dateOfBirth.isEmpty &&
                            gender != nil &&
                            !countryRegion.isEmpty &&
                            !passportNumber.isEmpty &&
                            !passportExpirationDate.isEmpty
                            
                            print("\n🔍 Field Validation:")
                            print("Surname: \(!surname.isEmpty ? "✅" : "❌")")
                            print("Given Name: \(!givenName.isEmpty ? "✅" : "❌")")
                            print("Date of Birth: \(!dateOfBirth.isEmpty ? "✅" : "❌")")
                            print("Gender: \(gender != nil ? "✅" : "❌")")
                            print("Country/Region: \(!countryRegion.isEmpty ? "✅" : "❌")")
                            print("Passport Number: \(!passportNumber.isEmpty ? "✅" : "❌")")
                            print("Expiration Date: \(!passportExpirationDate.isEmpty ? "✅" : "❌")")
                            print("Overall validation result: \(isValid ? "✅" : "❌")")
                            
                            return isValid
                        }
                        
                        private func savePassportData() {
                            print("\n🔄 Starting savePassportData...")
                            
                            let passportData: [String: String] = [
                                "documentNumber": passportNumber,
                                "surName": surname,
                                "givenName": givenName,
                                "nationality": passportNationality,
                                "dateOfBirth": dateOfBirth,
                                "gender": gender ?? "",
                                "dateOfExpiry": passportExpirationDate,
                                "dateOfIssue": dateOfIssue,
                                "issueCountry": countryRegion
                            ]
                            
                            print("\n📝 Saving passport data:")
                            passportData.forEach { key, value in
                                print("  \(key): \(value)")
                            }
                            
                            do {
                                let encodedData = try JSONEncoder().encode(passportData)
                                UserDefaults.standard.set(encodedData, forKey: "SavedpassportData")
                                passportDataSaved = true
                                
                                // 저장 후 즉시 필드 업데이트
                                DispatchQueue.main.async {
                                    self.loadSavedData()
                                }
                                
                                print("✅ Passport data saved successfully")
                                logStorageState()
                            } catch {
                                print("❌ Failed to encode passport data: \(error)")
                            }
                        }
                        
                        // MARK: - Supporting Views
                        struct InputPassField: View {
                            var title: String
                            @Binding var text: String
                            var showError: Bool = false
                            var placeholder: String = ""
                            var isRequired: Bool = false
                            @FocusState var isFocused: Bool
                            
                            var body: some View {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(title)
                                            .font(.system(size: 16))
                                            .opacity(0.7)
                                        if isRequired { Text("*").foregroundColor(.red) }
                                    }
                                    TextField(placeholder, text: $text)
                                        .font(.system(size: 16))
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .focused($isFocused)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(isFocused || !text.isEmpty ? Color.blue : Color.gray, lineWidth: 1)
                                        )
                                        .foregroundColor(text.isEmpty ? Color.gray : Color.black)
                                }
                            }
                        }
                        
                        struct RadioPassButton: View {
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
                                            .foregroundColor(showError ? .red : .blue)
                                        Text(text)
                                            .font(.system(size: 16))
                                            .opacity(0.7)
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                        }
                        
                        struct DropdownPassField: View {
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
                                                    .font(.system(size: 16))
                                                    .opacity(0.7)
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedValue.isEmpty ? "Select" : selectedValue)
                                                .font(.system(size: 16))
                                                .opacity(0.7)
                                                .foregroundColor(selectedValue.isEmpty ? .gray : .black)
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                        }
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 16).stroke(showError ? Color.red : Color.gray, lineWidth: 1))
                                    }
                                }
                            }
                        }
                    }

                    // MARK: - Preview Provider
                    struct ScanPassView_Previews: PreviewProvider {
                        static var previews: some View {
                            ScanPassView()
                        }
                    }
