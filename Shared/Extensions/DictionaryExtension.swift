//
//  Dictionary.swift
//  EMOM timers
//
//  Created by Javier Calatrava on 16/10/24.
//

import Foundation

extension Dictionary where Key == String, Value == Any {
    func deepCopy() -> Self {
        var copiedDict: [String: Any] = [:]
        
        for (key, value) in self {
            if let arrayValue = value as? [Any] {
                copiedDict[key] = arrayValue.deepCopyArray()
            } else if let dictValue = value as? [String: Any] {
                copiedDict[key] = dictValue.deepCopy()
            } else {
                copiedDict[key] = value
            }
        }
        
        return copiedDict
    }
}
