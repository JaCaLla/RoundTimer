import SwiftUI
import Combine

final class TimerStore: NSObject, ObservableObject {
  static let shared = TimerStore()
  private static let purchasedKey = "purchased"

    @Published var customTimer: CustomTimer? = nil{
        didSet {
            LocalLogger.log("TimerStore.customTimer.didSet \(customTimer?.description ?? "nil")")
        }
    }
    
    
  private var cancellable: Set<AnyCancellable> = []

 // let ticketCost = 8.5.formatted(.currency(code: "usd"))


  override private init() {

    super.init()

      Connectivity.shared.$companionCustomTimer
          .dropFirst()
          .receive(on: DispatchQueue.main)
          .compactMap { customTimer in
              LocalLogger.log("TimerStore.Connectivity.shared.$companionCustomTimer \(customTimer?.description ?? "nil")")
              return customTimer//CustomTimer(timerType: .emom, rounds: 2, workSecs: 10)
          }
          .assign(to: \.customTimer, on: self)
          .store(in: &cancellable)
  }

    
    func startTimerOnAW(customTimer: CustomTimer) {
        let connectivityMessage = ConnectivityMessage(action: .startTimer, direction: .fromIPhoneToAWatch, customTimer: customTimer)
        Connectivity.shared.send(connectivityMessage: connectivityMessage, delivery: .guaranteed)
    }
    
    func removeTimerOnAW() {
        let connectivityMessage = ConnectivityMessage(action: .removeTimer, direction: .fromIPhoneToAWatch)
        Connectivity.shared.send(connectivityMessage: connectivityMessage, delivery: .guaranteed)
    }
}
