import SwiftUI
import VComponents
import SwiftKeychainWrapper

// API 엔드포인트 상수
private enum APIEndpoint {
    static let base = "http://43.203.237.202:18080/api/v1/passport"
    static let update = "\(base)/update"
}

// API 요청 데이터 모델
struct PassportDoneData: Codable {
   var documentNumber: String
   var surName: String
   var givenName: String
   var nationality: String
   var dateOfBirth: String
   var gender: String
   var dateOfExpiry: String
   var dateOfIssue: String
   var issueCountry: String
   
   // CodingKeys 추가
   enum CodingKeys: String, CodingKey {
       case documentNumber
       case surName
       case givenName
       case nationality
       case dateOfBirth
       case gender
       case dateOfExpiry
       case dateOfIssue
       case issueCountry
   }
   
   // 디코딩 이니셜라이저 추가
   init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
       
       // 각 필드를 디코딩하되, 값이 없으면 기본값 사용
       documentNumber = try container.decodeIfPresent(String.self, forKey: .documentNumber) ?? ""
       surName = try container.decodeIfPresent(String.self, forKey: .surName) ?? ""
       givenName = try container.decodeIfPresent(String.self, forKey: .givenName) ?? ""
       nationality = try container.decodeIfPresent(String.self, forKey: .nationality) ?? ""
       dateOfBirth = try container.decodeIfPresent(String.self, forKey: .dateOfBirth) ?? ""
       gender = try container.decodeIfPresent(String.self, forKey: .gender) ?? ""
       dateOfExpiry = try container.decodeIfPresent(String.self, forKey: .dateOfExpiry) ?? ""
       dateOfIssue = try container.decodeIfPresent(String.self, forKey: .dateOfIssue) ?? ""
       issueCountry = try container.decodeIfPresent(String.self, forKey: .issueCountry) ?? ""
   }
   
   // 일반 이니셜라이저 추가
   init(
       documentNumber: String,
       surName: String,
       givenName: String,
       nationality: String,
       dateOfBirth: String,
       gender: String,
       dateOfExpiry: String,
       dateOfIssue: String,
       issueCountry: String
   ) {
       self.documentNumber = documentNumber
       self.surName = surName
       self.givenName = givenName
       self.nationality = nationality
       self.dateOfBirth = dateOfBirth
       self.gender = gender
       self.dateOfExpiry = dateOfExpiry
       self.dateOfIssue = dateOfIssue
       self.issueCountry = issueCountry
   }
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
    @AppStorage("SavedpassportData") private var savedpassportData: Data?
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

    init(result: PassportResult? = nil) {
        print("\n🔄 Starting ScanPassView initialization...")
        print("Received result: \(String(describing: result))")
        
        if let result = result, let data = result.data, result.status == 200 {
            print("\n📝 Initializing with OCR result:")
            print("Surname: \(data.surName ?? "nil")")
            print("Given Name: \(data.givenName ?? "nil")")
            
            // OCR 결과로 텍스트 필드 초기화
            self._surname = State(initialValue: data.surName ?? "")
            self._givenName = State(initialValue: data.givenName ?? "")
            self._dateOfBirth = State(initialValue: data.dateOfBirth ?? "")
            self._gender = State(initialValue: data.gender)
            self._countryRegion = State(initialValue: data.issueCountry ?? "")
            self._passportNumber = State(initialValue: data.documentNumber ?? "")
            self._passportExpirationDate = State(initialValue: data.dateOfExpiry ?? "")
            self._passportNationality = State(initialValue: data.nationality ?? "")
            self._dateOfIssue = State(initialValue: data.dateOfIssue ?? "")
            
            // OCR 결과를 UserDefaults에 저장
            if let encoded = try? JSONEncoder().encode(result) {
                savedpassportData = encoded
                passportDataSaved = true
            }
            
            print("✅ OCR data initialization completed")
        } else if let savedData = savedpassportData,
                  let decodedResult = try? JSONDecoder().decode(PassportResult.self, from: savedData),
                  let savedPassportData = decodedResult.data {
            // 저장된 데이터 사용
            print("📦 Using saved passport data")
            
            self._surname = State(initialValue: savedPassportData.surName ?? "")
            self._givenName = State(initialValue: savedPassportData.givenName ?? "")
            self._dateOfBirth = State(initialValue: savedPassportData.dateOfBirth ?? "")
            self._gender = State(initialValue: savedPassportData.gender)
            self._countryRegion = State(initialValue: savedPassportData.issueCountry ?? "")
            self._passportNumber = State(initialValue: savedPassportData.documentNumber ?? "")
            self._passportExpirationDate = State(initialValue: savedPassportData.dateOfExpiry ?? "")
            self._passportNationality = State(initialValue: savedPassportData.nationality ?? "")
            self._dateOfIssue = State(initialValue: savedPassportData.dateOfIssue ?? "")
            
            print("✅ Successfully loaded saved passport data")
        }
    }

    var body: some View {
           NavigationStack {
               ScrollView {
                   VStack(alignment: .leading, spacing: 16) {
                       // MARK: - Title Section
                       Text("Please check your ID information")
                           .font(.system(size: 32, weight: .bold))
                       
                       Text("If the recognized content is different from the real thing, usage may be restricted.")
                           .font(.system(size: 18))
                           .foregroundColor(.gray)
                       
                       // MARK: - Form Fields
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
                           // Input fields with initial data loading
                                         Group {
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
                                           
                                         }
                                         
                                         // Gender Selection with initial data loading
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
                                       
                                         Group {
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
                                     }
                       
                       Spacer()
                       
                       // MARK: - Action Buttons
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
               // MARK: - Navigation
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
                   loadSavedPassData()
        
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
    private func loadFieldData(_ field: String, into binding: Binding<String>) {
           if let savedData = savedpassportData,
              let decodedResult = try? JSONDecoder().decode(PassportResult.self, from: savedData),
              let data = decodedResult.data {
               switch field {
               case "surName": binding.wrappedValue = data.surName ?? ""
               case "givenName": binding.wrappedValue = data.givenName ?? ""
               case "dateOfBirth": binding.wrappedValue = data.dateOfBirth ?? ""
               case "issueCountry": binding.wrappedValue = data.issueCountry ?? ""
               case "documentNumber": binding.wrappedValue = data.documentNumber ?? ""
               case "dateOfExpiry": binding.wrappedValue = data.dateOfExpiry ?? ""
               case "dateOfIssue": binding.wrappedValue = data.dateOfIssue ?? ""
               case "nationality": binding.wrappedValue = data.nationality ?? ""
               default: break
               }
           }
       }
       
       private func loadGenderData() {
           if let savedData = savedpassportData,
              let decodedResult = try? JSONDecoder().decode(PassportResult.self, from: savedData),
              let data = decodedResult.data {
               gender = data.gender
           }
       }
    private func loadSavedPassData() {
        // OCR에서 저장된 userId와 현재 로그인한 username 비교
          guard let savedUserId = KeychainWrapper.standard.string(forKey: "passuserId"),
                let currentUsername = KeychainWrapper.standard.string(forKey: "username"),
                savedUserId == currentUsername else {
              print("❌ 사용자 검증 실패")
              print("저장된 passuserId: \(KeychainWrapper.standard.string(forKey: "passuserId") ?? "없음")")
              print("현재 username: \(KeychainWrapper.standard.string(forKey: "username") ?? "없음")")
              setDefaultPlaceholders()
              return
          }

        if let savedData = savedpassportData,
           let decodedResult = try? JSONDecoder().decode(PassportResult.self, from: savedData),
           let data = decodedResult.data {
            // 데이터 로드
            surname = data.surName ?? ""
            givenName = data.givenName ?? ""
            dateOfBirth = data.dateOfBirth ?? ""
            gender = data.gender ?? ""
            countryRegion = data.issueCountry ?? ""
            passportNumber = data.documentNumber ?? ""
            passportExpirationDate = data.dateOfExpiry ?? ""
            passportNationality = data.nationality ?? ""
            dateOfIssue = data.dateOfIssue ?? ""
            
            print("✅ Successfully loaded saved passport data")
        } else {
            print("❌ No saved passport data found or decoding failed")
            setDefaultPlaceholders()
        }
    }

    private func setDefaultPlaceholders() {
       print("📝 Setting default placeholders")
       // 필수 필드는 빈 값으로 설정 (사용자가 입력하도록)
       surname = ""
       givenName = ""
       dateOfBirth = ""
       gender = ""
       countryRegion = ""
       passportNumber = ""
       passportExpirationDate = ""
       passportNationality = ""
       dateOfIssue = ""
    }
    // MARK: - API Methods
       private func createPassportData() {
           print("\n🔄 Starting createPassportData...")
           
           let passportData = PassportDoneData(
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
           
           performAPIRequest(endpoint: APIEndpoint.base, method: "POST", data: passportData) { success in
               print(success ? "✅ Passport created successfully" : "❌ Failed to create passport")
               if success {
                   print( "✅ Passport 생성 API 완료")
               }
           }
       }
       
       private func updatePassportData() {
           print("\n🔄 Starting updatePassportData...")
           
           let passportData = PassportDoneData(
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
           
           performAPIRequest(endpoint: APIEndpoint.update, method: "POST", data: passportData) { success in
               print(success ? "✅ Passport updated successfully" : "❌ Failed to update passport")
               if success {
                   
                   print( "✅ Passport  업데이트 API 완료")
                   
               }
           }
       }
       
       private func fetchData() {
           print("\n🔄 Starting fetchData...")
           
           guard let url = URL(string: APIEndpoint.base),
                 let accessToken = accessToken else {
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
                   print("❌ Network error: \(error.localizedDescription)")
                   self.setDefaultPlaceholders()
                   return
               }
               
               guard let httpResponse = response as? HTTPURLResponse,
                     (200...299).contains(httpResponse.statusCode) else {
                   print("❌ Invalid response status code")
                   self.setDefaultPlaceholders()
                   return
               }
               
               guard let data = data else {
                   print("❌ No data received")
                   self.setDefaultPlaceholders()
                   return
               }
               
               do {
                   let decodedData = try JSONDecoder().decode(PassportDoneData.self, from: data)
                   
                   DispatchQueue.main.async {
                       // Update UI with fetched data or empty string if nil/empty
                       self.surname = decodedData.surName.isEmpty ? "" : decodedData.surName
                       self.givenName = decodedData.givenName.isEmpty ? "" : decodedData.givenName
                       self.dateOfBirth = decodedData.dateOfBirth.isEmpty ? "" : decodedData.dateOfBirth
                       self.gender = decodedData.gender.isEmpty ? nil : decodedData.gender
                       self.countryRegion = decodedData.issueCountry.isEmpty ? "" : decodedData.issueCountry
                       self.passportNumber = decodedData.documentNumber.isEmpty ? "" : decodedData.documentNumber
                       self.passportExpirationDate = decodedData.dateOfExpiry.isEmpty ? "" : decodedData.dateOfExpiry
                       self.passportNationality = decodedData.nationality.isEmpty ? "" : decodedData.nationality
                       self.dateOfIssue = decodedData.dateOfIssue.isEmpty ? "" : decodedData.dateOfIssue
                       
                       self.savePassportData()
                       print("✅ UI updated with fetched data")
                   }
               } catch {
                   print("❌ Decoding error: \(error)")
                   self.setDefaultPassPlaceholders()
               }
           }.resume()
       }
       
       private func setDefaultPassPlaceholders() {
           DispatchQueue.main.async {
               // Required fields set to empty
               self.surname = ""
               self.givenName = ""
               self.dateOfBirth = ""
               self.gender = nil
               self.countryRegion = ""
               self.passportNumber = ""
               self.passportExpirationDate = ""
               self.passportNationality = ""
               
               // Optional fields
               self.middleName = ""
               self.dateOfIssue = ""
           }
       }

    // MARK: - Utility Functions
    private func performAPIRequest<T: Encodable>(endpoint: String, method: String, data: T, completion: @escaping (Bool) -> Void) {
        print("\n🔄 Performing API Request to: \(endpoint)")
        
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
                print("❌ Invalid response code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
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
                print("📤 Updating existing passport data...")
                updatePassportData()
            } else {
                print("📥 Creating new passport data...")
                createPassportData()
            }
            
            let passportData = PassportDoneData(
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
                 
                 // Save to UserDefaults
                 let result = PassportResult(
                     status: 200,
                     message: "Success",
                     data: PassportData(
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
                 )
                 
                 if let encoded = try? JSONEncoder().encode(result) {
                     savedpassportData = encoded
                     passportDataSaved = true
                 }
            navigateToMyInfoView = true
        } else {
 
            errorMessage = "Please fill in all required fields."
            showError = true
  
        }
    }
    
    private func validateFields() -> Bool {
        let isValid = !surname.isEmpty &&
        !givenName.isEmpty &&
        !dateOfBirth.isEmpty &&
        gender != nil &&
        !countryRegion.isEmpty &&
        !passportNumber.isEmpty &&
        !passportExpirationDate.isEmpty &&
        !passportNationality.isEmpty
        
        print("\n🔍 Validation Result: \(isValid ? "✅ Pass" : "❌ Fail")")
        return isValid
    }
    
    private func savePassportData() {
        print("\n🔄 Saving passport data...")
        
        let passportData: [String: String] = [
            "documentNumber": passportNumber,
            "surName": surname,
            "givenName": givenName,
            "nationality": passportNationality,
            "dateOfBirth": dateOfBirth,
            "gender": gender ?? "",
            "dateOfExpiry": passportExpirationDate,
            "dateOfIssue": dateOfIssue,
            "issueCountry": countryRegion,
            "middleName": middleName
        ]
        
        do {
            let encodedData = try JSONEncoder().encode(passportData)
            UserDefaults.standard.set(encodedData, forKey: "SavedpassportData")
            passportDataSaved = true
            print("✅ Passport data saved successfully")
        
        } catch {
            print("❌ Failed to save passport data: \(error)")
        }
    }
}

// MARK: - Supporting Views
struct InputPassField: View {
    var title: String
    @Binding var text: String
    var showError: Bool = false
    var placeholder: String = ""
    var isRequired: Bool = false
    @FocusState private var isFocused: Bool
    
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
                        .stroke(showError ? Color.red : (isFocused ? Color.blue : Color.gray), lineWidth: 1)
                )
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
                    }
                }
            } label: {
                HStack {
                    Text(selectedValue.isEmpty ? "Select \(title)" : selectedValue)
                        .font(.system(size: 16))
                        .foregroundColor(selectedValue.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(showError ? Color.red : Color.gray, lineWidth: 1)
                )
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

