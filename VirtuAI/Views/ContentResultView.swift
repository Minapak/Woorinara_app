import SwiftUI
import VComponents

struct ContentResultView: View {
    @State private var koreaAddress: String = ""
    @State private var telephoneNumber: String = ""
    @State private var homeCountryAddress: String = ""
    @State private var homeCountryPhoneNumber: String = ""
    
    // 여권에서 전달된 값들
    @State private var name: String
    @State private var surname: String
    @State private var documentNumber: String
    
    @FocusState private var isFocused: Bool // Focus 상태 관리
    
    // 초기화 메서드 추가
    init(name: String = "", surname: String = "", documentNumber: String = "") {
        _name = State(initialValue: name)
        _surname = State(initialValue: surname)
        _documentNumber = State(initialValue: documentNumber)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Please provide any information that cannot be determined from the ID.")
                    .font(.body)
                    .foregroundColor(.gray)
                
                // Name
                VStack(alignment: .leading, spacing: 5) {
                    Text("Name")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#5C6366"))
                    
                    textFieldStyle("Enter Name", text: $name)
                }
                
                // Surname
                VStack(alignment: .leading, spacing: 5) {
                    Text("Surname")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#5C6366"))
                    
                    textFieldStyle("Enter Surname", text: $surname)
                }
                
                // Document Number
                VStack(alignment: .leading, spacing: 5) {
                    Text("Document Number")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#5C6366"))
                    
                    textFieldStyle("Enter Document Number", text: $documentNumber)
                }
                
                // Additional TextFields
                VStack(alignment: .leading, spacing: 5) {
                    Text("Address in Korea")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#5C6366"))
                    
                    textFieldStyle("Please enter the content.", text: $koreaAddress)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Telephone No.")
                        .font(.headline)
                    textFieldStyle("Please enter the content.", text: $telephoneNumber)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Home Country Address")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#5C6366"))
                    textFieldStyle("Please enter the content.", text: $homeCountryAddress)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Home Country Phone Number")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#5C6366"))
                    textFieldStyle("Please enter the content.", text: $homeCountryPhoneNumber)
                }
            }
            .padding()
        }
        .navigationTitle("My Information")
    }
    
    // 텍스트 필드 스타일 함수
    private func textFieldStyle(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .focused($isFocused) // 포커스 상태 추적
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isFocused || !text.wrappedValue.isEmpty ? Color(hex: "#3B8AFF") : Color(hex: "#B4BAC2"), lineWidth: 1)
            )
            .foregroundColor(text.wrappedValue.isEmpty ? Color(hex: "#5C687A") : Color(hex: "#5C687A"))
    }
}

#Preview {
    ContentResultView(name: "John", surname: "Doe", documentNumber: "12345678")
}
