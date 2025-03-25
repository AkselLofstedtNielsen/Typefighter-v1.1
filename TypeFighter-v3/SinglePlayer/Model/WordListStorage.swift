//
//  WordListStorage.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-03-25.
//

import Foundation

@propertyWrapper
struct WordListStorage {
    private let key: String
    private let defaultValue: [String]
    
    init(key: String, defaultValue: [String] = []) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: [String] {
        get {
            UserDefaults.standard.array(forKey: key) as? [String] ?? defaultValue
        }  set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

