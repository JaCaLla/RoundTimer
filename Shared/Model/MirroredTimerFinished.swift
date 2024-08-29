//
//  MirroredTimerStopped.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 14/7/24.
//

import Foundation

struct MirroredTimerFinished: Equatable, Codable {
    let rounds: Int
    let currentRound: Int
    let date: String
    let isWork: Bool
    let message: String
    
    init(rounds: Int, currentRounds: Int, date: String, isWork: Bool, message: String) {
        self.rounds = rounds
        self.currentRound = currentRounds
        self.date = date
        self.isWork = isWork
        self.message = message
    }
    
    enum CodingKeys: String, CodingKey {
        case rounds, currentRound, date, isWork, message
    }
    
    init?(dictionary: [String:Any]) {
        guard let rounds = dictionary[MirroredTimerFinished.CodingKeys.rounds.rawValue] as? Int,
        let currentRounds = dictionary[MirroredTimerFinished.CodingKeys.currentRound.rawValue] as? Int,
        let date = dictionary[MirroredTimerFinished.CodingKeys.date.rawValue] as? String,
        let isWork = dictionary[MirroredTimerFinished.CodingKeys.isWork.rawValue] as? Bool,
        let message = dictionary[MirroredTimerFinished.CodingKeys.message.rawValue] as? String else {
            return nil
        }
        self.rounds = rounds
        self.currentRound = currentRounds
        self.date = date
        self.isWork = isWork
        self.message = message
    }
}

// MARK :- CustomStringConvertible
extension MirroredTimerFinished: CustomStringConvertible {
    var description: String {
        return "MirroredTimerStopped(\(currentRound)/\(rounds),\(date),\(isWork),\(message)"
    }
}
