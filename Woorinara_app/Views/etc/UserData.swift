import Foundation

class UserData: ObservableObject {
    @Published var surname: String = ""
    @Published var givenName: String = ""
    @Published var dateOfBirth: String = ""
    @Published var gender: String = ""
    @Published var nationality: String = ""
    @Published var foreignRegistrationNumber: String = ""
    @Published var passportNumber: String = ""
    @Published var passportIssueDate: String = ""
    @Published var passportExpiryDate: String = ""

    @Published var addressInKorea: String = ""
    @Published var telephoneNumber: String = ""
    @Published var phoneNumber: String = ""
    @Published var homelandAddress: String = ""
    @Published var homelandPhoneNumber: String = ""
    @Published var schoolStatus: String = ""
    @Published var schoolName: String = ""
    @Published var schoolPhoneNumber: String = ""
    @Published var schoolType: String = ""
    @Published var originalWorkplaceName: String = ""
    @Published var originalWorkplaceRegistrationNumber: String = ""
    @Published var originalWorkplacePhoneNumber: String = ""
    @Published var futureWorkplaceName: String = ""
    @Published var futureWorkplacePhoneNumber: String = ""

    @Published var incomeAmount: String = ""
    @Published var occupation: String = ""
    @Published var email: String = ""
    @Published var refundAccountNumber: String = ""
    @Published var dateOfApplication: String = ""
}
