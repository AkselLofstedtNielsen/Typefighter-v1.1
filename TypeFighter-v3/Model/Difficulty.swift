//
//  Difficulty.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-04-07.
//

enum Difficulty: String, CaseIterable, Identifiable {
    case easy
    case medium
    case hard
    
    var id: String { self.rawValue }
    
    var fallingDuration: Double {
        switch self {
        case .easy:
            return 8.0      // 8 seconds to type the word
        case .medium:
            return 6.0      // 6 seconds to type the word
        case .hard:
            return 4.0      // 4 seconds to type the word
        }
    }
    
    var spawnInterval: Double {
        switch self {
        case .easy:
            return 2.5
        case .medium:
            return 2.0
        case .hard:
            return 1.5
        }
    }
}
