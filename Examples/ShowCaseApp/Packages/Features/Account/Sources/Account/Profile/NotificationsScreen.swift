import SwiftUI

struct NotificationsScreen: View {
    @State private var emailNotifications = true
    @State private var pushNotifications = true
    @State private var marketingEmails = false

    var body: some View {
        Form {
            Section(header: Text("conference_updates")) {
                Toggle("Push Notifications", isOn: $pushNotifications)
                Toggle("Email Notifications", isOn: $emailNotifications)
            }
            
            Section(header: Text("offers_promotions"), footer: Text("receive_occasional_emails_about_future_e")) {
                Toggle("Marketing Emails", isOn: $marketingEmails)
            }
        }
        .navigationTitle("notifications")
    }
}
