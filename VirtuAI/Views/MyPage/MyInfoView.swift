import SwiftUI
import AVFoundation
import VComponents
import SwiftKeychainWrapper

// MyInfo 데이터 모델
struct MyInfoData: Codable {
    var phoneNumber: String
    var annualIncome: Int?
    var workplaceName: String
    var workplaceRegistrationNumber: String
    var workplacePhoneNumber: String
    var futureWorkplaceName: String
    var futureWorkplaceRegistrationNumber: String
    var futureWorkplacePhoneNumber: String
    var profileImageUrl: String?
    var signatureUrl: String?
    var koreaAddress: String
    var telephoneNumber: String
    var homelandAddress: String
    var homelandPhoneNumber: String
    var schoolStatus: String
    var schoolName: String
    var schoolPhoneNumber: String
    var schoolType: String
    var originalWorkplaceName: String
    var originalWorkplaceRegistrationNumber: String
    var originalWorkplacePhoneNumber: String
    var incomeAmount: String
    var job: String
    var refundAccountNumber: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields with default empty string if missing
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber) ?? ""
        workplaceName = try container.decodeIfPresent(String.self, forKey: .workplaceName) ?? ""
        workplaceRegistrationNumber = try container.decodeIfPresent(String.self, forKey: .workplaceRegistrationNumber) ?? ""
        workplacePhoneNumber = try container.decodeIfPresent(String.self, forKey: .workplacePhoneNumber) ?? ""
        futureWorkplaceName = try container.decodeIfPresent(String.self, forKey: .futureWorkplaceName) ?? ""
        futureWorkplaceRegistrationNumber = try container.decodeIfPresent(String.self, forKey: .futureWorkplaceRegistrationNumber) ?? ""
        futureWorkplacePhoneNumber = try container.decodeIfPresent(String.self, forKey: .futureWorkplacePhoneNumber) ?? ""
        koreaAddress = try container.decodeIfPresent(String.self, forKey: .koreaAddress) ?? ""
        telephoneNumber = try container.decodeIfPresent(String.self, forKey: .telephoneNumber) ?? ""
        homelandAddress = try container.decodeIfPresent(String.self, forKey: .homelandAddress) ?? ""
        homelandPhoneNumber = try container.decodeIfPresent(String.self, forKey: .homelandPhoneNumber) ?? ""
        schoolStatus = try container.decodeIfPresent(String.self, forKey: .schoolStatus) ?? ""
        schoolName = try container.decodeIfPresent(String.self, forKey: .schoolName) ?? ""
        schoolPhoneNumber = try container.decodeIfPresent(String.self, forKey: .schoolPhoneNumber) ?? ""
        schoolType = try container.decodeIfPresent(String.self, forKey: .schoolType) ?? ""
        originalWorkplaceName = try container.decodeIfPresent(String.self, forKey: .originalWorkplaceName) ?? ""
        originalWorkplaceRegistrationNumber = try container.decodeIfPresent(String.self, forKey: .originalWorkplaceRegistrationNumber) ?? ""
        originalWorkplacePhoneNumber = try container.decodeIfPresent(String.self, forKey: .originalWorkplacePhoneNumber) ?? ""
        incomeAmount = try container.decodeIfPresent(String.self, forKey: .incomeAmount) ?? ""
        job = try container.decodeIfPresent(String.self, forKey: .job) ?? ""
        refundAccountNumber = try container.decodeIfPresent(String.self, forKey: .refundAccountNumber) ?? ""
        
        // Optional fields
        annualIncome = try container.decodeIfPresent(Int.self, forKey: .annualIncome)
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        signatureUrl = try container.decodeIfPresent(String.self, forKey: .signatureUrl)
    }
    
    // Dictionary initializer for convenience
    init(dictionary: [String: Any]) {
        self.phoneNumber = dictionary["phoneNumber"] as? String ?? ""
        self.annualIncome = dictionary["annualIncome"] as? Int
        self.workplaceName = dictionary["workplaceName"] as? String ?? ""
        self.workplaceRegistrationNumber = dictionary["workplaceRegistrationNumber"] as? String ?? ""
        self.workplacePhoneNumber = dictionary["workplacePhoneNumber"] as? String ?? ""
        self.futureWorkplaceName = dictionary["futureWorkplaceName"] as? String ?? ""
        self.futureWorkplaceRegistrationNumber = dictionary["futureWorkplaceRegistrationNumber"] as? String ?? ""
        self.futureWorkplacePhoneNumber = dictionary["futureWorkplacePhoneNumber"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
        self.signatureUrl = dictionary["signatureUrl"] as? String
        self.koreaAddress = dictionary["koreaAddress"] as? String ?? ""
        self.telephoneNumber = dictionary["telephoneNumber"] as? String ?? ""
        self.homelandAddress = dictionary["homelandAddress"] as? String ?? ""
        self.homelandPhoneNumber = dictionary["homelandPhoneNumber"] as? String ?? ""
        self.schoolStatus = dictionary["schoolStatus"] as? String ?? ""
        self.schoolName = dictionary["schoolName"] as? String ?? ""
        self.schoolPhoneNumber = dictionary["schoolPhoneNumber"] as? String ?? ""
        self.schoolType = dictionary["schoolType"] as? String ?? ""
        self.originalWorkplaceName = dictionary["originalWorkplaceName"] as? String ?? ""
        self.originalWorkplaceRegistrationNumber = dictionary["originalWorkplaceRegistrationNumber"] as? String ?? ""
        self.originalWorkplacePhoneNumber = dictionary["originalWorkplacePhoneNumber"] as? String ?? ""
        self.incomeAmount = dictionary["incomeAmount"] as? String ?? ""
        self.job = dictionary["job"] as? String ?? ""
        self.refundAccountNumber = dictionary["refundAccountNumber"] as? String ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case phoneNumber
        case annualIncome
        case workplaceName
        case workplaceRegistrationNumber
        case workplacePhoneNumber
        case futureWorkplaceName
        case futureWorkplaceRegistrationNumber
        case futureWorkplacePhoneNumber
        case profileImageUrl
        case signatureUrl
        case koreaAddress
        case telephoneNumber
        case homelandAddress
        case homelandPhoneNumber
        case schoolStatus
        case schoolName
        case schoolPhoneNumber
        case schoolType
        case originalWorkplaceName
        case originalWorkplaceRegistrationNumber
        case originalWorkplacePhoneNumber
        case incomeAmount
        case job
        case refundAccountNumber
    }
}

struct MyInfoView: View {
    // MARK: - Properties
    @AppStorage("myInfoDataSaved") private var myInfoDataSaved: Bool = false {
        didSet {
            print("\n📢 myInfoDataSaved changed from \(oldValue) to \(myInfoDataSaved)")
        }
    }
    @AppStorage(Constants.isFirstLogin) private var isFirstLogin = true
    // State Properties
    @State private var koreaAddress: String = ""
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
    @State private var incomeAmount: Int = 0
    @State private var job: String = ""
    @State private var refundAccountNumber: String = ""
    @State private var signatureImage: UIImage? = nil
    @State private var showSignaturePad = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showContentView = false
    @State private var isLoading = false
    @State private var profileImageUrl: String? = nil
    @State private var signatureUrl: String? = nil
    @State private var errorMessage: String = ""
    // Update API endpoint
    let endpoint = "http://43.203.237.202:18080/api/v1/members/details/update"
    @State private var currentUsername: String = KeychainWrapper.standard.string(forKey: "username") ?? ""
      @State private var ocrUserId: String = ""
    @AppStorage("SavedarcData") private var savedARCData: Data?
    @AppStorage("SavedpassportData") private var savedpassportData: Data?
    @AppStorage("SavedmyInfoData") private var savedMyInfoData: Data?
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Information")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Please provide any information that cannot be determined from the ID.")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading) {
                        SectionInfoView(
                            title: "Address in Korea",
                            text: $koreaAddress,
                            placeholder: "Seoul Special City",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "Telephone No.",
                            text: $telephoneNumber,
                            placeholder: "02-1234-5677",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "Cellphone No.",
                            text: $phoneNumber,
                            placeholder: "010-1234-5678",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "Home Country Address",
                            text: $homelandAddress,
                            placeholder: "5-2-1 Ginza, Chuo-ku, Tokyo, 170-3923",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "Home Country Phone Number",
                            text: $homelandPhoneNumber,
                            placeholder: "06-1234-1234",
                            isRequired: true
                        )
                        DropdownInfoField(
                            title: "Enrollment Status",
                            selectedValue: $schoolStatus,
                            options: ["NonSchool", "Elementary", "Middle", "High"],
                            placeholder: "High School",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "School Name",
                            text: $schoolName,
                            placeholder: "Fafa School",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "School Phone Number",
                            text: $schoolPhoneNumber,
                            placeholder: "06-1234-1234",
                            isRequired: true
                        )
                        DropdownInfoField(
                            title: "Type of School",
                            selectedValue: $schoolType,
                            options: ["Accredited", "NonAccredited", "Alternative"],
                            placeholder: "Unaccredited by the Office of..",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "Previous Employer Name",
                            text: $originalWorkplaceName,
                            placeholder: "Fafa Inc",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "Previous Employer Business Registration Number",
                            text: $originalWorkplaceRegistrationNumber,
                            placeholder: "123456789",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "Previous Employer Phone Number",
                            text: $originalWorkplacePhoneNumber,
                            placeholder: "02-1234-9876",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "Prospective Employer Name",
                            text: $futureWorkplaceName,
                            placeholder: "Enter employer name",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "Prospective Employer Phone Number",
                            text: $futureWorkplacePhoneNumber,
                            placeholder: "Enter phone number",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "Annual Income",
                            text: Binding(
                                get: { String(incomeAmount) },
                                set: { incomeAmount = Int($0) ?? 0 }
                            ),
                            placeholder: "5000 ten thousand won",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "Occupation",
                            text: $job,
                            placeholder: "Enter your occupation",
                            isRequired: true
                        )
                        SectionInfoView(
                            title: "Refund Account Number",
                            text: $refundAccountNumber,
                            placeholder: "KOOKMIN, 123456-12-34566",
                            isRequired: true
                        )
                        
                        VStack(alignment: .leading) {
                            Text("Enter Signature")
                                .font(.headline)
                            if let image = signatureImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(height: 100)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(16)
                            } else {
                                Button(action: { showSignaturePad = true }) {
                                    VStack {
                                        Image(systemName: "plus")
                                            .font(.largeTitle)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 100)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                }
                            }
                        }
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
                            handleDoneButton()
                            isFirstLogin = false}
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .sheet(isPresented: $showSignaturePad) {
                SignatureMyInfoPadView(signatureImage: $signatureImage) { savedImage in
                    print("📝 Signature captured")
                    self.signatureImage = savedImage
                    self.saveImageToAlbum(savedImage)
                }
            }
            .onAppear {
                print("\n📱 MyInfoView appeared")
                verifyUserAndLoadData()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Notification"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $showContentView) {
                ContentView()
            }
        }
    }
    private func handleDoneButton() {
        if validateFields() {
            print("✅ Fields validation passed")
            
            saveData()
            if UserDefaults.standard.data(forKey: "SavedmyInfoData") != nil {
                print("📤 Updating existing MyInfo data...")
                updateMyInfo()
            } else {
                print("📥 Creating new MyInfo data...")
                createMyInfo()
            }
            
            let myInfoData = MyInfoData(dictionary: [
                "phoneNumber": phoneNumber,
                "annualIncome": incomeAmount,
                "workplaceName": originalWorkplaceName,
                "workplaceRegistrationNumber": originalWorkplaceRegistrationNumber,
                "workplacePhoneNumber": originalWorkplacePhoneNumber,
                "futureWorkplaceName": futureWorkplaceName,
                "futureWorkplaceRegistrationNumber": originalWorkplaceRegistrationNumber,
                "futureWorkplacePhoneNumber": futureWorkplacePhoneNumber,
                "profileImageUrl": profileImageUrl as Any,
                "signatureUrl": signatureUrl as Any,
                "koreaAddress": koreaAddress,
                "telephoneNumber": telephoneNumber,
                "homelandAddress": homelandAddress,
                "homelandPhoneNumber": homelandPhoneNumber,
                "schoolStatus": schoolStatus,
                "schoolName": schoolName,
                "schoolPhoneNumber": schoolPhoneNumber,
                "schoolType": schoolType,
                "originalWorkplaceName": originalWorkplaceName,
                "originalWorkplaceRegistrationNumber": originalWorkplaceRegistrationNumber,
                "originalWorkplacePhoneNumber": originalWorkplacePhoneNumber,
                "incomeAmount": String(incomeAmount),
                "job": job,
                "refundAccountNumber": refundAccountNumber
            ])
            
            // Save to UserDefaults
            if let encoded = try? JSONEncoder().encode(myInfoData) {
                UserDefaults.standard.set(encoded, forKey: "SavedmyInfoData")
                myInfoDataSaved = true
                print("✅ MyInfo data saved successfully")
            }
            
            showContentView = true
        } else {
            print("❌ Fields validation failed")
            errorMessage = "Please fill in all required fields."
            showAlert = true
        }
    }
    
    
    // verifyUserAndLoadData 함수 수정
     private func verifyUserAndLoadData() {
         print("\n🔐 Verifying user credentials...")
         
         // 저장된 OCR 데이터에서 userId 확인
         if let arcData = savedARCData,
            let arcResult = try? JSONDecoder().decode(OCRNaverResponse.self, from: arcData),
            let userId = arcResult.data?.userId {
             ocrUserId = userId
         }
         
         if let passportData = savedpassportData,
            let passportResult = try? JSONDecoder().decode(PassportNaverResponse.self, from: passportData),
            let userId = passportResult.data?.userId {
             // 만약 ARC에서 userId를 못 가져왔다면 passport에서 가져옴
             if ocrUserId.isEmpty {
                 ocrUserId = userId
             }
         }
         
         print("📝 Current username: \(currentUsername)")
         print("📝 OCR userId: \(ocrUserId)")
         
         // username과 ocrUserId가 일치하는지 확인
         guard !ocrUserId.isEmpty && ocrUserId == currentUsername else {
             print("❌ User verification failed - Username mismatch")
             alertMessage = "User verification failed. Data cannot be loaded."
             showAlert = true
             return
         }
         
         // 사용자 검증이 성공하면 데이터 로드
         if let savedData = UserDefaults.standard.data(forKey: "SavedmyInfoData") {
             do {
                 let myInfoData = try JSONDecoder().decode([String: String].self, from: savedData)
                 print("✅ Found saved data for user")
                 
                 // UI 업데이트
                 DispatchQueue.main.async {
                     updateUIWithData(myInfoData)
                 }
             } catch {
                 print("❌ Error decoding saved data: \(error)")
                 alertMessage = "Error loading saved data"
                 showAlert = true
             }
         }
     }
    
    // createMyInfo 함수 추가
    private func createMyInfo() {
        guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("❌ Access token not available")
            alertMessage = "Access token not available"
            showAlert = true
            return
        }
        
        let myInfoDict: [String: Any] = [
            "phoneNumber": phoneNumber,
            "annualIncome": incomeAmount,
            "workplaceName": originalWorkplaceName,
            "workplaceRegistrationNumber": originalWorkplaceRegistrationNumber,
            "workplacePhoneNumber": originalWorkplacePhoneNumber,
            "futureWorkplaceName": futureWorkplaceName,
            "futureWorkplaceRegistrationNumber": originalWorkplaceRegistrationNumber,
            "futureWorkplacePhoneNumber": futureWorkplacePhoneNumber,
            "profileImageUrl": profileImageUrl as Any,
            "signatureUrl": signatureUrl as Any,
            "koreaAddress": koreaAddress,
            "telephoneNumber": telephoneNumber,
            "homelandAddress": homelandAddress,
            "homelandPhoneNumber": homelandPhoneNumber,
            "schoolStatus": schoolStatus,
            "schoolName": schoolName,
            "schoolPhoneNumber": schoolPhoneNumber,
            "schoolType": schoolType,
            "originalWorkplaceName": originalWorkplaceName,
            "originalWorkplaceRegistrationNumber": originalWorkplaceRegistrationNumber,
            "originalWorkplacePhoneNumber": originalWorkplacePhoneNumber,
            "incomeAmount": String(incomeAmount),
            "job": job,
            "refundAccountNumber": refundAccountNumber
        ]
        
        print("\n📤 Creating MyInfo with data:")
        myInfoDict.forEach { key, value in
            print("  \(key): \(value)")
        }
        
        let url = URL(string: "http://43.203.237.202:18080/api/v1/members/details")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: myInfoDict)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Error creating MyInfo: \(error.localizedDescription)")
                        self.alertMessage = "Error creating MyInfo: \(error.localizedDescription)"
                        self.showAlert = true
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse,
                       (200...299).contains(httpResponse.statusCode) {
                        print("✅ MyInfo created successfully")
                        self.saveData()
                        self.showContentView = true
                    } else {
                        print("❌ Failed to create MyInfo")
                        self.alertMessage = "Failed to create MyInfo"
                        self.showAlert = true
                    }
                }
            }.resume()
            
        } catch {
            print("❌ Error encoding data: \(error.localizedDescription)")
            alertMessage = "Error encoding data"
            showAlert = true
        }
    }
    // UI 업데이트 함수
       private func updateUIWithData(_ data: [String: String]) {
           // username과 ocrUserId가 일치할 때만 데이터 업데이트
           if ocrUserId == currentUsername {
               koreaAddress = data["koreaAddress"] ?? ""
               telephoneNumber = data["telephoneNumber"] ?? ""
               phoneNumber = data["phoneNumber"] ?? ""
               homelandAddress = data["homelandAddress"] ?? ""
               homelandPhoneNumber = data["homelandPhoneNumber"] ?? ""
               schoolStatus = data["schoolStatus"] ?? ""
               schoolName = data["schoolName"] ?? ""
               schoolPhoneNumber = data["schoolPhoneNumber"] ?? ""
               schoolType = data["schoolType"] ?? ""
               originalWorkplaceName = data["originalWorkplaceName"] ?? ""
               originalWorkplaceRegistrationNumber = data["originalWorkplaceRegistrationNumber"] ?? ""
               originalWorkplacePhoneNumber = data["originalWorkplacePhoneNumber"] ?? ""
               futureWorkplaceName = data["futureWorkplaceName"] ?? ""
               futureWorkplacePhoneNumber = data["futureWorkplacePhoneNumber"] ?? ""
               incomeAmount = Int(data["incomeAmount"] ?? "0") ?? 0
               job = data["job"] ?? ""
               refundAccountNumber = data["refundAccountNumber"] ?? ""
               
               print("✅ UI updated with loaded data for user: \(currentUsername)")
           } else {
               print("❌ User verification failed - Cannot update UI")
               resetFields()  // 일치하지 않으면 필드 초기화
           }
       }
    
    private func validateFields() -> Bool {
        let isValid = !koreaAddress.isEmpty &&
        !telephoneNumber.isEmpty &&
        !phoneNumber.isEmpty &&
        !homelandAddress.isEmpty &&
        !homelandPhoneNumber.isEmpty &&
        !schoolStatus.isEmpty &&
        !schoolName.isEmpty &&
        !schoolPhoneNumber.isEmpty &&
        !schoolType.isEmpty &&
        !originalWorkplaceName.isEmpty &&
        !originalWorkplaceRegistrationNumber.isEmpty &&
        !originalWorkplacePhoneNumber.isEmpty &&
        !futureWorkplaceName.isEmpty &&
        !futureWorkplacePhoneNumber.isEmpty &&
        incomeAmount > 0 &&
        !job.isEmpty &&
        !refundAccountNumber.isEmpty
        
        print("🔍 Field validation result: \(isValid)")
        if !isValid {
            print("Missing fields:")
            if koreaAddress.isEmpty { print("- Korea Address") }
            if telephoneNumber.isEmpty { print("- Telephone No.") }
            if phoneNumber.isEmpty { print("- Cellphone No.") }
            if homelandAddress.isEmpty { print("- Home Country Address") }
            if homelandPhoneNumber.isEmpty { print("- Home Country Phone Number") }
            if schoolStatus.isEmpty { print("- Enrollment Status") }
            if schoolName.isEmpty { print("- School Name") }
            if schoolPhoneNumber.isEmpty { print("- School Phone Number") }
            if schoolType.isEmpty { print("- Type of School") }
            if originalWorkplaceName.isEmpty { print("- Previous Employer Name") }
            if originalWorkplaceRegistrationNumber.isEmpty { print("- Previous Employer Business Registration Number") }
            if originalWorkplacePhoneNumber.isEmpty { print("- Previous Employer Phone Number") }
            if futureWorkplaceName.isEmpty { print("- Prospective Employer Name") }
            if futureWorkplacePhoneNumber.isEmpty { print("- Prospective Employer Phone Number") }
            if incomeAmount <= 0 { print("- Annual Income") }
            if job.isEmpty { print("- Occupation") }
            if refundAccountNumber.isEmpty { print("- Refund Account Number") }
        }
        
        return isValid
    }
    
    // MARK: - Data Operations
    private func updateMyInfo() {
        guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("❌ Access token not available")
            alertMessage = "Access token not available"
            showAlert = true
            return
        }
        
        // Dictionary로 먼저 데이터 구성
        let myInfoDict: [String: Any] = [
            "phoneNumber": phoneNumber,
            "annualIncome": incomeAmount,
            "workplaceName": originalWorkplaceName,
            "workplaceRegistrationNumber": originalWorkplaceRegistrationNumber,
            "workplacePhoneNumber": originalWorkplacePhoneNumber,
            "futureWorkplaceName": futureWorkplaceName,
            "futureWorkplaceRegistrationNumber": originalWorkplaceRegistrationNumber,
            "futureWorkplacePhoneNumber": futureWorkplacePhoneNumber,
            "profileImageUrl": profileImageUrl as Any,
            "signatureUrl": signatureUrl as Any,
            "koreaAddress": koreaAddress,
            "telephoneNumber": telephoneNumber,
            "homelandAddress": homelandAddress,
            "homelandPhoneNumber": homelandPhoneNumber,
            "schoolStatus": schoolStatus,
            "schoolName": schoolName,
            "schoolPhoneNumber": schoolPhoneNumber,
            "schoolType": schoolType,
            "originalWorkplaceName": originalWorkplaceName,
            "originalWorkplaceRegistrationNumber": originalWorkplaceRegistrationNumber,
            "originalWorkplacePhoneNumber": originalWorkplacePhoneNumber,
            "incomeAmount": String(incomeAmount),
            "job": job,
            "refundAccountNumber": refundAccountNumber
        ]
        
        print("\n📤 Updating MyInfo with data:")
        myInfoDict.forEach { key, value in
            print("  \(key): \(value)")
        }
        
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: myInfoDict)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Error updating information: \(error.localizedDescription)")
                        alertMessage = "Error updating information: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("❌ Invalid server response")
                        alertMessage = "Invalid server response"
                        showAlert = true
                        return
                    }
                    
                    if (200...299).contains(httpResponse.statusCode) {
                        print("✅ Information updated successfully")
                        alertMessage = "Information updated successfully"
                        myInfoDataSaved = true
                        saveData()
                        showContentView = true
                    } else {
                        print("❌ Failed to update information. Status code: \(httpResponse.statusCode)")
                        alertMessage = "Failed to update information. Status code: \(httpResponse.statusCode)"
                    }
                    showAlert = true
                }
            }.resume()
        } catch {
            print("❌ Error encoding data: \(error.localizedDescription)")
            alertMessage = "Error encoding data: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func fetchData() {
        guard let accessToken = KeychainWrapper.standard.string(forKey: "accessToken") else {
            print("❌ Access token not available")
            return
        }
        
        let url = URL(string: "http://43.203.237.202:18080/api/v1/members/details")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        print("📥 Fetching MyInfo data...")
        isLoading = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    print("❌ Error fetching data: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode([String: String].self, from: data)
                    print("✅ Data fetched successfully:")
                    decodedData.forEach { key, value in
                        print("  \(key): \(value)")
                    }
                    
                    self.koreaAddress = decodedData["koreaAddress"] ?? ""
                    self.telephoneNumber = decodedData["telephoneNumber"] ?? ""
                    self.phoneNumber = decodedData["phoneNumber"] ?? ""
                    self.homelandAddress = decodedData["homelandAddress"] ?? ""
                    self.homelandPhoneNumber = decodedData["homelandPhoneNumber"] ?? ""
                    self.schoolStatus = decodedData["schoolStatus"] ?? ""
                    self.schoolName = decodedData["schoolName"] ?? ""
                    self.schoolPhoneNumber = decodedData["schoolPhoneNumber"] ?? ""
                    self.schoolType = decodedData["schoolType"] ?? ""
                    self.originalWorkplaceName = decodedData["originalWorkplaceName"] ?? ""
                    self.originalWorkplaceRegistrationNumber = decodedData["originalWorkplaceRegistrationNumber"] ?? ""
                    self.originalWorkplacePhoneNumber = decodedData["originalWorkplacePhoneNumber"] ?? ""
                    self.futureWorkplaceName = decodedData["futureWorkplaceName"] ?? ""
                    self.futureWorkplacePhoneNumber = decodedData["futureWorkplacePhoneNumber"] ?? ""
                    self.incomeAmount = Int(decodedData["incomeAmount"] ?? "0") ?? 0
                    self.job = decodedData["job"] ?? ""
                    self.refundAccountNumber = decodedData["refundAccountNumber"] ?? ""
                    
                    print("✅ UI updated with fetched data")
                } catch {
                    print("❌ Failed to decode JSON: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    private func saveData() {
        let myInfoData: [String: String] = [
            "koreaAddress": koreaAddress,
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
            "incomeAmount": String(incomeAmount),
            "job": job,
            "refundAccountNumber": refundAccountNumber,
            "profileImageUrl": profileImageUrl ?? "",
            "signatureUrl": signatureUrl ?? ""
        ]
        
        print("\n📝 Attempting to save MyInfo data:")
        myInfoData.forEach { key, value in
            print("  \(key): \(value)")
        }
        
        do {
            let encodedData = try JSONEncoder().encode(myInfoData)
            UserDefaults.standard.set(encodedData, forKey: "SavedmyInfoData")
            myInfoDataSaved = true
            
            // Verify saved data
            if let verificationData = UserDefaults.standard.data(forKey: "SavedmyInfoData"),
               let decodedData = try? JSONDecoder().decode([String: String].self, from: verificationData) {
                print("\n✅ Data saved and verified in UserDefaults:")
                decodedData.forEach { key, value in
                    print("  \(key): \(value)")
                }
            }
            
            alertMessage = "Your information has been saved successfully."
            print("✅ Save operation completed successfully")
        } catch {
            alertMessage = "Failed to save your information: \(error.localizedDescription)"
            print("❌ Save operation failed: \(error.localizedDescription)")
        }
        showAlert = true
        print("--------------------------------")
    }
    
    private func loadMyInfoData() -> [String: String]? {
        print("\n🔄 Starting loadMyInfoData process...")
        
        guard let savedData = UserDefaults.standard.data(forKey: "SavedmyInfoData") else {
            print("❌ No MyInfo data found in UserDefaults")
            return nil
        }
        
        do {
            let myInfoData = try JSONDecoder().decode([String: String].self, from: savedData)
            print("\n📦 Successfully loaded MyInfo data:")
            myInfoData.forEach { key, value in
                print("  \(key): \(value)")
            }
            return myInfoData
        } catch {
            print("❌ Failed to decode MyInfo data: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func resetFields() {
        print("\n🔄 Resetting all fields...")
        koreaAddress = ""
        telephoneNumber = ""
        phoneNumber = ""
        homelandAddress = ""
        homelandPhoneNumber = ""
        schoolStatus = ""
        schoolName = ""
        schoolPhoneNumber = ""
        schoolType = ""
        originalWorkplaceName = ""
        originalWorkplaceRegistrationNumber = ""
        originalWorkplacePhoneNumber = ""
        futureWorkplaceName = ""
        futureWorkplacePhoneNumber = ""
        incomeAmount = 0
        job = ""
        refundAccountNumber = ""
        signatureImage = nil
        print("✅ All fields reset successfully")
    }
    
    private func saveImageToAlbum(_ image: UIImage) {
        print("\n📸 Saving signature image to album...")
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        alertMessage = "Signature saved to album."
        showAlert = true
        print("✅ Signature image saved to album")
    }
    
    
    struct SectionInfoView: View {
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
                ZStack(alignment: .leading) {
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
    }
    
    struct DropdownInfoField: View {
        var title: String
        @Binding var selectedValue: String
        var options: [String]
        var placeholder: String
        var isRequired: Bool = false
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.gray)
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
                        Text(selectedValue.isEmpty ? placeholder : selectedValue)
                            .foregroundColor(selectedValue.isEmpty ? .gray : .black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                }
            }
        }
    }
    
    // MARK: - Signature Related Views
    struct SignatureMyInfoPadView: View {
        @Binding var signatureImage: UIImage?
        var onSave: (UIImage) -> Void
        @State private var drawingPath = DrawingMyInfoPath()
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            VStack {
                Text("Enter Signature")
                    .font(.headline)
                    .padding()
                
                SignatureMyInfoDrawView(drawing: $drawingPath)
                    .frame(height: 200)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
                    .padding()
                
                HStack {
                    Button(action: {
                        print("🔄 Resetting signature pad")
                        drawingPath = DrawingMyInfoPath()
                    }) {
                        Text("Reset")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                    }
                    
                    Button(action: {
                        print("✅ Saving signature")
                        let image = drawingPath.toImage()
                        onSave(image)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
    
    struct SignatureMyInfoDrawView: View {
        @Binding var drawing: DrawingMyInfoPath
        
        var body: some View {
            ZStack {
                Color.white
                if drawing.isEmpty {
                    Text("Please enter the signature to be used for document creation.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                } else {
                    DrawMyInfoShape(drawingPath: drawing)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.black)
                }
            }
            .gesture(DragGesture()
                .onChanged { value in
                    drawing.addPoint(value.location)
                }
                .onEnded { _ in
                    drawing.addBreak()
                })
        }
    }
    
    struct DrawMyInfoShape: Shape {
        let drawingPath: DrawingMyInfoPath
        
        func path(in rect: CGRect) -> Path {
            drawingPath.path
        }
    }
    
    struct DrawingMyInfoPath {
        private(set) var points = [CGPoint]()
        private var breaks = [Int]()
        
        var isEmpty: Bool {
            points.isEmpty
        }
        
        mutating func addPoint(_ point: CGPoint) {
            points.append(point)
        }
        
        mutating func addBreak() {
            breaks.append(points.count)
        }
        
        var path: Path {
            var path = Path()
            guard let firstPoint = points.first else { return path }
            path.move(to: firstPoint)
            for i in 1..<points.count {
                if breaks.contains(i) {
                    path.move(to: points[i])
                } else {
                    path.addLine(to: points[i])
                }
            }
            return path
        }
        
        func toImage() -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 200))
            return renderer.image { ctx in
                ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
                ctx.cgContext.setLineWidth(2)
                ctx.cgContext.addPath(path.cgPath)
                ctx.cgContext.drawPath(using: .stroke)
            }
        }
    }

}

extension Path {
    var cgPath: CGPath {
        let path = CGMutablePath()
        forEach { element in
            switch element {
            case .move(let p):
                path.move(to: p)
            case .line(let p):
                path.addLine(to: p)
            case .quadCurve(let p1, let p2):
                path.addQuadCurve(to: p2, control: p1)
            case .curve(let p1, let p2, let p3):
                path.addCurve(to: p3, control1: p1, control2: p2)
            case .closeSubpath:
                path.closeSubpath()
            }
        }
        return path
    }
}
                    // MARK: - Preview
                    struct MyInfoView_Previews: PreviewProvider {
                        static var previews: some View {
                            MyInfoView()
                        }
                    }
