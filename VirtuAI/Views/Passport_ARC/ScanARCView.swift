import SwiftUI
import VComponents

// Main view for ScanARC
struct ScanARCView: View {
    @State private var foreignRegistrationNumber: String
    @State private var dateOfBirth: String
    @State private var gender: String?
    @State private var name: String
    @State private var country: String
    @State private var residenceCategory1 = "A"
    @State private var residenceCategory2 = "1"
    
    @State private var showError = false
    @State private var errorMessage = ""  // Stores error messages
    @FocusState private var isFocused: Bool
    @State private var navigateToAFARCView = false  // Control navigation to AFARCView
    
    let countries = [
        "South Korea", "Japan", "China", "India", "Thailand", "United States", "Canada", "Germany", "France", "United Kingdom",
        "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cabo Verde", "Cambodia", "Canada", "Chad", "Chile", "China", "Colombia", "Costa Rica", "Czechia (Czech Republic)", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Egypt", "France", "Germany", "Ghana", "India", "Indonesia", "Iran", "Ireland", "Italy", "Japan", "Kazakhstan", "Kyrgyzstan", "Laos", "Malaysia", "Mongolia", "Morocco", "Myanmar (Burma)", "Nepal", "Netherlands", "New Zealand", "Nigeria", "Pakistan", "Peru", "Philippines", "Poland", "Russia", "Saudi Arabia", "Singapore", "South Africa", "Spain", "Sri Lanka", "Sweden", "Switzerland", "Taiwan", "Thailand", "Turkey", "United Kingdom", "United States", "Uzbekistan", "Vietnam"
    ]
    let residenceCategories1 = (65...90).map { String(UnicodeScalar($0)!) } // A-Z
    let residenceCategories2 = (1...9).map { String($0) }
    
    // Initialize with OCRResult data
    init(result: OCRResult) {
        // Set initial values from OCRResult data
        self._foreignRegistrationNumber = State(initialValue: result.data?.alienRegNum ?? "")
        self._dateOfBirth = State(initialValue: result.data?.dateOfBirth ?? "")
        self._gender = State(initialValue: result.data?.gender)
        self._name = State(initialValue: result.data?.name ?? "")
        self._country = State(initialValue: result.data?.nationality ?? "")
        
        // Split visa into two parts for residence categories, if available
        if let visa = result.data?.visa, visa.count >= 3 {
            let firstPart = String(visa.prefix(1))
            let secondPart = String(visa.suffix(1))
            self._residenceCategory1 = State(initialValue: firstPart)
            self._residenceCategory2 = State(initialValue: secondPart)
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
                        // ID Type
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
                        
                        // Foreign Registration Number
                                  InputField(
                                      title: "Foreign Registration Number",
                                      text: $foreignRegistrationNumber,
                                      showError: showError && foreignRegistrationNumber.isEmpty,
                                      placeholder: "Z123456789",
                                      isRequired: true
                                  )
                                  .onChange(of: foreignRegistrationNumber) { newValue in
                                      // Add '-' after 6 characters
                                      if newValue.count == 6 && !newValue.contains("-") {
                                          foreignRegistrationNumber.insert("-", at: newValue.index(newValue.startIndex, offsetBy: 6))
                                      }
                                      // Limit the text length to 14 characters (e.g., yymmdd-1234567)
                                      if newValue.count > 14 {
                                          foreignRegistrationNumber = String(newValue.prefix(14))
                                      }
                                  }
                                  Spacer()
                        
                        // Date of Birth
                        InputField(title: "Date of Birth", text: $dateOfBirth, showError: showError && dateOfBirth.isEmpty, placeholder: "19870201", isRequired: true)
                        Spacer()
                        
                        // Gender
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Gender")
                                    .font(.system(size: 16))
                                    .opacity(0.7)
                                Text("*").foregroundColor(.red)
                            }
                            HStack {
                                RadioButtonPass(text: "Female", isSelected: $gender, tag: "Female", showError: showError && gender == nil)
                                RadioButtonPass(text: "Male", isSelected: $gender, tag: "Male", showError: showError && gender == nil)
                            }
                        }
                        Spacer()
                        
                        // Name
                        InputField(title: "Name", text: $name, showError: showError && name.isEmpty, placeholder: "TANAKA", isRequired: true)
                        Spacer()
                        
                        // Country
                        DropdownField(title: "Country", selectedValue: $country, options: countries, showError: showError && country.isEmpty, isRequired: true)
                        Spacer()
                        
                        // Visa (Residence Category)
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Visa")
                                    .font(.system(size: 16))
                                    .opacity(0.7)
                                Text("*").foregroundColor(.red)
                            }
                            HStack {
                                DropdownField(title: "Category", selectedValue: $residenceCategory1, options: residenceCategories1)
                                DropdownField(title: "Type", selectedValue: $residenceCategory2, options: residenceCategories2)
                            }
                        }
                }
                    
                    Spacer()
                    
                    // Buttons
                    HStack {
                        Button("Retry") {
                            resetFields()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
                        
                        Button("Done") {
                            if validateFields() {
                                // Successfully validated fields, navigate to AFARCView
                                navigateToAFARCView = true
                            } else {
                                showError = true
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    // NavigationLink to AFARCView, triggered by navigateToAFARCView
                    NavigationLink(destination: AFARCView(data: buildData()), isActive: $navigateToAFARCView) {
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden(false)
            .alert(isPresented: $showError) {
                Alert(title: Text("Incomplete Form"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
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
    
    // Function to build data dictionary for AFARCView
    private func buildData() -> [String: String] {
        return [
            "alienRegNum": foreignRegistrationNumber,
            "dateOfBirth": dateOfBirth,
            "gender": gender ?? "",
            "name": name,
            "nationality": country,
            "residenceCategory1": residenceCategory1,
            "residenceCategory2": residenceCategory2
        ]
    }
}
