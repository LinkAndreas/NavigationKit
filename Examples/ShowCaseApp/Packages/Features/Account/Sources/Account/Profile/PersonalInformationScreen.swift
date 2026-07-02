import SwiftUI

struct PersonalInformationScreen: View {
    @State private var firstName = "Jane"
    @State private var lastName = "Doe"
    @State private var email = "jane.doe@apple.com"

    var body: some View {
        Form {
            Section(header: Text("basic_info")) {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
            }
            
            Section(header: Text("contact")) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
            }
        }
        .navigationTitle("personal_info")
    }
}
