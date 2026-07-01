import NavigationKit

import SwiftUI

struct FramePreferenceKey: PreferenceKey {
    static let defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

struct FloatingDebuggerView: View {
    let navigator: RootNavigator
    var manager: DebuggerWindowManager
    @State private var isPresented = false
    @State private var position: CGPoint?

    var body: some View {
        GeometryReader { screenProxy in
            ZStack {
                Color.clear
                .allowsHitTesting(false)
            
            Image(systemName: "ladybug.fill")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .clipShape(Circle())
                .shadow(radius: 4, y: 2)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: FramePreferenceKey.self, value: proxy.frame(in: .global))
                    }
                )
                .onPreferenceChange(FramePreferenceKey.self) { frame in
                    manager.buttonFrame = frame
                }
                .position(position ?? CGPoint(x: screenProxy.size.width - 50, y: screenProxy.size.height - 100))
                .onTapGesture {
                    isPresented = true
                }
                .highPriorityGesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            position = value.location
                        }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $isPresented) {
                NavigationStack {
                    ScrollView([.horizontal, .vertical]) {
                        Text(navigator.debugDescription)
                            .font(.system(.body, design: .monospaced))
                            .fixedSize(horizontal: true, vertical: false)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                    }
                    .navigationTitle("Navigation Graph")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { isPresented = false }
                        }
                    }
                }
            }
    }
}
