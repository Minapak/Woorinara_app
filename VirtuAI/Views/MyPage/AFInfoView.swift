import SwiftUI
import SwiftKeychainWrapper


struct AFInfoView: View {
    // AppStorage
    @AppStorage("SavedarcData") private var savedARCData: Data?
    @AppStorage("SavedpassportData") private var savedPassportData: Data?
    @AppStorage("SavedmyInfoData") private var savedMyInfoData: Data?
    
    // State for user verification
    @State private var currentUsername: String = KeychainWrapper.standard.string(forKey: "username") ?? ""
    
    // Navigation State
    @State private var navigateToAFAutoView = false
    @Environment(\.presentationMode) var presentationMode
    
    // Form Fields States
    @State private var formData = FormData()
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccessAlert = false
    @State private var profileImageUrl: String? = nil
    @State private var signatureUrl: String? = nil
    // API Endpoints
    private static let baseARC = "http://43.203.237.202:18080/api/v1/idcard/update"
    private static let basePass = "http://43.203.237.202:18080/api/v1/passport/update"
    private static let baseMyInfo = "http://43.203.237.202:18080/api/v1/members/details/update"
    private let endpoint = "http://43.203.237.202:18080/api/v1/members/applicationForm"
    
    // Form Data Structure
    struct FormData {
        // Identity Data
        var foreignRegistrationNumber: String = ""
        var surname: String = ""
        var givenName: String = ""
        var dateOfBirth: String = ""
        var gender: String = ""
        var nationality: String = ""
        
        // Passport Data
        var passportNumber: String = ""
        var passportIssueDate: String = ""
        var passportExpiryDate: String = ""
        
        // Member Details
        var phoneNumber: String = ""
        var koreaAddress: String = ""
        var telephoneNumber: String = ""
        var homelandAddress: String = ""
        var homelandPhoneNumber: String = ""
        var schoolStatus: String = ""
        var schoolName: String = ""
        var schoolPhoneNumber: String = ""
        var schoolType: String = ""
        var originalWorkplaceName: String = ""
        var originalWorkplaceRegistrationNumber: String = ""
        var originalWorkplacePhoneNumber: String = ""
        var futureWorkplaceName: String = ""
        var futureWorkplacePhoneNumber: String = ""
        var futureWorkplaceRegistrationNumber: String = ""
        var incomeAmount: String = ""
        var job: String = ""
        var refundAccountNumber: String = ""
    }
    var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Application Form Information")
                            .font(.system(size: 32, weight: .bold))
                            .padding(.bottom, 20)
                        
                        // Identity Information Section
                        Group {
                        
                            
                            SectionAFInfoView(
                                title: "Foreign Registration Number",
                                text: $formData.foreignRegistrationNumber,
                                placeholder: "Enter registration number",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Surname",
                                text: $formData.surname,
                                placeholder: "Enter surname",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Given Name",
                                text: $formData.givenName,
                                placeholder: "Enter given name",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Date of Birth",
                                text: $formData.dateOfBirth,
                                placeholder: "YYYYMMDD",
                                isRequired: true
                            )
                            DropdownAFInfoField(
                                title: "Gender",
                                selectedValue: $formData.gender,
                                options: ["Male", "Female"],
                                placeholder: "Select gender",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Nationality",
                                text: $formData.nationality,
                                placeholder: "Enter nationality",
                                isRequired: true
                            )
                        }
                        
                        // Passport Information Section
                        Group {
                
                            
                            SectionAFInfoView(
                                title: "Passport Number",
                                text: $formData.passportNumber,
                                placeholder: "Enter passport number",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Issue Date",
                                text: $formData.passportIssueDate,
                                placeholder: "YYYYMMDD",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Expiry Date",
                                text: $formData.passportExpiryDate,
                                placeholder: "YYYYMMDD",
                                isRequired: true
                            )
                        }
                        
                        // Contact Information Section
                        Group {
                         
                            
                            SectionAFInfoView(
                                title: "Korea Address",
                                text: $formData.koreaAddress,
                                placeholder: "Enter Korea address",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Telephone Number",
                                text: $formData.telephoneNumber,
                                placeholder: "Enter telephone number",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Phone Number",
                                text: $formData.phoneNumber,
                                placeholder: "Enter mobile number",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Home Country Address",
                                text: $formData.homelandAddress,
                                placeholder: "Enter homeland address",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Home Country Phone",
                                text: $formData.homelandPhoneNumber,
                                placeholder: "Enter homeland phone",
                                isRequired: true
                            )
                        }
                        
                        // School Information Section
                        Group {
                       
                            
                            DropdownAFInfoField(
                                title: "School Status",
                                selectedValue: $formData.schoolStatus,
                                options: ["NonSchool", "Elementary", "Middle", "High"],
                                placeholder: "Select status",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "School Name",
                                text: $formData.schoolName,
                                placeholder: "Enter school name",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "School Phone",
                                text: $formData.schoolPhoneNumber,
                                placeholder: "Enter school phone",
                                isRequired: true
                            )
                            DropdownAFInfoField(
                                title: "School Type",
                                selectedValue: $formData.schoolType,
                                options: ["Accredited", "NonAccredited"],
                                placeholder: "Select type",
                                isRequired: true
                            )
                        }
                        
                        // Work Information Section
                        Group {
                          
                            
                            SectionAFInfoView(
                                title: "Previous Workplace",
                                text: $formData.originalWorkplaceName,
                                placeholder: "Enter previous workplace",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Previous Registration Number",
                                text: $formData.originalWorkplaceRegistrationNumber,
                                placeholder: "Enter registration number",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Previous Workplace Phone",
                                text: $formData.originalWorkplacePhoneNumber,
                                placeholder: "Enter workplace phone",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Future Workplace",
                                text: $formData.futureWorkplaceName,
                                placeholder: "Enter future workplace",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Future Workplace Phone",
                                text: $formData.futureWorkplacePhoneNumber,
                                placeholder: "Enter workplace phone",
                                isRequired: true
                            )
                        }
                        
                        // Additional Information Section
                        Group {
                        
                            
                            SectionAFInfoView(
                                title: "Annual Income",
                                text: $formData.incomeAmount,
                                placeholder: "Enter annual income",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Occupation",
                                text: $formData.job,
                                placeholder: "Enter occupation",
                                isRequired: true
                            )
                            SectionAFInfoView(
                                title: "Refund Account",
                                text: $formData.refundAccountNumber,
                                placeholder: "Enter account number",
                                isRequired: true
                            )
                        }
                        
                        // Action Buttons
                        HStack {
                            Button("Done") {
                                handleDoneButton()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                })
                .navigationDestination(isPresented: $navigateToAFAutoView) {
                    AFAutoView()
                }
            }
            .onAppear {
                print("\n📱 AFInfoView appeared")
                 // 먼저 저장된 데이터 로드
                 loadSavedData()
                 // 그 다음 서버에서 최신 데이터 fetch
                 verifyUserAndLoadData()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.3))
                }
            }
        }
        
    
    // MARK: - Data Loading and Verification
    private func verifyUserAndLoadData() {
        guard let savedUsername = KeychainWrapper.standard.string(forKey: "username"),
              savedUsername == currentUsername else {
            showError(message: "User verification failed")
            return
        }
        
        isLoading = true
        // Load saved data
        loadSavedData()
        // Fetch current data from server
        fetchApplicationFormData()
    }
    
    private func loadSavedData() {
        print("\n🔄 Starting to load all saved data...")
        
        // Load ARC Data
        if let arcData = savedARCData,
           let arcResult = try? JSONDecoder().decode(ARCResult.self, from: arcData),
           let data = arcResult.data {
            print("📄 Loading ARC data...")
            formData.foreignRegistrationNumber = data.foreignRegistrationNumber ?? ""
            formData.dateOfBirth = data.dateOfBirth ?? ""
            formData.gender = data.gender ?? ""
            // Split name into surname and given name if it contains a space
            if let name = data.name {
                let nameParts = name.split(separator: " ")
                if nameParts.count >= 2 {
                    formData.surname = String(nameParts[0])
                    formData.givenName = String(nameParts[1...].joined(separator: " "))
                } else {
                    formData.surname = name
                }
            }
            formData.nationality = data.nationality ?? ""
            print("✅ ARC data loaded successfully")
        } else {
            print("⚠️ No ARC data found")
        }
        
        // Load Passport Data
        if let passData = savedPassportData,
           let passResult = try? JSONDecoder().decode(PassportResult.self, from: passData),
           let data = passResult.data {
            print("📄 Loading Passport data...")
            formData.passportNumber = data.documentNumber ?? ""
            formData.passportIssueDate = data.dateOfIssue ?? ""
            formData.passportExpiryDate = data.dateOfExpiry ?? ""
            // 날짜와 성별 데이터 업데이트
               formData.dateOfBirth = data.dateOfBirth ?? ""  // Passport에서 날짜 데이터 가져오기
               formData.gender = data.gender == "M" ? "Male" : (data.gender == "F" ? "Female" : "") // 성별 데이터 변환하여 가져오기
            // Debug log for date and gender
               print("- Date of Birth from Passport: \(formData.dateOfBirth)")
               print("- Gender from Passport: \(formData.gender)")
            // Update surname and given name if they're empty
            if formData.surname.isEmpty {
                formData.surname = data.surName ?? ""
            }
            if formData.givenName.isEmpty {
                formData.givenName = data.givenName ?? ""
            }
            // Update nationality if it's empty
            if formData.nationality.isEmpty {
                formData.nationality = data.nationality ?? ""
            }
            print("✅ Passport data loaded successfully")
        } else {
            print("⚠️ No Passport data found")
        }
        
        // Load MyInfo Data
        if let myInfoData = savedMyInfoData,
           let myInfoDict = try? JSONDecoder().decode([String: String].self, from: myInfoData) {
            print("📄 Loading MyInfo data...")
            formData.phoneNumber = myInfoDict["phoneNumber"] ?? ""
            formData.koreaAddress = myInfoDict["koreaAddress"] ?? ""
            formData.telephoneNumber = myInfoDict["telephoneNumber"] ?? ""
            formData.homelandAddress = myInfoDict["homelandAddress"] ?? ""
            formData.homelandPhoneNumber = myInfoDict["homelandPhoneNumber"] ?? ""
            formData.schoolStatus = myInfoDict["schoolStatus"] ?? ""
            formData.schoolName = myInfoDict["schoolName"] ?? ""
            formData.schoolPhoneNumber = myInfoDict["schoolPhoneNumber"] ?? ""
            formData.schoolType = myInfoDict["schoolType"] ?? ""
            formData.originalWorkplaceName = myInfoDict["originalWorkplaceName"] ?? ""
            formData.originalWorkplaceRegistrationNumber = myInfoDict["originalWorkplaceRegistrationNumber"] ?? ""
            formData.originalWorkplacePhoneNumber = myInfoDict["originalWorkplacePhoneNumber"] ?? ""
            formData.futureWorkplaceName = myInfoDict["futureWorkplaceName"] ?? ""
            formData.futureWorkplacePhoneNumber = myInfoDict["futureWorkplacePhoneNumber"] ?? ""
            formData.incomeAmount = myInfoDict["incomeAmount"] ?? ""
            formData.job = myInfoDict["job"] ?? ""
            formData.refundAccountNumber = myInfoDict["refundAccountNumber"] ?? ""
            signatureUrl = myInfoDict["signatureUrl"] // Load existing signatureUrl
            print("✅ MyInfo data loaded successfully")
        } else {
            print("⚠️ No MyInfo data found")
        }

        // Debug log loaded data
        print("\n📝 Final loaded form data:")
        print("Identity Information:")
        print("- Foreign Registration Number: \(formData.foreignRegistrationNumber)")
        print("- Name: \(formData.surname) \(formData.givenName)")
        print("- Date of Birth: \(formData.dateOfBirth)")
        print("- Gender: \(formData.gender)")
        print("- Nationality: \(formData.nationality)")
        
        print("\nPassport Information:")
        print("- Passport Number: \(formData.passportNumber)")
        print("- Issue Date: \(formData.passportIssueDate)")
        print("- Expiry Date: \(formData.passportExpiryDate)")
        
        print("\n✅ Data loading completed")
    }
    
    private func fetchApplicationFormData() {
        guard let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            showError(message: "Authentication token not found")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    showError(message: error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    showError(message: "No data received")
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let dataDict = json?["data"] as? [String: Any] {
                        updateFormWithServerData(dataDict)
                    }
                } catch {
                    showError(message: "Failed to parse server response")
                }
            }
        }.resume()
    }
    
    private func updateFormWithServerData(_ dataDict: [String: Any]) {
        print("\n🔄 Updating form with server data...")
        
        // Identity Data
        if let identity = dataDict["identity"] as? [String: Any] {
            print("📄 Updating identity data...")
            formData.foreignRegistrationNumber = identity["foreignRegistrationNumber"] as? String ?? formData.foreignRegistrationNumber
            formData.dateOfBirth = identity["birthDate"] as? String ?? formData.dateOfBirth
            formData.gender = identity["gender"] as? String == "M" ? "Male" : (identity["gender"] as? String == "F" ? "Female" : formData.gender)
            if let name = identity["name"] as? String {
                let nameParts = name.split(separator: " ")
                if nameParts.count >= 2 {
                    formData.surname = String(nameParts[0])
                    formData.givenName = String(nameParts[1...].joined(separator: " "))
                } else {
                    formData.surname = name
                }
            }
            formData.nationality = identity["nationality"] as? String ?? formData.nationality
        }
        
        // Passport Data
        if let passport = dataDict["passport"] as? [String: Any] {
            print("📄 Updating passport data...")
            formData.passportNumber = passport["documentNumber"] as? String ?? formData.passportNumber
            formData.surname = passport["surName"] as? String ?? formData.surname
            formData.givenName = passport["givenName"] as? String ?? formData.givenName
            formData.nationality = passport["nationality"] as? String ?? formData.nationality
            formData.dateOfBirth = passport["dateOfBirth"] as? String ?? formData.dateOfBirth
            formData.gender = passport["gender"] as? String == "M" ? "Male" : (passport["gender"] as? String == "F" ? "Female" : formData.gender)
            formData.passportExpiryDate = passport["dateOfExpiry"] as? String ?? formData.passportExpiryDate
            formData.passportIssueDate = passport["dateOfIssue"] as? String ?? formData.passportIssueDate
        }
        
        // Member Details
        if let memberDetail = dataDict["memberDetail"] as? [String: Any] {
            print("📄 Updating member detail data...")
            formData.phoneNumber = memberDetail["phoneNumber"] as? String ?? formData.phoneNumber
            formData.koreaAddress = memberDetail["koreaAddress"] as? String ?? formData.koreaAddress
            formData.telephoneNumber = memberDetail["telephoneNumber"] as? String ?? formData.telephoneNumber
            formData.homelandAddress = memberDetail["homelandAddress"] as? String ?? formData.homelandAddress
            formData.homelandPhoneNumber = memberDetail["homelandPhoneNumber"] as? String ?? formData.homelandPhoneNumber
            formData.schoolStatus = memberDetail["schoolStatus"] as? String ?? formData.schoolStatus
            formData.schoolName = memberDetail["schoolName"] as? String ?? formData.schoolName
            formData.schoolPhoneNumber = memberDetail["schoolPhoneNumber"] as? String ?? formData.schoolPhoneNumber
            formData.schoolType = memberDetail["schoolType"] as? String ?? formData.schoolType
            formData.originalWorkplaceName = memberDetail["originalWorkplaceName"] as? String ?? formData.originalWorkplaceName
            formData.originalWorkplaceRegistrationNumber = memberDetail["originalWorkplaceRegistrationNumber"] as? String ?? formData.originalWorkplaceRegistrationNumber
            formData.originalWorkplacePhoneNumber = memberDetail["originalWorkplacePhoneNumber"] as? String ?? formData.originalWorkplacePhoneNumber
            formData.futureWorkplaceName = memberDetail["futureWorkplaceName"] as? String ?? formData.futureWorkplaceName
            formData.futureWorkplacePhoneNumber = memberDetail["futureWorkplacePhoneNumber"] as? String ?? formData.futureWorkplacePhoneNumber
            formData.futureWorkplaceRegistrationNumber = memberDetail["futureWorkplaceRegistrationNumber"] as? String ?? formData.futureWorkplaceRegistrationNumber
            
            // Handle income amount conversion from number to string if necessary
            if let incomeAmount = memberDetail["incomeAmount"] as? Int {
                formData.incomeAmount = String(incomeAmount)
            } else if let incomeAmount = memberDetail["incomeAmount"] as? String {
                formData.incomeAmount = incomeAmount
            }
            
            formData.job = memberDetail["job"] as? String ?? formData.job
            formData.refundAccountNumber = memberDetail["refundAccountNumber"] as? String ?? formData.refundAccountNumber
        }
        
        print("✅ Form update completed")
    }
    
    // AFInfoView
    private func handleDoneButton() {
        if validateFields() {
            isLoading = true
            updateAllData()
            // AFAutoView에 데이터 업데이트 알림
            NotificationCenter.default.post(name: Notification.Name("AFDataUpdated"), object: nil)
            navigateToAFAutoView = true
        }
    }
    
    private func validateFields() -> Bool {
        let requiredFields: [String: String] = [
            // Identity Data
            "Foreign Registration Number": formData.foreignRegistrationNumber,
            "Surname": formData.surname,
            "Given Name": formData.givenName,
            "Date of Birth": formData.dateOfBirth,
            "Gender": formData.gender,
            "Nationality": formData.nationality,
            
            // Passport Data
            "Passport Number": formData.passportNumber,
            "Issue Date": formData.passportIssueDate,
            "Expiry Date": formData.passportExpiryDate,
            
            // Contact Information
            "Korea Address": formData.koreaAddress,
            "Telephone Number": formData.telephoneNumber,
            "Phone Number": formData.phoneNumber,
            "Home Country Address": formData.homelandAddress,
            "Home Country Phone": formData.homelandPhoneNumber,
            
            // School Information
            "School Status": formData.schoolStatus,
            "School Name": formData.schoolName,
            "School Phone": formData.schoolPhoneNumber,
            "School Type": formData.schoolType,
            
            // Work Information
            "Previous Workplace": formData.originalWorkplaceName,
            "Previous Registration Number": formData.originalWorkplaceRegistrationNumber,
            "Previous Workplace Phone": formData.originalWorkplacePhoneNumber,
            "Future Workplace": formData.futureWorkplaceName,
            "Future Workplace Phone": formData.futureWorkplacePhoneNumber,
            
            // Additional Information
            "Annual Income": formData.incomeAmount,
            "Occupation": formData.job,
            "Refund Account": formData.refundAccountNumber
        ]
        
        let emptyFields = requiredFields.filter { $0.value.isEmpty }
        
        if !emptyFields.isEmpty {
            let fieldNames = emptyFields.map { $0.key }.joined(separator: ", ")
            showError(message: "Please fill in the following required fields: \(fieldNames)")
            return false
        }
        
        return true
    }

    private func updateAllData() {
        let group = DispatchGroup()
        var errorMessages: [String] = []
        
        // Update ARC Data
        group.enter()
        updateARCData { success in
            if !success {
             //   errorMessages.append("Failed to update Identity Card information")
            }
            group.leave()
        }
        
        // Update Passport Data
        group.enter()
        updatePassportData { success in
            if !success {
             //   errorMessages.append("Failed to update Passport information")
            }
            group.leave()
        }
        
        // Update MyInfo Data
        group.enter()
        updateMyInfoData { success in
            if !success {
            //    errorMessages.append("Failed to update Personal information")
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            isLoading = false
            if !errorMessages.isEmpty {
                // 구체적인 에러 메시지 표시
              //  showError(message: errorMessages.joined(separator: "\n"))
            } else {
                // AFAutoView로 이동
                    NotificationCenter.default.post(name: Notification.Name("AFDataUpdated"), object: nil)
                    navigateToAFAutoView = true
            }
        }
    }
        
    private func updateARCData(completion: @escaping (Bool) -> Void) {
        guard let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            completion(false)
            return
        }
        
        // Using the same format as ScanARCView's createARCIdentity
        let arcData: [String: Any] = [
            "foreignRegistrationNumber": formData.foreignRegistrationNumber,
            "birthDate": formData.dateOfBirth,
            "gender": formData.gender == "Male" ? "M" : "F",
            "name": formData.surname + " " + formData.givenName,
            "nationality": formData.nationality,
            "region": "California",
            "residenceStatus": "Permanent Resident",
            "visaType": "D-8",
            "permitDate": "20220115",
            "expirationDate": "20320115",
            "issueCity": "Los Angeles",
            "reportDate": "20231012",
            "residence": "1234 Elm St, Los Angeles, CA"
        ]
        
        var request = URLRequest(url: URL(string: Self.baseARC)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: arcData)
        } catch {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("ARC Update Error:", error.localizedDescription)
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(false)
                return
            }
            
            completion(true)
        }.resume()
    }

    private func updatePassportData(completion: @escaping (Bool) -> Void) {
        guard let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            completion(false)
            return
        }
        
        // Using the same format as ScanPassView's createPassportData
        let passportData: [String: Any] = [
            "documentNumber": formData.passportNumber,
            "surName": formData.surname,
            "givenName": formData.givenName,
            "nationality": formData.nationality,
            "dateOfBirth": formData.dateOfBirth,
            "gender": formData.gender == "Male" ? "M" : "F",
            "dateOfExpiry": formData.passportExpiryDate,
            "dateOfIssue": formData.passportIssueDate,
            "issueCountry": formData.nationality
        ]
        
        var request = URLRequest(url: URL(string: Self.basePass)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: passportData)
        } catch {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Passport Update Error:", error.localizedDescription)
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(false)
                return
            }
            
            completion(true)
        }.resume()
    }

    private func updateMyInfoData(completion: @escaping (Bool) -> Void) {
        guard let token = KeychainWrapper.standard.string(forKey: "accessToken") else {
            completion(false)
            return
        }
        
        // Using the same format as MyInfoView's createMyInfo
        let myInfoData: [String: Any] = [
            "phoneNumber": formData.phoneNumber,
            "annualIncome": Int(formData.incomeAmount) ?? 0,
            "workplaceName": formData.originalWorkplaceName,
            "workplaceRegistrationNumber": formData.originalWorkplaceRegistrationNumber,
            "workplacePhoneNumber": formData.originalWorkplacePhoneNumber,
            "futureWorkplaceName": formData.futureWorkplaceName,
            "futureWorkplaceRegistrationNumber": formData.originalWorkplaceRegistrationNumber,
            "futureWorkplacePhoneNumber": formData.futureWorkplacePhoneNumber,
            "profileImageUrl": "",  // Optional
            "signatureUrl": signatureUrl ?? "",     // Optional
            "koreaAddress": formData.koreaAddress,
            "telephoneNumber": formData.telephoneNumber,
            "homelandAddress": formData.homelandAddress,
            "homelandPhoneNumber": formData.homelandPhoneNumber,
            "schoolStatus": formData.schoolStatus,
            "schoolName": formData.schoolName,
            "schoolPhoneNumber": formData.schoolPhoneNumber,
            "schoolType": formData.schoolType,
            "originalWorkplaceName": formData.originalWorkplaceName,
            "originalWorkplaceRegistrationNumber": formData.originalWorkplaceRegistrationNumber,
            "originalWorkplacePhoneNumber": formData.originalWorkplacePhoneNumber,
            "incomeAmount": formData.incomeAmount,
            "job": formData.job,
            "refundAccountNumber": formData.refundAccountNumber
        ]
        
        var request = URLRequest(url: URL(string: Self.baseMyInfo)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: myInfoData)
        } catch {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("MyInfo Update Error:", error.localizedDescription)
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(false)
                return
            }
            
            completion(true)
        }.resume()
    }
 
     private func showError(message: String) {
         errorMessage = message
         showError = true
     }
 }



// MARK: - Supporting Views

// MARK: - Supporting Views
struct SectionAFInfoView: View {
    var title: String
    @Binding var text: String
    var placeholder: String
    var isRequired: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.gray)
                if isRequired {
                    Text("*").foregroundColor(.red)
                }
            }
            TextField(placeholder, text: $text)
                .padding()
                              .background(Color.white)
                              .cornerRadius(10)
                              .overlay(
                                  RoundedRectangle(cornerRadius: 10)
                                      .stroke(Color.gray, lineWidth: 1)
                              )
        }
    }
}


struct DropdownAFInfoField: View {
    var title: String
    @Binding var selectedValue: String
    var options: [String]
    var placeholder: String
    var isRequired: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.gray)
                if isRequired {
                    Text("*").foregroundColor(.red)
                }
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
                    Text(selectedValue.isEmpty ? placeholder : selectedValue)
                        .foregroundColor(selectedValue.isEmpty ? .gray : .black)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
        }
    }
}

struct AFInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AFInfoView()
    }
}
