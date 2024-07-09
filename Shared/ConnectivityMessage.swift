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

struct ConnectivityMessage: Dictionable {
    typealias DataType = [String: Any]
    let action: ConnectivityMessageAction
    let direction: ConnectivityMessageDirection
    var customTimer: CustomTimer? = nil
    
    var description: String {
        return "ConnectivityMessage(\(self.action.rawValue),\(self.direction),\(String(describing: self.customTimer?.description)))"
    }
    
    enum CodingKeys: String, CodingKey {
        case action
        case direction
        case customTimer
    }

    
    init(action: ConnectivityMessageAction,
         direction: ConnectivityMessageDirection,
         customTimer: CustomTimer? = nil) {
        self.action = action
        self.direction = direction
        self.customTimer = customTimer
    }
    
    init?(dictionary: [String:Any]) {
        guard let action = ConnectivityMessageAction(rawValue: dictionary[ConnectivityMessage.CodingKeys.action.rawValue] as? String ?? ""),
            let direction = ConnectivityMessageDirection(rawValue: dictionary[ConnectivityMessage.CodingKeys.direction.rawValue] as? String ?? "")
            else {
            return nil
        }
        self.action = action
        self.direction = direction
        if  let dictionary =  dictionary[ConnectivityMessage.CodingKeys.customTimer.rawValue] as? [String : Any],
            let customTimer = CustomTimer(dictionary: dictionary) {
            self.customTimer = customTimer
        }
    }
}

enum ConnectivityMessageAction: String, Codable {
    case none
    case startTimer
    case removeTimer
    case ping
}

enum ConnectivityMessageDirection: String, Codable {
    case none
    case fromIPhoneToAWatch
    case fromAWatchToIPhone
    
}
