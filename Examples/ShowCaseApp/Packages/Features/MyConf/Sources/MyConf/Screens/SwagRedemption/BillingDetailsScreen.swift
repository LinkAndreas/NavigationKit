import SwiftUI

public struct BillingDetailsScreen: View {
    let onNextTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Invoice Data Entry").font(.title)
            Button("Next: Bank Data", action: onNextTapped)
        }
        .padding()
        .navigationTitle("Invoice")
    }
}

