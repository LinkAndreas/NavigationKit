import SwiftUI

struct PersonalInformationScreen: View {
    @State private var firstName = "Jane"
    @State private var lastName = "Doe"
    @State private var email = "jane.doe@apple.com"

    var body: some View {
        Form {
            Section(header: Text("Basic Info")) {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
            }
            
            Section(header: Text("Contact")) {
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
            }
        }
        .navigationTitle("Personal Info")
    }
}
