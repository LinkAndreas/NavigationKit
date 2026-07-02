import Foundation

extension Optional {
    var isPresented: Bool {
        get { self != nil }
        set {
            if !newValue { self = nil }
        }
    }
}
