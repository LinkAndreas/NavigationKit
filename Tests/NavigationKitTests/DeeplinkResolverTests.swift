import Foundation
import Testing
@testable import NavigationKit

@Test
@MainActor
func failsResolvingURLWhenDeepLinkHandlerMissing() async throws {
    let url = anyURL()
    let sut = makeSUT()
        
    let result = sut.resolve(url)
    #expect(result == nil)
}

@Test
@MainActor
func resolvesURLToNavigationState() async throws {
    let navigationState = anyNavigationState()
    let url = anyURL()
    let sut = makeSUT()
    let handler = anyDeepLinkHandler(state: navigationState)
    
    sut.register(handler)
    
    let result = sut.resolve(url)
    #expect(result == navigationState)
}

@Test
@MainActor
func skipsNilHandlersAndResolvesWithFirstMatchingHandler() async throws {
    let expectedState = NavigationState.stack(StackState(AnyRoute.a))
    let url = anyURL()
    let sut = makeSUT()
    
    // First handler fails to resolve
    sut.register { _ in nil }
    
    // Second handler resolves
    sut.register { _ in expectedState }
    
    // Third handler is ignored
    sut.register { _ in .stack(StackState(AnyRoute.b)) }
    
    let result = sut.resolve(url)
    #expect(result == expectedState)
}

@Test
@MainActor
func evaluatesHandlersInRegistrationOrder() async throws {
    let firstState = NavigationState.stack(StackState(AnyRoute.a))
    let secondState = NavigationState.stack(StackState(AnyRoute.b))
    let url = anyURL()
    let sut = makeSUT()
    
    sut.register { _ in firstState }
    sut.register { _ in secondState }
    
    let result = sut.resolve(url)
    #expect(result == firstState)
}

@MainActor
private func makeSUT() -> DeeplinkResolver {
    let sut = DeeplinkResolver()
    return sut
}

private enum AnyRoute: Hashable {
    case a
    case b
}

private func anyNavigationState() -> NavigationState {
    return .stack(StackState.init(AnyRoute.a))
}

private func anyDeepLinkHandler(state: NavigationState) -> (URL) -> NavigationState? {
    return { url in
        return state
    }
}

private func anyURL(string: String = "https://www.google.com") -> URL {
    return URL(string: string)!
}
