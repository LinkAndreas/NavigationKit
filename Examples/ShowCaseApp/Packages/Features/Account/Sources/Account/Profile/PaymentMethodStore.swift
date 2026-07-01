import Foundation
import SwiftUI

public struct PaymentMethod: Identifiable, Hashable {
    public let id = UUID()
    public let name: String
    public let lastFour: String
    public let type: CardType

    public enum CardType: String, Hashable {
        case visa = "Visa"
        case mastercard = "Mastercard"
        case appleCard = "Apple Card"
        
        var iconName: String {
            switch self {
            case .appleCard: return "applelogo"
            case .visa, .mastercard: return "creditcard.fill"
            }
        }
    }
}

@MainActor
public class PaymentMethodStore: ObservableObject {
    public static let shared = PaymentMethodStore()
    
    @Published public var methods: [PaymentMethod] = [
        PaymentMethod(name: "Apple Card", lastFour: "1234", type: .appleCard)
    ]
    
    public func add(name: String, lastFour: String, type: PaymentMethod.CardType) {
        let newMethod = PaymentMethod(name: name, lastFour: lastFour, type: type)
        methods.append(newMethod)
    }
}
