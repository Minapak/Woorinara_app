import SwiftUI
import SwiftKeychainWrapper

struct AFInfoView: View {
    // AppStorage for UserDefaults Data
    @AppStorage("SavedARCData") private var savedARCData: Data?
    @AppStorage("SavedPassportData") private var savedPassportData: Data?
    @AppStorage("SavedMyInfoData") private var savedMyInfoData: Data?

    // State Variables
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

    // Loading and Error Handling
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage: String?

    // Access Token
    let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Submitting...")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Application Form \nInformation")
                            .font(.system(size: 32, weight: .bold))

//                        Text("If the recognized content is different from the real thing, usage may be restricted.")
//                            .font(.system(size: 18))
//                            .foregroundColor(.gray)
                    // Personal Information
                    Group {
                        SectionAFInfoView(title: "Surname", text: $surname, placeholder: "Enter surname")
                        SectionAFInfoView(title: "Given Name", text: $givenName, placeholder: "Enter given name")
                        SectionAFInfoView(title: "Date of Birth", text: $dateOfBirth, placeholder: "yyyy-mm-dd")
                        DropdownAFInfoField(title: "Gender", selectedValue: $gender, options: ["Male", "Female"], isRequired: true)
                        SectionAFInfoView(title: "Nationality", text: $nationality, placeholder: "Enter nationality")
                        SectionAFInfoView(title: "Foreign Registration Number", text: $foreignRegistrationNumber, placeholder: "123456-1234567")
                    }
                    
                    // Passport Information
                    Group {
                        SectionAFInfoView(title: "Passport Number", text: $passportNumber, placeholder: "Enter passport number")
                        SectionAFInfoView(title: "Passport Issue Date", text: $passportIssueDate, placeholder: "yyyy-mm-dd")
                        SectionAFInfoView(title: "Passport Expiry Date", text: $passportExpiryDate, placeholder: "yyyy-mm-dd")
                    }
                    
                    // Contact Information
                    Group {
                        SectionAFInfoView(title: "Address in Korea", text: $addressInKorea, placeholder: "Enter address")
                        SectionAFInfoView(title: "Telephone Number", text: $telephoneNumber, placeholder: "Enter telephone number")
                        SectionAFInfoView(title: "Phone Number", text: $phoneNumber, placeholder: "Enter phone number")
                        SectionAFInfoView(title: "Homeland Address", text: $homelandAddress, placeholder: "Enter homeland address")
                        SectionAFInfoView(title: "Homeland Phone Number", text: $homelandPhoneNumber, placeholder: "Enter homeland phone number")
                    }
                    
                    // School Information
                    Group {
                        DropdownAFInfoField(title: "School Status", selectedValue: $schoolStatus, options: ["None School", "Elementary", "Middle", "High"], isRequired: true)
                        SectionAFInfoView(title: "School Name", text: $schoolName, placeholder: "Enter school name")
                        SectionAFInfoView(title: "School Phone Number", text: $schoolPhoneNumber, placeholder: "Enter school phone number")
                        DropdownAFInfoField(title: "Type of School", selectedValue: $schoolType, options: ["Unaccredited", "Accredited"], isRequired: true)
                    }
                    
                    // Workplace Information
                    Group {
                        SectionAFInfoView(title: "Original Workplace Name", text: $originalWorkplaceName, placeholder: "Enter workplace name")
                        SectionAFInfoView(title: "Original Workplace Registration Number", text: $originalWorkplaceRegistrationNumber, placeholder: "Enter registration number")
                        SectionAFInfoView(title: "Original Workplace Phone Number", text: $originalWorkplacePhoneNumber, placeholder: "Enter phone number")
                        SectionAFInfoView(title: "Future Workplace Name", text: $futureWorkplaceName, placeholder: "Enter workplace name")
                        SectionAFInfoView(title: "Future Workplace Phone Number", text: $futureWorkplacePhoneNumber, placeholder: "Enter phone number")
                    }
                    
                    // Additional Information
                    Group {
                        SectionAFInfoView(title: "Income Amount", text: $incomeAmount, placeholder: "Enter income amount")
                        SectionAFInfoView(title: "Occupation", text: $occupation, placeholder: "Enter occupation")
                        SectionAFInfoView(title: "Email", text: $email, placeholder: "Enter email")
                        SectionAFInfoView(title: "Refund Account Number", text: $refundAccountNumber, placeholder: "Enter account number")
                        SectionAFInfoView(title: "Date of Application", text: $dateOfApplication, placeholder: "yyyy-mm-dd")
                    }
                    
                    // Submit Buttons
                    HStack {
                        
                        
                        Button("Done") {
                            sendPassportData()
                            submitMyInfoData()
                            sendARCData()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            }
        }
        .padding()
        .onAppear(perform: loadSavedData)
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown Error"), dismissButton: .default(Text("OK")))
        }
    }

    // Load saved data from UserDefaults
    private func loadSavedData() {
        if let arcData = savedARCData {
            if let decodedData = try? JSONDecoder().decode([String: String].self, from: arcData) {
                foreignRegistrationNumber = decodedData["foreignRegistrationNumber"] ?? ""
            }
        }

        if let passportData = savedPassportData {
            if let decodedData = try? JSONDecoder().decode([String: String].self, from: passportData) {
                surname = decodedData["surName"] ?? ""
                givenName = decodedData["givenName"] ?? ""
                dateOfBirth = decodedData["dateOfBirth"] ?? ""
                gender = decodedData["gender"] ?? ""
                nationality = decodedData["nationality"] ?? ""
                passportNumber = decodedData["documentNumber"] ?? ""
                passportIssueDate = decodedData["dateOfIssue"] ?? ""
                passportExpiryDate = decodedData["dateOfExpiry"] ?? ""
            }
        }

        if let myInfoData = savedMyInfoData {
            if let decodedData = try? JSONDecoder().decode([String: String].self, from: myInfoData) {
                addressInKorea = decodedData["koreaAddress"] ?? ""
                telephoneNumber = decodedData["telephoneNumber"] ?? ""
                phoneNumber = decodedData["phoneNumber"] ?? ""
                homelandAddress = decodedData["homelandAddress"] ?? ""
                homelandPhoneNumber = decodedData["homelandPhoneNumber"] ?? ""
                schoolStatus = decodedData["schoolStatus"] ?? ""
                schoolName = decodedData["schoolName"] ?? ""
                schoolPhoneNumber = decodedData["schoolPhoneNumber"] ?? ""
                schoolType = decodedData["schoolType"] ?? ""
                originalWorkplaceName = decodedData["originalWorkplaceName"] ?? ""
                originalWorkplaceRegistrationNumber = decodedData["originalWorkplaceRegistrationNumber"] ?? ""
                originalWorkplacePhoneNumber = decodedData["originalWorkplacePhoneNumber"] ?? ""
                futureWorkplaceName = decodedData["futureWorkplaceName"] ?? ""
                futureWorkplacePhoneNumber = decodedData["futureWorkplacePhoneNumber"] ?? ""
                incomeAmount = decodedData["incomeAmount"] ?? ""
                occupation = decodedData["job"] ?? ""
                email = decodedData["email"] ?? ""
                refundAccountNumber = decodedData["refundAccountNumber"] ?? ""
            }
        }

        // Set today's date for the application
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        dateOfApplication = formatter.string(from: Date())
    }

    // Submit My Info Data
    private func submitMyInfoData() {
        guard let accessToken = accessToken else {
            errorMessage = "Access token not available."
            showError = true
            return
        }

        let requestBody: [String: Any] = [
            "koreaAddress": addressInKorea,
            "telephoneNumber": telephoneNumber,
            "phoneNumber": phoneNumber,
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
            "email": email,
            "refundAccountNumber": refundAccountNumber,
            "dateOfApplication": dateOfApplication
        ]

        sendData(to: "http://43.203.237.202:18080/api/v1/details/update", requestBody: requestBody)
    }

    // Submit ARC Data
    private func sendARCData() {
        guard let accessToken = accessToken else {
            errorMessage = "Access token not available."
            showError = true
            return
        }

        let requestBody: [String: Any] = [
            "foreignRegistrationNumber": foreignRegistrationNumber,
            "dateOfBirth": dateOfBirth,
            "gender": gender,
            "nationality": nationality
        ]

        sendData(to: "http://43.203.237.202:18080/api/v1/identity", requestBody: requestBody)
    }

    // Submit Passport Data
    private func sendPassportData() {
        guard let accessToken = accessToken else {
            errorMessage = "Access token not available."
            showError = true
            return
        }

        let requestBody: [String: Any] = [
            "passportNumber": passportNumber,
            "surname": surname,
            "givenName": givenName,
            "dateOfBirth": dateOfBirth,
            "gender": gender,
            "passportIssueDate": passportIssueDate,
            "passportExpiryDate": passportExpiryDate,
            "nationality": nationality
        ]

        sendData(to: "http://43.203.237.202:18080/api/v1/passport", requestBody: requestBody)
    }

    // Generic Send Data Function
    private func sendData(to url: String, requestBody: [String: Any]) {
        guard let apiUrl = URL(string: url) else {
            errorMessage = "Invalid URL."
            showError = true
            return
        }

        var request = URLRequest(url: apiUrl)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            errorMessage = "Failed to encode request body."
            showError = true
            return
        }

        isLoading = true

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Network error: \(error.localizedDescription)"
                    showError = true
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    errorMessage = "Failed to submit data."
                    showError = true
                }
                return
            }

            DispatchQueue.main.async {
                print("Submission successful!")
            }
        }.resume()
    }
}

// SectionView Component
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

// DropdownField Component
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
