
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
    @AppStorage("arcDataSaved") private var arcDataSaved: Bool = false
    @AppStorage("passportDataSaved") private var passportDataSaved: Bool = false
    
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
    // Body
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

        performAPIRequest(endpoint: APIEndpoint.base, method: "POST", data: identityData) { success in
            if success {
                fetchData()
            }
        }
    }

    private func updateARCIdentity() {
        guard let accessToken = accessToken else {
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

        performAPIRequest(endpoint: APIEndpoint.update, method: "POST", data: identityData) { success in
            if success {
                fetchData()
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

        isLoading = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(ARCIdentityData.self, from: data)
                DispatchQueue.main.async {
                    self.foreignRegistrationNumber = decodedData.foreignRegistrationNumber
                    self.dateOfBirth = decodedData.birthDate
                    self.gender = decodedData.gender
                    self.name = decodedData.name
                    self.country = decodedData.nationality
                    self.region = decodedData.region
                    self.residenceStatus = decodedData.residenceStatus
                    self.visaType = decodedData.visaType
                    self.permitDate = decodedData.permitDate
                    self.expirationDate = decodedData.expirationDate
                    self.issueCity = decodedData.issueCity
                    self.reportDate = decodedData.reportDate
                    self.residence = decodedData.residence
                }
            } catch {
                print("Decoding error: \(error)")
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
        } catch {
            print("Encoding error: \(error)")
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }

            DispatchQueue.main.async {
                completion(true)
            }
        }.resume()
    }

    private func handleNextButton() {
        if validateFields() {
            if arcDataSaved {
                updateARCIdentity()
            } else {
                createARCIdentity()
            }
            
            saveARCData()
            navigateToPassportView = true
        } else {
            showError = true
            errorMessage = "Please fill in all required fields."
        }
    }

    private func validateFields() -> Bool {
        return !foreignRegistrationNumber.isEmpty &&
               !dateOfBirth.isEmpty &&
               gender != nil &&
               !name.isEmpty &&
               !country.isEmpty
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
           
           do {
               let encodedData = try JSONEncoder().encode(arcData)
               UserDefaults.standard.set(encodedData, forKey: "SavedARCData")
               arcDataSaved = true
               print("ARC data saved successfully")
           } catch {
               print("Failed to encode ARC data: \(error.localizedDescription)")
           }
       }

       private func loadARCData() -> [String: String]? {
           guard let savedData = UserDefaults.standard.data(forKey: "SavedARCData") else {
               print("No ARC data found in UserDefaults")
               return nil
           }
           
           do {
               let arcData = try JSONDecoder().decode([String: String].self, from: savedData)
               print("ARC data loaded successfully")
               return arcData
           } catch {
               print("Failed to decode ARC data: \(error.localizedDescription)")
               return nil
           }
       }

       private func resetFields() {
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
