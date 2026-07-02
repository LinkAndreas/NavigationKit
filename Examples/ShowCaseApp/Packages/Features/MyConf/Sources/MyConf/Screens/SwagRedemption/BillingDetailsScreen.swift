import SwiftUI

public struct BillingDetailsScreen: View {
    let onNextTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("invoice_data_entry").font(.title)
            Button("next_bank_data", action: onNextTapped)
        }
        .padding()
        .navigationTitle("invoice")
    }
}

