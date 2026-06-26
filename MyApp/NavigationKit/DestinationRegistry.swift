import SwiftUI

@MainActor
public struct DestinationRegistry {
    private var builders: [ObjectIdentifier: (AnyRoute, Navigator) -> AnyView] = [:]
    public init() {}
    public mutating func register<R: Hashable, V: View>(
        _ type: R.Type, @ViewBuilder _ build: @escaping (R, Navigator) -> V
    ) {
        builders[ObjectIdentifier(type)] = { any, nav in
            guard let r = any.wrapped.base as? R else { return AnyView(EmptyView()) }
            return AnyView(build(r, nav))
        }
    }
    func view(for route: AnyRoute, navigator: Navigator) -> AnyView {
        builders[route.typeID]?(route, navigator)
            ?? AnyView(Text("⚠️ Unregistered route: \(String(describing: route.wrapped))")
                        .foregroundStyle(.red))
    }
}
