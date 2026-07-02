import SwiftUI

struct PaymentMethodsScreen: View {
    @StateObject private var store = PaymentMethodStore.shared
    let onAddPaymentMethodTapped: () -> Void

    var body: some View {
        List {
            Section(header: Text("saved_cards")) {
                ForEach(store.methods) { method in
                    HStack {
                        Image(systemName: method.type.iconName)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(method.name)
                                .font(.headline)
                            Text("lastfour")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            Section {
                Button(action: onAddPaymentMethodTapped) {
                    Label("add_payment_method", systemImage: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("payment")
    }
}
