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
                        Text("Jane Doe")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("iOS Developer @ Apple")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Account Settings")) {
                Button(action: onPersonalInformationTapped) {
                    Label("Personal Information", systemImage: "person.text.rectangle")
                }
                
                Button(action: onNotificationsTapped) {
                    Label("Notifications", systemImage: "bell.badge")
                }
                
                Button(action: onPaymentMethodsTapped) {
                    Label("Payment Methods", systemImage: "creditcard")
                }
                
                Button(action: onSettingsTapped) {
                    Label("General Settings", systemImage: "gear")
                }
            }
            
            Section {
                Button(action: onLogoutTapped) {
                    Text("Log Out")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close", action: onCloseTapped)
            }
        }
    }
}
