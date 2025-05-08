import SwiftUI

@MainActor
final class UpTimerViewModel: EMOMViewModel {

    override func getCurrentRound() -> String {
        guard [.countdown].allSatisfy({ state.value != $0 }) else { return "" }
        return String(localized: "up_indicator")
    }
}
