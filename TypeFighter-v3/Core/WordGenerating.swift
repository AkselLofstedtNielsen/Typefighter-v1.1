//
//  WordGenerating.swift
//  TypeFighter-v3
//
//  Updated implementation to prevent word repetition
//

import Foundation

protocol WordGenerating {
    func getNextWord() -> String
    func isPoolEmpty() -> Bool
    func resetPool() // Add this to allow pool reset for new games
}

// Fixed implementation that prevents word repetition
class WordListGenerator: WordGenerating {
    private let wordList: WordListSinglePlayer
    private var availableWords: [Word] = [] // Words that haven't been used yet
    private var usedWords: [Word] = [] // Words that have been used
    
    init(wordList: WordListSinglePlayer) {
        self.wordList = wordList
        // Make sure we have words loaded
        wordList.fillList()
        resetPool() // Initialize available words
        print("WordListGenerator initialized with \(availableWords.count) available words")
    }
    
    func getNextWord() -> String {
        // Check if we have any available words
        guard !availableWords.isEmpty else {
            print("No more words available, pool is empty")
            return "FALLBACK"
        }
        
        // Get a random word from available words
        let randomIndex = Int.random(in: 0..<availableWords.count)
        let selectedWord = availableWords.remove(at: randomIndex)
        
        // Move it to used words
        usedWords.append(selectedWord)
        
        print("Returning word: \(selectedWord.word) (\(availableWords.count) remaining)")
        return selectedWord.word
    }
    
    func isPoolEmpty() -> Bool {
        return availableWords.isEmpty
    }
    
    func resetPool() {
        // Reset the pool by moving all words back to available
        availableWords = wordList.gameWords.map { word in
            // Create new instances to avoid reference issues
            Word(word: word.word, xPos: 0, yPos: 0)
        }
        usedWords.removeAll()
        print("Word pool reset with \(availableWords.count) words available")
    }
    
    // Debug function to see current state
    func debugPrintPoolState() {
        print("=== WordListGenerator State ===")
        print("Available words: \(availableWords.count)")
        print("Used words: \(usedWords.count)")
        if !availableWords.isEmpty {
            print("Next few available: \(availableWords.prefix(3).map { $0.word })")
        }
    }
}

// Keep the RandomWordGenerator as an alternative for testing
class RandomWordGenerator: WordGenerating {
    private let wordPool = [
        "SWIFT", "CODING", "APPLE", "XCODE", "MOBILE",
        "DESIGN", "PATTERN", "FRAME", "FACE", "KEY",
        "SCREEN", "BUTTON", "GESTURE", "ANIMATE", "LAYOUT"
    ]
    
    private var availableWords: [String]
    private let wordLimit: Int
    
    init(wordLimit: Int = 10) {
        self.wordLimit = wordLimit
        self.availableWords = []
        resetPool()
    }
    
    func getNextWord() -> String {
        guard !availableWords.isEmpty else {
            print("RandomWordGenerator: No more words available")
            return "DEFAULT"
        }
        
        // Remove and return a random word
        let randomIndex = Int.random(in: 0..<availableWords.count)
        let word = availableWords.remove(at: randomIndex)
        
        print("RandomWordGenerator returning: \(word) (\(availableWords.count) remaining)")
        return word
    }
    
    func isPoolEmpty() -> Bool {
        return availableWords.isEmpty
    }
    
    func resetPool() {
        // Create a pool with limited number of words, no repetition
        let shuffledPool = wordPool.shuffled()
        availableWords = Array(shuffledPool.prefix(min(wordLimit, wordPool.count)))
        print("RandomWordGenerator pool reset with \(availableWords.count) words")
    }
}
