//
//  ConnectivityMessage.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 22/5/24.
//

import Foundation
protocol Dictionable: Codable {
    
}

extension Dictionable {
    func toDict() -> Dictionary<String, Any>? {

        var dict: Dictionary<String, Any>? = nil

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>
        } catch {
            return nil
        }
        return dict
    }
}
// MARK :- CustomStringConvertible
extension ConnectivityMessage: CustomStringConvertible {
    var description: String {
        return "ConnectivityMessage(\(self.action.rawValue),\(self.direction),\(String(describing: self.customTimer?.description)),\(String(describing: mirroredTimer))"
    }
}

struct ConnectivityMessage: Dictionable {
    typealias DataType = [String: Any]
    let action: ConnectivityMessageAction
    let direction: ConnectivityMessageDirection
    var customTimer: CustomTimer? = nil
    var mirroredTimer: MirroredTimer?
    
    enum CodingKeys: String, CodingKey {
        case action
        case direction
        case customTimer
        case mirroredTimer
    }

    
    init(action: ConnectivityMessageAction,
         direction: ConnectivityMessageDirection,
         customTimer: CustomTimer? = nil,
         mirroredTimer: MirroredTimer? = nil) {
        self.action = action
        self.direction = direction
        self.customTimer = customTimer
        self.mirroredTimer = mirroredTimer
    }
    
    init?(dictionary: [String: Any]) {
        guard let action = ConnectivityMessageAction(rawValue: dictionary[ConnectivityMessage.CodingKeys.action.rawValue] as? String ?? ""),
            let direction = ConnectivityMessageDirection(rawValue: dictionary[ConnectivityMessage.CodingKeys.direction.rawValue] as? String ?? "")
            else {
            return nil
        }
        self.action = action
        self.direction = direction
        if let dictionary = dictionary[ConnectivityMessage.CodingKeys.customTimer.rawValue] as? [String: Any],
            let customTimer = CustomTimer(dictionary: dictionary) {
            self.customTimer = customTimer
        } else if let dictionary = dictionary[ConnectivityMessage.CodingKeys.mirroredTimer.rawValue] as? [String: Any],
            let mirroredTimer = MirroredTimer(dictionary: dictionary) {
            self.mirroredTimer = mirroredTimer
        }
        }
}

enum ConnectivityMessageAction: String, Codable {
    case none
    case startTimer
    case removeTimer
    case ping
    case refreshMirroredTimer
}

enum ConnectivityMessageDirection: String, Codable {
    case none
    case fromIPhoneToAWatch
    case fromAWatchToIPhone
    
}
