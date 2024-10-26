import RSFUIPassportScanner
import SwiftUI

struct ContentPView1: View {
    @State private var result: PassportInfo? = nil
    @State private var presentScanner = false
    @State private var isContentTFViewPresented = false

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
                        // 여권 정보 출력 (디버그 용)
                        print("Document Type: \(result.documentType.rawValue)")
                        print("Country Code: \(result.countryCode)")
                        print("Given Names: \(result.givenNames)")
                        print("Surnames: \(result.surnames)")
                    }
                }

                Button(action: {
                    result = nil
                    presentScanner = true
                    print("Open Scanner Button Pressed")
                }, label: {
                    Text("Open Scanner")
                })

                // "Next" 버튼으로 ContentTFView로 이동
                Button(action: {
                    isContentTFViewPresented = true
                }, label: {
                    Text("Next to Fill Form")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                })
            }
            .padding()
            .fullScreenCover(isPresented: $presentScanner, content: {
                PassportScannerView(result: $result)
            })
            .sheet(isPresented: $isContentTFViewPresented) {
                if let result = result {
                    ContentResultView(
                        name: result.givenNames,
                        surname: result.surnames,
                        documentNumber: result.documentNumber ?? ""
                    )
                } else {
                    ContentResultView()
                }
            }
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
    ContentPView1()
}
