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
    private var usedWords: Set<UUID> = []
    
    init(wordList: WordListSinglePlayer) {
        self.wordList = wordList
        // Make sure we have words loaded
        wordList.fillList()
        print("WordListGenerator initialized with \(wordList.gameWords.count) words")
    }
    
    func getNextWord() -> String {
        // If we have a random word from the list, return it
        if let randomWord = wordList.gameWords.randomElement() {
            // Track this word as used
            usedWords.insert(randomWord.id)
            
            // Keep it in gameWords but mark as used
            // This prevents removing from the source array which could be causing issues
            print("Returning word: \(randomWord.word)")
            return randomWord.word
        }
        
        print("No words available, returning fallback")
        // Fallback to a default word if none available
        return "FALLBACK"
    }
    
    func isPoolEmpty() -> Bool {
        // Check if all words have been used
        return usedWords.count >= wordList.gameWords.count
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
    
    init(wordLimit: Int = 10) {
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
