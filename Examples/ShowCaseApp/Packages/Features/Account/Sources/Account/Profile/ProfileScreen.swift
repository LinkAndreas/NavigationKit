import SwiftUI

struct ProfileScreen: View {
    let onPersonalInformationTapped: () -> Void
    let onNotificationsTapped: () -> Void
    let onPaymentMethodsTapped: () -> Void
    let onSettingsTapped: () -> Void
    let onLogoutTapped: () -> Void
    let onCloseTapped: () -> Void

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("jane_doe")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("ios_developer_apple")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("account_settings")) {
                Button(action: onPersonalInformationTapped) {
                    Label("personal_information", systemImage: "person.text.rectangle")
                }
                
                Button(action: onNotificationsTapped) {
                    Label("notifications", systemImage: "bell.badge")
                }
                
                Button(action: onPaymentMethodsTapped) {
                    Label("payment_methods", systemImage: "creditcard")
                }
                
                Button(action: onSettingsTapped) {
                    Label("general_settings", systemImage: "gear")
                }
            }
            
            Section {
                Button(action: onLogoutTapped) {
                    Text("log_out")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("close", action: onCloseTapped)
            }
        }
    }
}
