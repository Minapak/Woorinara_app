import SwiftUI
import VComponents

struct ScanPassView: View {
    @State private var surname: String
    @State private var givenName: String
    @State private var middleName: String
    @State private var dateOfBirth: String
    @State private var gender: String? // "M" 또는 "F" 값을 설정
    @State private var countryRegion: String
    @State private var passportNumber: String
    @State private var passportExpirationDate: String
    @State private var passportNationality: String
    @State private var showError = false
    @FocusState private var isFocused: Bool
    @State private var navigateToAFCenterView = false
    
    let countries = ["South Korea", "Japan", "China", "India", "Thailand", "United States", "Canada", "Germany", "France", "United Kingdom"]
    
    init(result: OCRPassResult) {
        self._surname = State(initialValue: result.data?.surName ?? "")
        self._givenName = State(initialValue: result.data?.givenName ?? "")
        self._middleName = State(initialValue: result.data?.middleName ?? "")
        self._dateOfBirth = State(initialValue: result.data?.dateOfBirth ?? "")
        self._gender = State(initialValue: result.data?.gender) // 초기 gender 값 설정
        self._countryRegion = State(initialValue: result.data?.issueCountry ?? "")
        self._passportNumber = State(initialValue: result.data?.documentNumber ?? "")
        self._passportExpirationDate = State(initialValue: result.data?.dateOfExpiry ?? "")
        self._passportNationality = State(initialValue: result.data?.nationality ?? "")
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
                        // ID 종류
                        Text("Type of ID")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .opacity(0.7)
                        
                        TextField("Passport", text: .constant("Passport"))
                            .disabled(true)
                            .padding()
                            .background(Color.gray)
                            .opacity(0.7)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            .foregroundColor(.gray)
                            .opacity(0.5)
                        Spacer()
                        HStack(spacing: 3) {
                            // 성, 이름, 중간 이름
                            InputField(title: "Surname", text: $surname, isFocused: _isFocused)
                            InputField(title: "Given name", text: $givenName, isFocused: _isFocused)
                            InputField(title: "Middle name", text: $middleName, showError: showError && middleName.isEmpty, placeholder: "Required", isRequired: true, isFocused: _isFocused)
                        }
                        Spacer()
                        // 생년월일
                        InputField(title: "Date of Birth", text: $dateOfBirth, showError: showError && dateOfBirth.isEmpty, placeholder: "yyyyMMdd", isRequired: true, isFocused: _isFocused)
                        Spacer()
                        Spacer()
                        // 성별 선택
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
                        Spacer()
                        Spacer()
                        // 국가 / 지역
                        DropdownField(title: "Country / Region", selectedValue: $countryRegion, options: countries, showError: showError && countryRegion.isEmpty, isRequired: true)
                        Spacer()
                        // 여권 번호
                        InputField(title: "Passport Number", text: $passportNumber, showError: showError && passportNumber.isEmpty, placeholder: "Required", isRequired: true, isFocused: _isFocused)
                        Spacer()
                        // 여권 만료일
                        InputField(title: "Passport Expiration Date", text: $passportExpirationDate, showError: showError && passportExpirationDate.isEmpty, placeholder: "yyyyMMdd", isRequired: true, isFocused: _isFocused)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button("Retry") {
                            resetFields()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 2))
                        
                        Button("Done") {
                            if validateFields() {
                                navigateToAFCenterView = true
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
                    
                    // NavigationLink를 사용해 AFCenterView로 데이터 전달 및 화면 이동
                    NavigationLink(destination: AFCenterView(passportData: buildPassportData()), isActive: $navigateToAFCenterView) {
                        EmptyView() // NavigationLink는 빈 뷰로
                    }
                }
                .padding()
            }
            .navigationTitle("")
            .navigationBarBackButtonHidden(false)
        }
    }
    
    private func validateFields() -> Bool {
        return !middleName.isEmpty && !dateOfBirth.isEmpty && gender != nil && !countryRegion.isEmpty && !passportNumber.isEmpty && !passportExpirationDate.isEmpty
    }
    
    private func resetFields() {
        surname = ""
        givenName = ""
        middleName = ""
        dateOfBirth = ""
        gender = nil
        countryRegion = ""
        passportNumber = ""
        passportExpirationDate = ""
        showError = false
    }
    
    private func buildPassportData() -> [String: String] {
        return [
            "surName": surname,
            "givenName": givenName,
            "middleName": middleName,
            "dateOfBirth": dateOfBirth,
            "gender": gender ?? "",
            "countryRegion": countryRegion,
            "passportNumber": passportNumber,
            "passportExpirationDate": passportExpirationDate,
            "nationality": passportNationality
        ]
    }
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
