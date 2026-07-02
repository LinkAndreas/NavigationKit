import SwiftUI

public struct ShippingAddressEntryScreen: View {
    let onToInvoiceDataTapped: () -> Void
    let onToSummaryTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("reward_collector_selection").font(.title)
            Button("next_invoice_data", action: onToInvoiceDataTapped)
            Button("skip_to_summary", action: onToSummaryTapped)
        }
        .padding()
        .navigationTitle("collectors")
    }
}

