import SwiftUI

/// A SwiftUI view that creates and retains a context for its content.
///
/// Use `WithContext` when a view needs a reference or value that should be created
/// lazily and kept alive for the lifetime of a SwiftUI identity. Changing the
/// supplied `id` resets the stored context, so the next body evaluation creates a
/// new one.
///
/// Example:
/// ```swift
/// WithContext(id: offset) {
///     ViewModel(offset: offset)
/// } content: { viewModel in
///     Text("Offset: \(viewModel.offset)")
/// }
/// ```
///
/// - Parameters:
///   - Context: The type of context created for the content view.
///   - Content: The SwiftUI view produced from the context.
public struct WithContext<Context, Content: View>: View {
    private let id: [AnyHashable]
    private let make: () -> Context
    private let content: (Context) -> Content

    /// Creates a context-backed view.
    ///
    /// - Parameters:
    ///   - id: The value that defines the lifetime of the stored context. When it
    ///     changes, the context is rebuilt.
    ///   - make: A closure that creates the context. The closure is evaluated
    ///     lazily, when the content first accesses the context.
    ///   - content: A view builder that receives the retained context and returns
    ///     the view hierarchy to display.
    public init(
        id: AnyHashable,
        make: @escaping () -> Context,
        @ViewBuilder content: @escaping (Context) -> Content
    ) {
        self.id = [id]
        self.make = make
        self.content = content
    }

    /// Creates a context-backed view.
    ///
    /// - Parameters:
    ///   - id: Values that together define the lifetime of the stored context.
    ///     When any value changes, the context is rebuilt.
    ///   - make: A closure that creates the context. The closure is evaluated
    ///     lazily, when the content first accesses the context.
    ///   - content: A view builder that receives the retained context and returns
    ///     the view hierarchy to display.
    public init(
        id: [AnyHashable] = [],
        make: @escaping () -> Context,
        @ViewBuilder content: @escaping (Context) -> Content
    ) {
        self.id = id
        self.make = make
        self.content = content
    }

    /// The view hierarchy that owns the scoped context storage.
    public var body: some View {
        Scope(make: make, content: content)
            .id(id)
    }

    private struct Scope: View {
        final class Storage {
            lazy var context: Context = make()
            private let make: () -> Context

            init(make: @escaping () -> Context) {
                self.make = make
            }
        }

        @State private var storage: Storage
        private let content: (Context) -> Content

        init(
            make: @escaping () -> Context,
            content: @escaping (Context) -> Content
        ) {
            self.storage = Storage(make: make)
            self.content = content
        }

        var body: some View {
            content(storage.context)
        }
    }
}
