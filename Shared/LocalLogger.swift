//
//  Logger.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 22/6/24.
//

import Foundation
import os.log

actor LocalLogger {
#if os(watchOS)
static let sender = "⌚️"
#elseif os(iOS)
    static let sender = "📱"
#else
    static let sender = "⁉️"
#endif
    
    
    static func log(type: OSLogType = .info, _ message: String) {
        os_log(type, "\(LocalLogger.sender):\(message)")
    }
}
