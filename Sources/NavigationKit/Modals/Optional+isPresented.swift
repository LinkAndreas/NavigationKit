import SwiftUI

extension Optional {
    /// A helper property that maps an optional value to a boolean binding.
    ///
    /// - Returns: `true` if the optional is non-nil; `false` otherwise.
    /// - Note: When setting to `false`, the optional is mutated to `nil`. Setting to `true` has no effect.
    var isPresented: Bool {
        get { self != nil }
        set {
            if !newValue { self = nil }
        }
    }
}
