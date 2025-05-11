import Foundation
import WatchConnectivity
import os.log
@MainActor
final class Connectivity: NSObject, ObservableObject {
  @Published var purchasedIds: [Int] = []
 

    @Published var companionCustomTimer: CustomTimer?
    @Published var mirroredTimer: MirroredTimer?
    @Published var pingReceivedOnAW: Bool = false

  static let shared = Connectivity()

  override private init() {
    super.init()

    #if !os(watchOS)
    guard WCSession.isSupported() else {
      return
    }
    #endif

    WCSession.default.delegate = self
    WCSession.default.activate()
  }

    public func send(connectivityMessage: ConnectivityMessage,
                     delivery: Delivery,
                replyHandler: (([String: Any]) -> Void)? = nil,
                errorHandler: ((Error) -> Void)? = nil ) {
        guard canSendToPeer() else { return }
        guard let userInfo: [String: Any] = connectivityMessage.toDict() else {
                return
        }
        LocalLogger.log("Connectivity.send delivery:\(delivery):connectivityMessage:\(connectivityMessage)")
        switch delivery {
        case .failable:
          WCSession.default.sendMessage(
            userInfo,
            replyHandler: optionalMainQueueDispatch(handler: replyHandler),
            errorHandler: optionalMainQueueDispatch(handler: errorHandler)
          )

        case .guaranteed:
          WCSession.default.transferUserInfo(userInfo)

        case .highPriority:
          do {
            try WCSession.default.updateApplicationContext(userInfo)
          } catch {
            errorHandler?(error)
          }
        }
        
    }

  private func canSendToPeer() -> Bool {
    guard WCSession.default.activationState == .activated else {
      return false
    }

    #if os(watchOS)
    guard WCSession.default.isCompanionAppInstalled else {
      return false
    }
    #else
    guard WCSession.default.isWatchAppInstalled else {
      return false
    }
    #endif

    return true
  }

    private func update(from dictionary: [String: Any]) async {
        guard let connectivityMessage = ConnectivityMessage(dictionary: dictionary) else { return }
           if connectivityMessage.action == .startTimer, let customTimer = connectivityMessage.customTimer {
               LocalLogger.log("Connectivity.update.companionCustomTimer = \(customTimer.description)")
               await MainActor.run {
                   self.companionCustomTimer = customTimer
               }
           } else if connectivityMessage.action == .removeTimer {
               LocalLogger.log("Connectivity.update.companionCustomTimer = nil")
               await MainActor.run {
                   self.companionCustomTimer = nil
               }
           } else if connectivityMessage.action == .refreshMirroredTimer,
                        let mirroredTimer = connectivityMessage.mirroredTimer {
               LocalLogger.log("Connectivity.update.mirroredTimer = \(mirroredTimer)")
               self.mirroredTimer = mirroredTimer
               
           } else if connectivityMessage.action == .ping {
               LocalLogger.log("Connectivity.update.pingReceivedOnAW = true \(connectivityMessage.direction)")
               if     connectivityMessage.direction == .fromIPhoneToAWatch {
                   self.pingReceivedOnAW = true
                   
               } else {
                   await MainActor.run {
                       self.pingReceivedOnAW = true
                   }
               }
           } else {
               LocalLogger.log("Connectivity.update unknown message")
           }
  }

    func addTimer() {
        // to do llamar a la función 
        let customTimer = CustomTimer(timerType: .emom, rounds: 2, workSecs: 10)
        let message = ConnectivityMessage(action: .startTimer, direction: .fromIPhoneToAWatch, customTimer: customTimer)
        if message.action == .startTimer, let customTimer = message.customTimer  {
            self.companionCustomTimer = customTimer
        }
    }
    
    func removeTimer() {
        self.companionCustomTimer = nil//= CustomTimer(timerType: .none, rounds: 0)
    }

  typealias OptionalHandler<T> = ((T) -> Void)?

  private func optionalMainQueueDispatch<T>(handler: OptionalHandler<T>) -> OptionalHandler<T> {
    guard let handler = handler else {
      return nil
    }

    return { item in
      DispatchQueue.main.async {
        handler(item)
      }
    }
  }
    
    static func getTimestamp() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        return dateFormatter.string(from: date)
    }
}

// MARK: - WCSessionDelegate
extension Connectivity: WCSessionDelegate {
    internal nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }

  #if os(iOS)
  nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
  }

  nonisolated func sessionDidDeactivate(_ session: WCSession) {
    // If the person has more than one watch, and they switch,
    // reactivate their session on the new device.
    WCSession.default.activate()
  }
  #endif

     nonisolated func session(
    _ session: WCSession,
    didReceiveUserInfo userInfo: [String: Any] = [:]
  ) {
      doCopyAndCallUpdateInMainActor(userInfo)
  }
    
     private nonisolated func doCopyAndCallUpdateInMainActor(_ dictionary: [String: Any] = [:])  {
         nonisolated(unsafe) let dictionaryCopy =  dictionary.deepCopy()
             Task { @MainActor in
                 await self.update(from: dictionaryCopy)
             }
    }

nonisolated func session(
    _ session: WCSession,
    didReceiveApplicationContext applicationContext: [String: Any]
  ) {
      doCopyAndCallUpdateInMainActor(applicationContext)
  }

  // This method is called when a message is sent with failable priority
  // *and* a reply was requested.
  nonisolated func session(
    _ session: WCSession,
    didReceiveMessage message: [String: Any],
    replyHandler: @escaping ([String: Any]) -> Void
  ) {
      
      doCopyAndCallUpdateInMainActor(message)
    
    let key = ConnectivityUserInfoKey.verified.rawValue
    replyHandler([key: true])
  }

  // This method is called when a message is sent with failable priority
  // and a reply was *not* request.
  nonisolated func session(
    _ session: WCSession,
    didReceiveMessage message: [String: Any]
  ) {
      doCopyAndCallUpdateInMainActor(message)
  }

  nonisolated func session(
    _ session: WCSession,
    didReceiveMessageData messageData: Data
  ) {
  }

  nonisolated func session(
    _ session: WCSession,
    didReceiveMessageData messageData: Data,
    replyHandler: @escaping (Data) -> Void
  ) {
  }

  #if os(watchOS)
//  func session(_ session: WCSession, didReceive file: WCSessionFile) {
//    let key = ConnectivityUserInfoKey.qrCodes.rawValue
//    guard let id = file.metadata?[key] as? Int else {
//      return
//    }
//
//    let destination = QRCode.url(for: id)
//
//    try? FileManager.default.removeItem(at: destination)
//    try? FileManager.default.moveItem(at: file.fileURL, to: destination)
//  }
  #endif
}
