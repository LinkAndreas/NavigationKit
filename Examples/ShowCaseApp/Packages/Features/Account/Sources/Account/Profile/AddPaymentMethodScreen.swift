import SwiftUI

struct AddPaymentMethodScreen: View {
    let onSaveTapped: () -> Void
    let onCancelTapped: () -> Void
    
    @State private var cardName: String = ""
    @State private var cardNumber: String = ""
    @State private var expiry: String = ""
    @State private var cvv: String = ""
    
    private var isFormValid: Bool {
        let cleanCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let isValidExpiry = expiry.count == 5 && expiry.contains("/")
        return !cardName.isEmpty && cleanCardNumber.count == 16 && isValidExpiry && (cvv.count == 3 || cvv.count == 4)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Card Details")) {
                TextField("Name on Card", text: $cardName)
                TextField("Card Number", text: $cardNumber)
                    .keyboardType(.numberPad)
                    .onChange(of: cardNumber) { _, newValue in
                        var clean = newValue.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                        if clean.count > 16 {
                            clean = String(clean.prefix(16))
                        }
                        // Format with spaces
                        var formatted = ""
                        for (index, char) in clean.enumerated() {
                            if index > 0 && index % 4 == 0 {
                                formatted.append(" ")
                            }
                            formatted.append(char)
                        }
                        cardNumber = formatted
                    }
                
                HStack {
                    TextField("MM/YY", text: $expiry)
                        .keyboardType(.numberPad)
                        .onChange(of: expiry) { _, newValue in
                            var clean = newValue.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                            if clean.count > 4 {
                                clean = String(clean.prefix(4))
                            }
                            if clean.count > 2 {
                                let start = clean.index(clean.startIndex, offsetBy: 2)
                                expiry = "\(clean[..<start])/\(clean[start...])"
                            } else {
                                expiry = clean
                            }
                        }
                    Divider()
                    TextField("CVV", text: $cvv)
                        .keyboardType(.numberPad)
                        .onChange(of: cvv) { _, newValue in
                            let clean = newValue.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                            cvv = String(clean.prefix(4))
                        }
                }
            }
        }
        .navigationTitle("Add Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: onCancelTapped)
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let lastFour = cardNumber.count >= 4 ? String(cardNumber.suffix(4)) : "1234"
                    let type: PaymentMethod.CardType = cardNumber.starts(with: "4") ? .visa : .mastercard
                    
                    PaymentMethodStore.shared.add(
                        name: cardName.isEmpty ? "New Card" : cardName,
                        lastFour: lastFour,
                        type: type
                    )
                    
                    onSaveTapped()
                }
                .disabled(!isFormValid)
            }
        }
    }
}
