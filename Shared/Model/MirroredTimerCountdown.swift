//
//  MirroredTimerCountdown.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 13/7/24.
//

import Foundation

struct MirroredTimerCountdown: Equatable, Codable {
    let value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    enum CodingKeys: String, CodingKey {
        case value
    }
    
    init?(dictionary: [String:Any]) {
        guard let value = dictionary[MirroredTimerCountdown.CodingKeys.value.rawValue] as? Int else {
            return nil
        }
        self.value = value
    }
}

// MARK :- CustomStringConvertible
extension MirroredTimerCountdown: CustomStringConvertible {
    var description: String {
        return "MirroredTimerCountdown(\(self.value))"
    }
}
