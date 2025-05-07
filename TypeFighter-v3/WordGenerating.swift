
//
//  WordGenerating.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-05-07.
//

import Foundation


protocol WordGenerating {
    func getNextWord() -> String
    func isPoolEmpty() -> Bool
}

// Implementation for the existing WordListSinglePlayer
class WordListGenerator: WordGenerating {
    private let wordList: WordListSinglePlayer
    
    init(wordList: WordListSinglePlayer) {
        self.wordList = wordList
        // Make sure we have words loaded
        wordList.fillList()
    }
    
    func getNextWord() -> String {
        // If we have a random word from the list, return it
        if let randomWord = wordList.gameWords.randomElement() {
            // Remove it from the available pool
            wordList.gameWords.removeAll(where: { $0.id == randomWord.id })
            return randomWord.word
        }
        
        // Fallback to a default word if none available
        return "FALLBACK"
    }
    
    func isPoolEmpty() -> Bool {
        return wordList.gameWords.isEmpty && wordList.words.isEmpty
    }
}

// Example of a random word generator for testing
class RandomWordGenerator: WordGenerating {
    private let wordPool = [
        "SWIFT", "CODING", "APPLE", "XCODE", "MOBILE",
        "DESIGN", "PATTERN", "FRAMEWORK", "INTERFACE", "KEYBOARD",
        "SCREEN", "BUTTON", "GESTURE", "ANIMATION", "LAYOUT"
    ]
    
    private var remainingWords: [String]
    private let wordLimit: Int
    
    init(wordLimit: Int = 50) {
        self.wordLimit = wordLimit
        self.remainingWords = []
        resetWordPool()
    }
    
    func getNextWord() -> String {
        if remainingWords.isEmpty {
            resetWordPool()
        }
        
        if let word = remainingWords.popLast() {
            return word
        }
        
        return "DEFAULT"
    }
    
    func isPoolEmpty() -> Bool {
        return remainingWords.isEmpty
    }
    
    private func resetWordPool() {
        // Create a new pool with repeated words to match word limit
        var pool: [String] = []
        
        for _ in 0..<(wordLimit / wordPool.count + 1) {
            pool.append(contentsOf: wordPool)
        }
        
        // Shuffle the pool and limit it
        remainingWords = pool.shuffled().prefix(wordLimit).map { $0 }
    }
}
