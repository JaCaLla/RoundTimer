import SwiftUI
import Combine
protocol TimerStoreProtocol {
    func startTimerOnAW(customTimer: CustomTimer)
    func removeTimerOnAW()
    func ping(completion: @escaping () -> Void)
}

final class TimerStore: NSObject, ObservableObject {
    static let shared = TimerStore()
    private static let purchasedKey = "purchased"
    
    @Published var customTimer: CustomTimer? = nil{
        didSet {
            LocalLogger.log("TimerStore.customTimer.didSet \(customTimer?.description ?? "nil")")
        }
    }
    
    var pingCompletion:(() -> Void) = { /* Default empty block */}
    @Published var pingReceivedOnAW: Bool = false {
        didSet {
            LocalLogger.log("TimerStore.pingCompletion.didSet \(pingReceivedOnAW)")
#if os(watchOS)
            //
            pingAcknowledge()
            LocalLogger.log("TimerStore.pingCompletion.pingAcknowledge()")
#else
            pingCompletion()
            LocalLogger.log("TimerStore.pingCompletion.pingCompletion()")
#endif
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
        
        Connectivity.shared.$pingReceivedOnAW
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .assign(to: \.pingReceivedOnAW, on: self)
            .store(in: &cancellable)
    }
    
    let delivery =  Delivery.guaranteed
}

// MARK: - TimerStoreProtocol
extension TimerStore: TimerStoreProtocol {
    
    

    func startTimerOnAW(customTimer: CustomTimer) {
        let connectivityMessage = ConnectivityMessage(action: .startTimer, direction: .fromIPhoneToAWatch, customTimer: customTimer)
        Connectivity.shared.send(connectivityMessage: connectivityMessage, delivery: delivery)
    }
    
    func removeTimerOnAW() {
        let connectivityMessage = ConnectivityMessage(action: .removeTimer, direction: .fromIPhoneToAWatch)
        Connectivity.shared.send(connectivityMessage: connectivityMessage, delivery: delivery)
    }
    
    func ping(completion: @escaping () -> Void) {
        pingCompletion = completion
        let connectivityMessage = ConnectivityMessage(action: .ping, direction: .fromIPhoneToAWatch)
        Connectivity.shared.send(connectivityMessage: connectivityMessage, delivery: delivery)
    }
    
    func pingAcknowledge() {
        let connectivityMessage = ConnectivityMessage(action: .ping, direction: .fromAWatchToIPhone)
        Connectivity.shared.send(connectivityMessage: connectivityMessage, delivery: delivery)
    }
}
