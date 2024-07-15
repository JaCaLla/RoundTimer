//
//  MirroredTimerStopped.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 14/7/24.
//

import Foundation

struct MirroredTimerStopped: Equatable, Codable {
    let rounds: Int
    let currentRound: Int
    let date: String
    let isWork: Bool
    
    init(rounds: Int, currentRounds: Int, date: String, isWork: Bool) {
        self.rounds = rounds
        self.currentRound = currentRounds
        self.date = date
        self.isWork = isWork
    }
    
    enum CodingKeys: String, CodingKey {
        case rounds, currentRound, date, isWork
    }
    
    init?(dictionary: [String:Any]) {
        guard let rounds = dictionary[MirroredTimerStopped.CodingKeys.rounds.rawValue] as? Int,
        let currentRounds = dictionary[MirroredTimerStopped.CodingKeys.currentRound.rawValue] as? Int,
        let date = dictionary[MirroredTimerStopped.CodingKeys.date.rawValue] as? String,
        let isWork = dictionary[MirroredTimerStopped.CodingKeys.isWork.rawValue] as? Bool else {
            return nil
        }
        self.rounds = rounds
        self.currentRound = currentRounds
        self.date = date
        self.isWork = isWork
    }
}

// MARK :- CustomStringConvertible
extension MirroredTimerStopped: CustomStringConvertible {
    var description: String {
        return "MirroredTimerStopped(\(currentRound)/\(rounds),\(date),\(isWork)"
    }
}
