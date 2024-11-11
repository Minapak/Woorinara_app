import SwiftUI
import VComponents

struct ScanARCView: View {
    @State private var foreignRegistrationNumber: String
    @State private var dateOfBirth: String
    @State private var gender: String?
    @State private var name: String
    @State private var country: String
    @State private var residenceCategory1 = "A"
    @State private var residenceCategory2 = "1"
    
    @State private var showError = false
    @State private var errorMessage = ""  // 에러 메시지를 저장하는 변수
    @FocusState private var isFocused: Bool
    @State private var navigateToAFCenterView = false
    
    let countries = ["South Korea", "Japan", "China", "India", "Thailand", "United States", "Canada", "Germany", "France", "United Kingdom"]
    let residenceCategories1 = (65...90).map { String(UnicodeScalar($0)!) }
    let residenceCategories2 = (1...9).map { String($0) }
    
    // Initializer with OCRResult data
    init(result: OCRResult) {
        // Initializing each field with data from OCRResult
        self._foreignRegistrationNumber = State(initialValue: result.data?.documentNumber ?? "")
        self._dateOfBirth = State(initialValue: result.data?.dateOfBirth ?? "")
        self._gender = State(initialValue: result.data?.gender)
        self._name = State(initialValue: "\(result.data?.givenName ?? "") \(result.data?.surName ?? "")")
        self._country = State(initialValue: result.data?.nationality ?? "")
        
        // Initial log for fields
        print("Initialized foreignRegistrationNumber: \(result.data?.documentNumber ?? "")")
        print("Initialized dateOfBirth: \(result.data?.dateOfBirth ?? "")")
        print("Initialized gender: \(result.data?.gender ?? "nil")")
        print("Initialized name: \(result.data?.givenName ?? "") \(result.data?.surName ?? "")")
        print("Initialized country: \(result.data?.nationality ?? "")")
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
                        // Type of ID
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
                        InputField(title: "Foreign registration number", text: $foreignRegistrationNumber, showError: showError && foreignRegistrationNumber.isEmpty, placeholder: "Please enter the content", isRequired: true)
                        Spacer()
                        
                        // Date of Birth
                        InputField(title: "Date of Birth", text: $dateOfBirth, showError: showError && dateOfBirth.isEmpty, placeholder: "Please enter the content", isRequired: true)
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
                        InputField(title: "Name", text: $name, showError: showError && name.isEmpty, placeholder: "Please enter the content", isRequired: true)
                        Spacer()
                        
                        // Country
                        DropdownField(title: "Country", selectedValue: $country, options: countries, showError: showError && country.isEmpty, isRequired: true)
                        Spacer()
                        
                        // 체류자격
                        VStack(alignment: .leading) {
                            HStack {
                                Text("체류자격")
                                    .font(.system(size: 16))
                                    .opacity(0.7)
                                Text("*").foregroundColor(.red)
                            }
                            HStack {
                                DropdownField(title: "A", selectedValue: $residenceCategory1, options: residenceCategories1)
                                DropdownField(title: "1", selectedValue: $residenceCategory2, options: residenceCategories2)
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
                                // 성공 처리
                                print("✅ All fields validated successfully.")
                            } else {
                                showError = true
                                print("❗ Validation failed.")
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
            .navigationTitle("")
            .navigationBarBackButtonHidden(false)
            .alert(isPresented: $showError) {
                Alert(title: Text("Incomplete Form"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func validateFields() -> Bool {
        print("Validating fields...")
        print("Foreign Registration Number: \(foreignRegistrationNumber)")
        print("Date of Birth: \(dateOfBirth)")
        print("Gender: \(gender ?? "nil")")
        print("Name: \(name)")
        print("Country: \(country)")
        print("Residence Category 1: \(residenceCategory1)")
        print("Residence Category 2: \(residenceCategory2)")
        
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
        print("Fields reset.")
    }
}
