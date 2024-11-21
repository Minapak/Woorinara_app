import SwiftUI
import SwiftKeychainWrapper

struct AFInfoView: View {
    // AppStorage
    @AppStorage("SavedarcData") private var savedARCData: Data?
    @AppStorage("SavedpassportData") private var savedPassportData: Data?
    @AppStorage("SavedmyInfoData") private var savedMyInfoData: Data?
    
    // State
    @State private var arcData: ARCIdentityData?
    @State private var passportData: PassportData?
    @State private var myInfoData: MyInfoData?
    @State private var navigateToAFAutoView = false // 추가
    @State private var surname: String = ""
    @State private var givenName: String = ""
    @State private var dateOfBirth: String = ""
    @State private var gender: String = ""
    @State private var nationality: String = ""
    @State private var foreignRegistrationNumber: String = ""
    
    @State private var passportNumber: String = ""
    @State private var passportIssueDate: String = ""
    @State private var passportExpiryDate: String = ""
    
    @State private var addressInKorea: String = ""
    @State private var telephoneNumber: String = ""
    @State private var phoneNumber: String = ""
    @State private var homelandAddress: String = ""
    @State private var homelandPhoneNumber: String = ""
    
    @State private var schoolStatus: String = ""
    @State private var schoolName: String = ""
    @State private var schoolPhoneNumber: String = ""
    @State private var schoolType: String = ""
    
    @State private var originalWorkplaceName: String = ""
    @State private var originalWorkplaceRegistrationNumber: String = ""
    @State private var originalWorkplacePhoneNumber: String = ""
    @State private var futureWorkplaceName: String = ""
    @State private var futureWorkplacePhoneNumber: String = ""
    
    @State private var incomeAmount: String = ""
    @State private var occupation: String = ""
    @State private var email: String = ""
    @State private var refundAccountNumber: String = ""
    @State private var dateOfApplication: String = ""
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccessAlert = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    private let endpoint = "http://43.203.237.202:18080/api/v1/members/applicationForm"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Application Form Information")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.bottom, 20)
                    
                    Group {
                        // Form fields...
                        SectionAFInfoView(title: "Surname", text: $surname, placeholder: "Enter surname")
                        SectionAFInfoView(title: "Given Name", text: $givenName, placeholder: "Enter given name")
                        SectionAFInfoView(title: "Date of Birth", text: $dateOfBirth, placeholder: "yyyy-mm-dd")
                        DropdownAFInfoField(title: "Gender", selectedValue: $gender, options: ["Male", "Female"], isRequired: true)
                        SectionAFInfoView(title: "Nationality", text: $nationality, placeholder: "Enter nationality")
                        SectionAFInfoView(title: "Foreign Registration Number", text: $foreignRegistrationNumber, placeholder: "123456-1234567")
                        
                        SectionAFInfoView(title: "Passport Number", text: $passportNumber, placeholder: "Enter passport number")
                        SectionAFInfoView(title: "Passport Issue Date", text: $passportIssueDate, placeholder: "yyyy-mm-dd")
                        SectionAFInfoView(title: "Passport Expiry Date", text: $passportExpiryDate, placeholder: "yyyy-mm-dd")
                        
                        SectionAFInfoView(title: "Address in Korea", text: $addressInKorea, placeholder: "Enter address")
                        SectionAFInfoView(title: "Telephone Number", text: $telephoneNumber, placeholder: "Enter telephone number")
                        SectionAFInfoView(title: "Phone Number", text: $phoneNumber, placeholder: "Enter phone number")
                        SectionAFInfoView(title: "Homeland Address", text: $homelandAddress, placeholder: "Enter homeland address")
                        SectionAFInfoView(title: "Homeland Phone Number", text: $homelandPhoneNumber, placeholder: "Enter homeland phone number")
                        
                        DropdownAFInfoField(title: "School Status", selectedValue: $schoolStatus, options: ["None School", "Elementary", "Middle", "High"], isRequired: true)
                        SectionAFInfoView(title: "School Name", text: $schoolName, placeholder: "Enter school name")
                        SectionAFInfoView(title: "School Phone Number", text: $schoolPhoneNumber, placeholder: "Enter school phone number")
                        DropdownAFInfoField(title: "Type of School", selectedValue: $schoolType, options: ["Unaccredited", "Accredited"], isRequired: true)
                        
                        SectionAFInfoView(title: "Original Workplace Name", text: $originalWorkplaceName, placeholder: "Enter workplace name")
                        SectionAFInfoView(title: "Original Workplace Registration Number", text: $originalWorkplaceRegistrationNumber, placeholder: "Enter registration number")
                        SectionAFInfoView(title: "Original Workplace Phone Number", text: $originalWorkplacePhoneNumber, placeholder: "Enter phone number")
                        SectionAFInfoView(title: "Future Workplace Name", text: $futureWorkplaceName, placeholder: "Enter workplace name")
                        SectionAFInfoView(title: "Future Workplace Phone Number", text: $futureWorkplacePhoneNumber, placeholder: "Enter phone number")
                        
                        SectionAFInfoView(title: "Income Amount", text: $incomeAmount, placeholder: "Enter income amount")
                        SectionAFInfoView(title: "Occupation", text: $occupation, placeholder: "Enter occupation")
                        SectionAFInfoView(title: "Email", text: $email, placeholder: "Enter email")
                        SectionAFInfoView(title: "Refund Account Number", text: $refundAccountNumber, placeholder: "Enter account number")
                        SectionAFInfoView(title: "Date of Application", text: $dateOfApplication, placeholder: "yyyy-mm-dd")
            
                    }
                    Spacer()

                    HStack {
                        Button("Done") {
                            handleDoneButton()                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToAFAutoView) {
                AFAutoView()
            }
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black)
                    .imageScale(.large)
                Text("")
                    .foregroundColor(.black)
            })
            .onAppear {
                loadAllData()
                updateFormFields() // Added this call
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Application form submitted successfully")
            }
        }
    }
    
    private func loadAllData() {
        loadARCData()
        loadPassportData()
        loadMyInfoData()
    }
 

    private func handleDoneButton() {
        guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") else {
            showError(message: "Access token not available")
            return
        }
        
        // MyInfoData 생성
        let myInfoDict: [String: String] = [
            "phoneNumber": phoneNumber,
            "koreaAddress": addressInKorea,
            "telephoneNumber": telephoneNumber,
            "homelandAddress": homelandAddress,
            "homelandPhoneNumber": homelandPhoneNumber,
            "schoolStatus": schoolStatus,
            "schoolName": schoolName,
            "schoolPhoneNumber": schoolPhoneNumber,
            "schoolType": schoolType,
            "originalWorkplaceName": originalWorkplaceName,
            "originalWorkplaceRegistrationNumber": originalWorkplaceRegistrationNumber,
            "originalWorkplacePhoneNumber": originalWorkplacePhoneNumber,
            "futureWorkplaceName": futureWorkplaceName,
            "futureWorkplacePhoneNumber": futureWorkplacePhoneNumber,
            "incomeAmount": incomeAmount,
            "job": occupation,
            "refundAccountNumber": refundAccountNumber
        ]
        
        // Save data to UserDefaults using AppStorage
        if let encodedData = try? JSONEncoder().encode(myInfoDict) {
            savedMyInfoData = encodedData
        }
        
        // AFAutoView로 이동
        navigateToAFAutoView = true
    }
    private func updateFormFields() {
        // Update fields from ARC data
        if let arc = arcData {
            foreignRegistrationNumber = arc.foreignRegistrationNumber
            dateOfBirth = arc.birthDate
            gender = arc.gender
            nationality = arc.nationality
            
            // Split name into surname and given name
            let nameParts = arc.name.split(separator: " ")
            if nameParts.count >= 2 {
                surname = String(nameParts[0])
                givenName = String(nameParts[1...].joined(separator: " "))
            } else {
                surname = arc.name
            }
        }
        
        // Update fields from Passport data
        if let passport = passportData {
            passportNumber = passport.documentNumber
            surname = passport.surName
            givenName = passport.givenName
            nationality = passport.nationality
            dateOfBirth = passport.dateOfBirth
            gender = passport.gender
            passportExpiryDate = passport.dateOfExpiry
            passportIssueDate = passport.dateOfIssue
        }
        
        // Update fields from MyInfo data
        if let myInfo = myInfoData {
            phoneNumber = myInfo.phoneNumber
            addressInKorea = myInfo.koreaAddress
            telephoneNumber = myInfo.telephoneNumber
            homelandAddress = myInfo.homelandAddress
            homelandPhoneNumber = myInfo.homelandPhoneNumber
            schoolStatus = myInfo.schoolStatus
            schoolName = myInfo.schoolName
            schoolPhoneNumber = myInfo.schoolPhoneNumber
            schoolType = myInfo.schoolType
            originalWorkplaceName = myInfo.originalWorkplaceName
            originalWorkplaceRegistrationNumber = myInfo.originalWorkplaceRegistrationNumber
            originalWorkplacePhoneNumber = myInfo.originalWorkplacePhoneNumber
            futureWorkplaceName = myInfo.futureWorkplaceName
            futureWorkplacePhoneNumber = myInfo.futureWorkplacePhoneNumber
            incomeAmount = myInfo.incomeAmount
            occupation = myInfo.job
            refundAccountNumber = myInfo.refundAccountNumber
        }
    }
    
    private func loadARCData() {
        guard let savedData = savedARCData,
              let decodedData = try? JSONDecoder().decode([String: String].self, from: savedData) else {
            return
        }
        
        arcData = ARCIdentityData(
            foreignRegistrationNumber: decodedData["foreignRegistrationNumber"] ?? "",
            birthDate: decodedData["birthDate"] ?? "",
            gender: decodedData["gender"] ?? "",
            name: decodedData["name"] ?? "",
            nationality: decodedData["nationality"] ?? "",
            region: decodedData["region"] ?? "",
            residenceStatus: decodedData["residenceStatus"] ?? "",
            visaType: decodedData["visaType"] ?? "",
            permitDate: decodedData["permitDate"] ?? "",
            expirationDate: decodedData["expirationDate"] ?? "",
            issueCity: decodedData["issueCity"] ?? "",
            reportDate: decodedData["reportDate"] ?? "",
            residence: decodedData["residence"] ?? ""
        )
    }
    
    private func loadPassportData() {
        guard let savedData = savedPassportData,
              let decodedData = try? JSONDecoder().decode([String: String].self, from: savedData) else {
            return
        }
        
        passportData = PassportData(
            documentNumber: decodedData["documentNumber"] ?? "",
            surName: decodedData["surName"] ?? "",
            givenName: decodedData["givenName"] ?? "",
            nationality: decodedData["nationality"] ?? "",
            dateOfBirth: decodedData["dateOfBirth"] ?? "",
            gender: decodedData["gender"] ?? "",
            dateOfExpiry: decodedData["dateOfExpiry"] ?? "",
            dateOfIssue: decodedData["dateOfIssue"] ?? "",
            issueCountry: decodedData["issueCountry"] ?? ""
        )
    }
    
    private func loadMyInfoData() {
        guard let savedData = savedMyInfoData else {
            return
        }
        
        do {
            // JSON 데이터로부터 직접 디코딩
            myInfoData = try JSONDecoder().decode(MyInfoData.self, from: savedData)
        } catch {
            print("Error decoding MyInfoData: \(error)")
            
            // 실패시 dictionary 방식으로 시도
            if let decodedData = try? JSONDecoder().decode([String: String].self, from: savedData) {
                // Dictionary를 MyInfoData로 변환
                let personalInfo: [String: Any] = [
                    "phoneNumber": decodedData["phoneNumber"] ?? "",
                    "koreaAddress": decodedData["koreaAddress"] ?? "",
                    "telephoneNumber": decodedData["telephoneNumber"] ?? "",
                    "homelandAddress": decodedData["homelandAddress"] ?? "",
                    "homelandPhoneNumber": decodedData["homelandPhoneNumber"] ?? "",
                    "schoolStatus": decodedData["schoolStatus"] ?? "",
                    "schoolName": decodedData["schoolName"] ?? "",
                    "schoolPhoneNumber": decodedData["schoolPhoneNumber"] ?? "",
                    "schoolType": decodedData["schoolType"] ?? "",
                    "originalWorkplaceName": decodedData["originalWorkplaceName"] ?? "",
                    "originalWorkplaceRegistrationNumber": decodedData["originalWorkplaceRegistrationNumber"] ?? "",
                    "originalWorkplacePhoneNumber": decodedData["originalWorkplacePhoneNumber"] ?? "",
                    "futureWorkplaceName": decodedData["futureWorkplaceName"] ?? "",
                    "futureWorkplacePhoneNumber": decodedData["futureWorkplacePhoneNumber"] ?? "",
                    "incomeAmount": decodedData["incomeAmount"] ?? "",
                    "job": decodedData["job"] ?? "",
                    "refundAccountNumber": decodedData["refundAccountNumber"] ?? "",
                    "workplaceName": decodedData["workplaceName"] ?? "",
                    "workplaceRegistrationNumber": decodedData["workplaceRegistrationNumber"] ?? "",
                    "workplacePhoneNumber": decodedData["workplacePhoneNumber"] ?? "",
                    "futureWorkplaceRegistrationNumber": decodedData["futureWorkplaceRegistrationNumber"] ?? "",
                    "annualIncome": Int(decodedData["annualIncome"] ?? "0"),
                    "profileImageUrl": decodedData["profileImageUrl"],
                    "signatureUrl": decodedData["signatureUrl"]
                ]
                myInfoData = MyInfoData(dictionary: personalInfo)
            }
        }
    }
    private func submitApplicationForm() {
            guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken"),
                  let url = URL(string: endpoint),
                  let arc = arcData,
                  let passport = passportData,
                  let myInfo = myInfoData else {
                showError(message: "Missing required data")
                return
            }
            
            let formData: [String: Any] = [
                "arcInfo": getARCInfo(from: arc),
                "passportInfo": getPassportInfo(from: passport),
                "personalInfo": getPersonalInfo(from: myInfo)
            ]
            
            isLoading = true
            submitForm(with: formData, accessToken: accessToken) { error in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    if let error = error {
                        showError(message: "Network error: \(error.localizedDescription)")
                    } else {
                        showSuccessAlert = true
                    }
                }
            }
        }

        private func getARCInfo(from arc: ARCIdentityData) -> [String: String] {
            return [
                "foreignRegistrationNumber": arc.foreignRegistrationNumber,
                "birthDate": arc.birthDate,
                "gender": arc.gender,
                "name": arc.name,
                "nationality": arc.nationality,
                "visaType": arc.visaType
            ]
        }

        private func getPassportInfo(from passport: PassportData) -> [String: String] {
            return [
                "documentNumber": passport.documentNumber,
                "surName": passport.surName,
                "givenName": passport.givenName,
                "dateOfIssue": passport.dateOfIssue,
                "dateOfExpiry": passport.dateOfExpiry
            ]
        }

        private func getPersonalInfo(from myInfo: MyInfoData) -> [String: String] {
            return [
                "phoneNumber": myInfo.phoneNumber,
                "koreaAddress": myInfo.koreaAddress,
                "telephoneNumber": myInfo.telephoneNumber,
                "homelandAddress": myInfo.homelandAddress,
                "homelandPhoneNumber": myInfo.homelandPhoneNumber,
                "schoolStatus": myInfo.schoolStatus,
                "schoolName": myInfo.schoolName,
                "schoolPhoneNumber": myInfo.schoolPhoneNumber,
                "schoolType": myInfo.schoolType,
                "originalWorkplaceName": myInfo.originalWorkplaceName,
                "originalWorkplaceRegistrationNumber": myInfo.originalWorkplaceRegistrationNumber,
                "originalWorkplacePhoneNumber": myInfo.originalWorkplacePhoneNumber,
                "futureWorkplaceName": myInfo.futureWorkplaceName,
                "futureWorkplacePhoneNumber": myInfo.futureWorkplacePhoneNumber,
                "incomeAmount": myInfo.incomeAmount,
                "job": myInfo.job,
                "refundAccountNumber": myInfo.refundAccountNumber
            ]
        }

        private func submitForm(with formData: [String: Any], accessToken: String, completion: @escaping (Error?) -> Void) {
            guard let url = URL(string: endpoint) else {
                completion(NSError(domain: "Invalid URL", code: -1, userInfo: nil))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: formData)
            } catch {
                completion(error)
                return
            }
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(error)
                } else if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    completion(NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: nil))
                } else {
                    completion(nil)
                }
            }.resume()
        }

        private func showError(message: String) {
            errorMessage = message
            showError = true
        }
    }


// MARK: - Supporting Views
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.blue)
            .padding(.top, 10)
    }
}

struct FormRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(value.isEmpty ? "Not provided" : value)
                .font(.body)
        }
        .padding(.vertical, 4)
    }
}

struct SectionAFInfoView: View {
    var title: String
    @Binding var text: String
    var placeholder: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
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
    var isRequired: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
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
                    Text(selectedValue.isEmpty ? "Select \(title)" : selectedValue)
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
