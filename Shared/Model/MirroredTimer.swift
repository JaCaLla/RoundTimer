//
//  MirroredTimer.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 12/7/24.
//

import Foundation
// TO DO: TRY TO USE STATE ENUM INSTEAD
enum MirroredTimerType: String, Codable {
    case countdown, working, stopped, removedFromCompanion
}

struct MirroredTimer: Equatable, Codable {
    let mirroredTimerType: MirroredTimerType
    var mirroredTimerCountdown: MirroredTimerCountdown?
    var mirroredTimerWorking: MirroredTimerWorking?
    var mirroredTimerStopped: MirroredTimerStopped?
    
    
    enum CodingKeys: String, CodingKey {
        case mirroredTimerType
        case mirroredTimerCountdown
        case mirroredTimerWorking
        case mirroredTimerStopped
    }
    
    
    init(mirroredTimerType: MirroredTimerType,
         mirroredTimerCountdown: MirroredTimerCountdown? = nil,
         mirroredTimerWorking: MirroredTimerWorking? = nil,
         mirroredTimerStopped: MirroredTimerStopped? = nil) {
        self.mirroredTimerType = mirroredTimerType
        self.mirroredTimerCountdown = mirroredTimerCountdown
        self.mirroredTimerWorking = mirroredTimerWorking
        self.mirroredTimerStopped = mirroredTimerStopped
    }
    
    init?(dictionary: [String:Any]) {
        guard let mirroredTimerTypeStr = dictionary[MirroredTimer.CodingKeys.mirroredTimerType.rawValue] as? String,
              let mirroredTimerType = MirroredTimerType(rawValue: mirroredTimerTypeStr) else {
            return nil
        }
        self.mirroredTimerType = mirroredTimerType
        if  let dictionary =  dictionary[MirroredTimer.CodingKeys.mirroredTimerCountdown.rawValue] as? [String : Any],
            let mirroredTimerCountdown = MirroredTimerCountdown(dictionary: dictionary) {
                         // self.mirroredTimer = countdown
            self.mirroredTimerCountdown = mirroredTimerCountdown
        }
        if  let dictionary =  dictionary[MirroredTimer.CodingKeys.mirroredTimerWorking.rawValue] as? [String : Any],
            let mirroredTimerWorking = MirroredTimerWorking(dictionary: dictionary) {
                         // self.mirroredTimer = countdown
            self.mirroredTimerWorking = mirroredTimerWorking
        }
        if  let dictionary =  dictionary[MirroredTimer.CodingKeys.mirroredTimerStopped.rawValue] as? [String : Any],
            let mirroredTimerStopped = MirroredTimerStopped(dictionary: dictionary) {
                         // self.mirroredTimer = countdown
            self.mirroredTimerStopped = mirroredTimerStopped
        }
        
    }
}

// MARK :- CustomStringConvertible
extension MirroredTimer: CustomStringConvertible {
    var description: String {
        return "MirroredTimer(\(mirroredTimerType),\(String(describing: mirroredTimerCountdown)),\(String(describing: mirroredTimerWorking)))"
    }
}

// MARK :- Samples
extension MirroredTimer {
    static let removedFromCompanion = MirroredTimer(mirroredTimerType: .removedFromCompanion)
}
