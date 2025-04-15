//
//  GameEngine.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-04-15.
//

import Foundation

class GameEngine {
    var difficulty: Difficulty
    var wordGenerating: WordGenerating
    
    func spawnWord() -> Word {
        
    }
    func checkCollision(word: Word) -> Bool {
        
    }
    func processUserInput(letter: Character) -> WordMatchResult {
        
    }
}

protocol WordGenerating {
    func getNextWord() -> String
}

enum WordMatchResult {
    case noMatch
    case partialMatch(wordId: UUID, progress: Double)
    case completeMatch(wordId: UUID, score: Int)
}
