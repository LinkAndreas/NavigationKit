import SwiftUI

struct SettingsScreen: View {
    let onDeleteAccountTapped: () -> Void

    @AppStorage("appearance_setting") private var appearance: Int = 0
    @State private var syncToCalendar = false
    @State private var downloadOverWifiOnly = true
    @State private var shareAnalytics = true
    @State private var discoverable = false

    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $appearance) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 4)
            }
            
            Section(header: Text("Data & Sync")) {
                Toggle("Sync Agenda to Calendar", isOn: $syncToCalendar)
                Toggle("Download Video over Wi-Fi only", isOn: $downloadOverWifiOnly)
            }
            
            Section(header: Text("Privacy")) {
                Toggle("Share Usage Analytics", isOn: $shareAnalytics)
                Toggle("Make me discoverable to attendees", isOn: $discoverable)
            }
            
            Section {
                Button("Delete Account") {
                    onDeleteAccountTapped()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Settings")
    }
}
