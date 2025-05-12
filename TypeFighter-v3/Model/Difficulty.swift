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
            return 10
        case .medium:
            return 7.0
        case .hard:
            return 4.5
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
