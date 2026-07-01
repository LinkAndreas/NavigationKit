import SwiftUI

public struct ShippingAddressEntryScreen: View {
    let onToInvoiceDataTapped: () -> Void
    let onToSummaryTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Reward Collector Selection").font(.title)
            Button("Next: Invoice Data", action: onToInvoiceDataTapped)
            Button("Skip to Summary", action: onToSummaryTapped)
        }
        .padding()
        .navigationTitle("Collectors")
    }
}

