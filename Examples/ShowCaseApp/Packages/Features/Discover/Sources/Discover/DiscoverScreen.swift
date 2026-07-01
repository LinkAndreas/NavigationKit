import SwiftUI

struct DiscoverScreen: View {
    let openEventDetails: () -> Void
    let openKeynoteDetails: (String) -> Void
    let openSchedule: () -> Void
    let openAccount: () -> Void

    var body: some View {
        DiscoverView(
            openEventDetails: openEventDetails,
            openKeynoteDetails: openKeynoteDetails,
            openSchedule: openSchedule,
            openAccount: openAccount
        )
    }
}
