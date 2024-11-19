import SwiftUI
import VComponents
import SwiftKeychainWrapper

// Main view for ScanARC
struct ScanARCView: View {
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
     
     @State private var showError = false
     @State private var errorMessage = ""
     @State private var isLoading = false
    @State private var residenceCategory1 = "A"
    @State private var residenceCategory2 = "1"
    
    @FocusState private var isFocused: Bool
    @State private var navigateToAFARCView = false
    @State private var navigateToPassportView = false
    @State private var showAlertInfo = false
    @State private var navigateToScanPreARCView = false // Navigation flag for ScanPrePassView
    @State private var showAlertARC = false
     @State private var navigateToScanPrePassView = false
     @State private var navigateToMyInfoView = false


    @AppStorage("arcDataSaved") private var arcDataSaved: Bool = false
    @AppStorage("passportDataSaved") private var passportDataSaved: Bool = false

    let endpoint = "http://43.203.237.202:18080/api/v1/identity"
    let accessToken = KeychainWrapper.standard.string(forKey: "accessToken")
    

    let countries = [
        "South Korea", "Japan", "China", "India", "Thailand", "United States", "Canada", "Germany", "France", "United Kingdom",
        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cabo Verde", "Cambodia", "Canada", "Chad", "Chile", "China", "Colombia", "Costa Rica", "Czechia (Czech Republic)", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Egypt", "France", "Germany", "Ghana", "India", "Indonesia", "Iran", "Ireland", "Italy", "Japan", "Kazakhstan", "Kyrgyzstan", "Laos", "Malaysia", "Mongolia", "Morocco", "Myanmar (Burma)", "Nepal", "Netherlands", "New Zealand", "Nigeria", "Pakistan", "Peru", "Philippines", "Poland", "Russia", "Saudi Arabia", "Singapore", "South Africa", "Spain", "Sri Lanka", "Sweden", "Switzerland", "Taiwan", "Thailand", "Turkey", "United Kingdom", "United States", "Uzbekistan", "Vietnam"
    ]
    let residenceCategories1 = (65...90).map { String(UnicodeScalar($0)!) } // A-Z
    let residenceCategories2 = (1...9).map { String($0) }
    
    init(result: OCRResult? = nil) {
        // If OCRResult is provided, initialize fields with its data
        if let result = result {
            self._foreignRegistrationNumber = State(initialValue: result.data?.alienRegNum ?? "")
            self._dateOfBirth = State(initialValue: result.data?.dateOfBirth ?? "")
            self._gender = State(initialValue: result.data?.gender)
            self._name = State(initialValue: result.data?.name ?? "")
            self._country = State(initialValue: result.data?.nationality ?? "")
            
            if let visa = result.data?.visa, visa.count >= 3 {
                let firstPart = String(visa.prefix(1))
                let secondPart = String(visa.suffix(1))
                self._residenceCategory1 = State(initialValue: firstPart)
                self._residenceCategory2 = State(initialValue: secondPart)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Please check your ID information")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("If the recognized content is different from the real thing, it will be limited to use")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading) {
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
                        
                        InputARCField(
                            title: "Foreign Registration Number",
                            text: $foreignRegistrationNumber,
                            showError: showError && foreignRegistrationNumber.isEmpty,
                            placeholder: "Z123456789",
                            isRequired: true
                        )
                        .onChange(of: foreignRegistrationNumber) { newValue in
                            if newValue.count == 6 && !newValue.contains("-") {
                                foreignRegistrationNumber.insert("-", at: newValue.index(newValue.startIndex, offsetBy: 6))
                            }
                            if newValue.count > 14 {
                                foreignRegistrationNumber = String(newValue.prefix(14))
                            }
                        }
                        Spacer()
                        
                        InputARCField(title: "Date of Birth", text: $dateOfBirth, showError: showError && dateOfBirth.isEmpty, placeholder: "19870201", isRequired: true)
                        Spacer()
                        Spacer()
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
                        Spacer()
                        InputARCField(title: "Name", text: $name, showError: showError && name.isEmpty, placeholder: "TANAKA", isRequired: true)
                        Spacer()
                        
                        DropdownARCField(title: "Country", selectedValue: $country, options: countries, showError: showError && country.isEmpty, isRequired: true)
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Visa")
                                    .font(.system(size: 16))
                                    .opacity(0.7)
                                Text("*").foregroundColor(.red)
                            }
                            HStack {
                                // Dropdown for Residence Category 1
                                DropdownARCField(
                                    title: "Category",
                                    selectedValue: $residenceCategory1,
                                    options: residenceCategories1
                                )
                                Text("-") // Static separator
                                    .font(.system(size: 16))
                                    .opacity(0.7)
                                // Dropdown for Residence Category 2
                                DropdownARCField(
                                    title: "Type",
                                    selectedValue: $residenceCategory2,
                                    options: residenceCategories2
                                )
                            }
                            .onChange(of: residenceCategory1) { _ in
                                updateVisaType()
                            }
                            .onChange(of: residenceCategory2) { _ in
                                updateVisaType()
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button("Retry") {
                            navigateToScanPreARCView = true // Navigate to ScanPrePassView
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
                        
                        Button("Next") {
                            if foreignRegistrationNumber.isEmpty {
                                              // showAlertInfo = true
                                           }
                            if validateFields() {
                                saveARCData()
                                navigateToPassportView = true
                            } else {
                                showError = true
                                errorMessage = "Please fill in all required fields."
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: AFARCView(data: buildData()), isActive: $navigateToAFARCView) {
                        EmptyView()
                    }
                    NavigationLink(destination: PassportInfoView(), isActive: $navigateToPassportView) {
                                       EmptyView()
                                   }
                    
                    NavigationLink(destination: ScanPreARCView(), isActive: $navigateToScanPreARCView) {
                                      EmptyView()
                                  }
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden(false)
            .onAppear {
                            fetchData()
                        }
            .overlay(
                      Group {
                          if showAlertInfo {
                              Color.black.opacity(0.1).edgesIgnoringSafeArea(.all)
                             // AlertInfoView(isPresented: $showAlertInfo)
                          }
                      }
                  )
        }
    }
    
    // Function to update visaType
    private func updateVisaType() {
        visaType = "\(residenceCategory1)-\(residenceCategory2)"
        
    }
    private func fetchData() {
         guard let url = URL(string: endpoint),
               let token = accessToken else {
             return
         }

         var request = URLRequest(url: url)
         request.httpMethod = "GET"
         request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

         isLoading = true

         URLSession.shared.dataTask(with: request) { data, response, error in
             DispatchQueue.main.async {
                 isLoading = false
             }

             if let error = error {
                 print("Error: \(error.localizedDescription)")
                 return
             }

             guard let data = data else {
                 print("No data received.")
                 return
             }

             do {
                 let decodedData = try JSONDecoder().decode([String: String].self, from: data)
                 DispatchQueue.main.async {
                     self.foreignRegistrationNumber = decodedData["foreignRegistrationNumber"] ?? ""
                     self.dateOfBirth = decodedData["birthDate"] ?? ""
                     self.gender = decodedData["gender"]
                     self.name = decodedData["name"] ?? ""
                     self.country = decodedData["nationality"] ?? ""
                     self.residenceCategory1 = decodedData["residenceCategory1"] ?? "A"
                     self.residenceCategory2 = decodedData["residenceCategory2"] ?? "1"
                 }
             } catch {
                 print("Failed to decode JSON: \(error.localizedDescription)")
             }
         }.resume()
     }

    // Save ARC Data to UserDefaults
    private func saveARCData() {
        let arcData: [String: String] = [
            "foreignRegistrationNumber": foreignRegistrationNumber,
            "birthDate": dateOfBirth,
            "gender": gender ?? "",
            "name": name,
            "nationality": country,
            "residenceCategory1": residenceCategory1,
            "residenceCategory2": residenceCategory2,
            "region": region,
            "residenceStatus": residenceStatus,
            "visaType": visaType,
            "permitDate": permitDate,
            "expirationDate": expirationDate,
            "issueCity": issueCity,
            "reportDate": reportDate,
            "residence": residence
        ]
        
        do {
            let encodedData = try JSONEncoder().encode(arcData)
            UserDefaults.standard.set(encodedData, forKey: "SavedARCData")
            print("ARC data saved successfully.")
        } catch {
            print("Failed to encode ARC data: \(error.localizedDescription)")
        }
    }

    // Load ARC Data from UserDefaults
    private func loadARCData() -> [String: String]? {
        guard let savedData = UserDefaults.standard.data(forKey: "SavedARCData") else {
            print("No ARC data found in UserDefaults.")
            return nil
        }
        
        do {
            let arcData = try JSONDecoder().decode([String: String].self, from: savedData)
            print("ARC data loaded successfully.")
            return arcData
        } catch {
            print("Failed to decode ARC data: \(error.localizedDescription)")
            return nil
        }
    }

    // Function to build data dictionary for API submission or navigation
    private func buildData() -> [String: String] {
        return [
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
    }

    private func validateFields() -> Bool {
        return !foreignRegistrationNumber.isEmpty && !dateOfBirth.isEmpty && gender != nil && !name.isEmpty && !country.isEmpty
    }
    
    private func resetFields() {
        foreignRegistrationNumber = ""
        dateOfBirth = ""
        gender = nil
        name = ""
        country = ""
        residenceCategory1 = "A"
        residenceCategory2 = "1"
        showError = false
    }

    private func sendData() {
        guard let accessToken = accessToken else {
            errorMessage = "Access token not available."
            showError = true
            return
        }
        
        let requestBody: [String: Any] = [
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
        
        guard let url = URL(string: endpoint) else {
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
// InputField 컴포넌트 수정
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
                // Placeholder
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
                // Text 입력 필드
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

// DropdownField 컴포넌트 수정
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
                // 라디오 버튼 아이콘
                Image(systemName: isSelected == tag ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(showError && isSelected == nil ? .red : .blue)
                    .font(.system(size: 18))

                // 텍스트
                Text(text)
                    .foregroundColor(.black)
                    .font(.system(size: 16))
                    .opacity(0.7)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle()) // 기본 버튼 스타일 제거
    }
}
