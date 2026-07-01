import SwiftUI

public struct PaymentMethodScreen: View {
    let onNextTapped: () -> Void

    public var body: some View {
        VStack(spacing: 20) {
            Text("Bank Data Selection").font(.title)
            Button("Next: Summary", action: onNextTapped)
        }
        .padding()
        .navigationTitle("Bank Data")
    }
}

