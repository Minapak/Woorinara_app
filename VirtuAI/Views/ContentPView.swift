import RSFUIPassportScanner
import SwiftUI

struct ContentPView: View {
    @State private var result: PassportInfo? = nil
    @State private var presentScanner = false

    var body: some View {
        if #available(iOS 17.0, *) {
            VStack {
                if let result = result {
                    VStack(content: {
                        LabeledContent("Type", value: result.documentType.rawValue)
                        LabeledContent("Country", value: result.countryCode)
                        LabeledContent("Name", value: result.givenNames)
                        LabeledContent("Surname", value: result.surnames)
                        
                        if let birthdate = result.birthdate {
                            LabeledContent("Birthdate") {
                                Text(birthdate, style: .date)
                            }
                        }
                        if let documentNumber = result.documentNumber {
                            LabeledContent("Document Number", value: documentNumber)
                        }
                        
                        LabeledContent("Nationality", value: result.nationalityCountryCode)
                        
                        LabeledContent("Sex", value: result.sex.rawValue)
                        
                        if let idNumber = result.identificationNumber {
                            LabeledContent("ID Number", value: idNumber)
                        }
                        if let expiryDate = result.expiryDate {
                            LabeledContent("Expiry Date") {
                                Text(expiryDate, style: .date)
                            }
                        }
                    })
                    .onAppear {
                        // 여기에서 로그를 출력합니다.
                        print("Document Type: \(result.documentType.rawValue)")
                        print("Country Code: \(result.countryCode)")
                        print("Given Names: \(result.givenNames)")
                        print("Surnames: \(result.surnames)")
                        if let birthdate = result.birthdate {
                            print("Birthdate: \(birthdate)")
                        }
                        if let documentNumber = result.documentNumber {
                            print("Document Number: \(documentNumber)")
                        }
                        print("Nationality Country Code: \(result.nationalityCountryCode)")
                        print("Sex: \(result.sex.rawValue)")
                        if let idNumber = result.identificationNumber {
                            print("ID Number: \(idNumber)")
                        }
                        if let expiryDate = result.expiryDate {
                            print("Expiry Date: \(expiryDate)")
                        }
                    }
                }

                Button(action: {
                    result = nil
                    presentScanner = true
                    print("Open Scanner Button Pressed")
                }, label: {
                    Text("Open Scanner")
                })
            }
            .padding()
            .fullScreenCover(isPresented: $presentScanner, content: {
                PassportScannerView(result: $result)
            })
            .onChange(of: result) { newValue in
                if let result = newValue {
                    print("Result Updated: \(result)")
                    presentScanner = false
                } else {
                    print("No result found")
                }
            }
        } else {
            // Fallback for iOS versions below 17.0
        }
    }
}

#Preview {
    ContentPView()
}
