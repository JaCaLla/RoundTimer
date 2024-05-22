//
//  LocalPersitenceManager.swift
//  EMOM timers
//
//  Created by Javier Calartrava on 13/5/24.
//

import Foundation

protocol LocalPersitenceManagerProtocol {
    func add(message: String)
 //   func resetMessages()
}

final class LocalPersitenceManager: NSObject, ObservableObject {
    static var shared = LocalPersitenceManager()
    
    private static let purchasedKey = "purchased"
    
    @Published var messages: [String] = [] {
      didSet {
        UserDefaults.standard.setValue(messages, forKey: Self.purchasedKey)
      }
    }
    
    override private init() {
        messages = UserDefaults.standard.array(forKey: Self.purchasedKey) as? [String] ?? []

    }
}

extension LocalPersitenceManager: LocalPersitenceManagerProtocol {
    func add(message: String) {
        messages.append(message)
    }
    
//    func resetMessages() {
//      //  UserDefaults.standard.removeObject(forKey: "myArray")
//    }
    
    

}
