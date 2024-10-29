//
//  ArrayExtension.swift
//  EMOM timers
//
//  Created by Javier Calatrava on 16/10/24.
//

import Foundation

extension Array where Element == Any {
   // @MainActor
    func deepCopyArray() -> [Any] {
        var copiedArray: [Any] = []
        
        for element in self {
            if let arrayElement = element as? [Any] {
                copiedArray.append(arrayElement.deepCopyArray())
            } else if let dictElement = element as? [String: Any] {
                copiedArray.append(dictElement.deepCopy())
            } else {
                copiedArray.append(element)
            }
        }
        
        return copiedArray
    }
}
