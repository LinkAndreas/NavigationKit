import SwiftUI

public struct PaymentMethodScreen: View {
    let onNextTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("bank_data_selection").font(.title)
            Button("next_summary", action: onNextTapped)
        }
        .padding()
        .navigationTitle("bank_data")
    }
}

