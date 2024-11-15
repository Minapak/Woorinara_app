import SwiftUI
import VComponents
import SwiftKeychainWrapper

struct ScanPassView: View {
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
    @State private var showError = false
    @State private var errorMessage = ""
    @FocusState private var isFocused: Bool
    @State private var isLoading = false

    @State private var navigateToMyInfoView = false
    @State private var showAlertInfo = false
    @State private var navigateToScanPrePassView = false // Navigation flag for ScanPrePassView

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
        if let result = result {
            self._surname = State(initialValue: result.data?.surName ?? "")
            self._givenName = State(initialValue: result.data?.givenName ?? "")
            self._middleName = State(initialValue: result.data?.middleName ?? "")
            self._dateOfBirth = State(initialValue: result.data?.dateOfBirth ?? "")
            self._gender = State(initialValue: result.data?.gender)
            self._countryRegion = State(initialValue: result.data?.issueCountry ?? "")
            self._passportNumber = State(initialValue: result.data?.documentNumber ?? "")
            self._passportExpirationDate = State(initialValue: result.data?.dateOfExpiry ?? "")
            self._passportNationality = State(initialValue: result.data?.nationality ?? "")
//            self._dateOfIssue = State(initialValue: result.data?.dateOfIssue ?? "")
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Please check your ID information")
                            .font(.system(size: 32, weight: .bold))

                        Text("If the recognized content is different from the real thing, usage may be restricted.")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)

                        VStack(alignment: .leading) {
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

                            InputField(title: "Surname", text: $surname, isFocused: _isFocused)
                            InputField(title: "Given name", text: $givenName, showError: showError && givenName.isEmpty, placeholder: "TANAKA", isRequired: true, isFocused: _isFocused)
                            InputField(title: "Middle name", text: $middleName, isFocused: _isFocused)

                            InputField(title: "Date of Birth", text: $dateOfBirth, showError: showError && dateOfBirth.isEmpty, placeholder: "19820201", isRequired: true, isFocused: _isFocused)

                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Gender")
                                        .font(.system(size: 16))
                                        .opacity(0.7)
                                    Text("*").foregroundColor(.red)
                                }
                                HStack {
                                    RadioButtonPass(text: "Female", isSelected: $gender, tag: "F", showError: showError && gender == nil)
                                    RadioButtonPass(text: "Male", isSelected: $gender, tag: "M", showError: showError && gender == nil)
                                }
                            }

                            DropdownField(title: "Country / Region", selectedValue: $countryRegion, options: countries, showError: showError && countryRegion.isEmpty, isRequired: true)

                            InputField(title: "Passport Number", text: $passportNumber, showError: showError && passportNumber.isEmpty, placeholder: "M12345678", isRequired: true, isFocused: _isFocused)

                            InputField(title: "Passport Expiration Date", text: $passportExpirationDate, showError: showError && passportExpirationDate.isEmpty, placeholder: "20301231", isRequired: true, isFocused: _isFocused)

                            InputField(title: "Passport Issue Date", text: $dateOfIssue, showError: false, placeholder: "20201231", isFocused: _isFocused)
                        }

                        HStack {
                            Button("Retry") {
                                navigateToScanPrePassView = true
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))

                            Button("Next") {
                                if validateFields() {
                                    savePassportData()
                                    sendPassportData()
                                    navigateToMyInfoView = true
                                } else {
                                    errorMessage = "Please fill in all required fields."
                                    showError = true
                                }
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
                NavigationLink(destination: MyInfoView(), isActive: $navigateToMyInfoView) {
                    EmptyView()
                }
                NavigationLink(destination: ScanPrePassView(), isActive: $navigateToScanPrePassView) {
                    EmptyView()
                }
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Incomplete Form"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func validateFields() -> Bool {
        return !dateOfBirth.isEmpty && gender != nil && !countryRegion.isEmpty && !passportNumber.isEmpty && !passportExpirationDate.isEmpty
    }

    private func savePassportData() {
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

        if let encodedData = try? JSONEncoder().encode(passportData) {
            UserDefaults.standard.set(encodedData, forKey: "SavedPassportData")
            print("Passport data saved.")
        } else {
            print("Failed to encode passport data.")
        }
    }

    private func sendPassportData() {
        guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") else {
            errorMessage = "Access token is missing."
            showError = true
            return
        }

        let requestBody: [String: Any] = [
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

        guard let url = URL(string: "http://43.203.237.202:18080/api/v1/passport") else {
            errorMessage = "Invalid URL."
            showError = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
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
                    errorMessage = "Server error."
                    showError = true
                }
                return
            }

            DispatchQueue.main.async {
                print("Passport data sent successfully.")
            }
        }.resume()
    }
}

     // MARK: - Load Passport Data from UserDefaults
     private func loadPassportData() -> [String: String]? {
         if let savedData = UserDefaults.standard.data(forKey: "SavedPassportData") {
             if let decodedData = try? JSONDecoder().decode([String: String].self, from: savedData) {
                 return decodedData
             } else {
                 print("Failed to decode passport data.")
             }
         } else {
             print("No passport data found.")
         }
         return nil
     }
 
struct InputField: View {
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



struct RadioButtonPass: View {
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

struct DropdownField: View {
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
