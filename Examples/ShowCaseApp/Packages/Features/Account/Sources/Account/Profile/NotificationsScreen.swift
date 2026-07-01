import SwiftUI

struct NotificationsScreen: View {
    @State private var emailNotifications = true
    @State private var pushNotifications = true
    @State private var marketingEmails = false

    var body: some View {
        Form {
            Section(header: Text("Conference Updates")) {
                Toggle("Push Notifications", isOn: $pushNotifications)
                Toggle("Email Notifications", isOn: $emailNotifications)
            }
            
            Section(header: Text("Offers & Promotions"), footer: Text("Receive occasional emails about future events and partner offers.")) {
                Toggle("Marketing Emails", isOn: $marketingEmails)
            }
        }
        .navigationTitle("Notifications")
    }
}
