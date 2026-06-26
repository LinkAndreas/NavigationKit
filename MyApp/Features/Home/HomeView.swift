import SwiftUI

struct HomeView: View {
    let openCatalog: () -> Void
    let openAccount: () -> Void
    
    var body: some View {
        List {
            Button("Browse catalog", action: openCatalog)
            Button("My account", action: openAccount)
        }
        .navigationTitle("Home")
    }
}
