//
//  GameEngine.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-04-15.
//

import Foundation
import SwiftUI

//PROBLEM
//- Liv blir inte borttagna vid miss.
//- Verkar som ord slutar falla om man slutar skriva ett tag? timern? eller word som slutar läsas om kanske
//- userinput fixat. Men ordet försvinner inte förens nästa tangent trycks. Titta över.

// Enum for word matching results
enum WordMatchResult {
    case noMatch
    case partialMatch(wordId: UUID, progress: Double)
    case completeMatch(wordId: UUID, score: Int)
}

class GameEngine: ObservableObject {
    // Configuration
    @Published var difficulty: Difficulty
    private let wordGenerating: WordGenerating
    
    // Game state
    @Published var words: [Word] = []
    @Published var score: Int = 0
    @Published var lives: Int = 3
    @Published var elapsedTime: Double = 0.0
    @Published var wordsPerMinute: Double = 0.0
    @Published var currentTypedWord: String = ""
    
    // Word tracking
    private var activeWordId: UUID?
    private var letterPosition: Int = 0
    private var wordsCompleted: Int = 0
    private var lastSpawnTime: Double = 0.0
    
    // Active timers
    private var gameTimer: Timer?
    
    init(difficulty: Difficulty, wordGenerating: WordGenerating) {
        self.difficulty = difficulty
        self.wordGenerating = wordGenerating
    }
    
    // Game control functions
    func startGame() {
        resetGameState()
        startTimers()
        // Spawn initial word to get things going
        spawnWord()
        lastSpawnTime = 0.0
    }
    
    func stopGame() {
        stopTimers()
    }
    
    func pauseGame() {
        stopTimers()
    }
    
    func resumeGame() {
        startTimers()
    }
    
    func resetGameState() {
        words.removeAll()
        score = 0
        lives = 3
        elapsedTime = 0.0
        wordsPerMinute = 0.0
        currentTypedWord = ""
        activeWordId = nil
        letterPosition = 0
        wordsCompleted = 0
        lastSpawnTime = 0.0
    }
    
    // Timer functions
    private func startTimers() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateGameTime()
        }
    }
    
    private func stopTimers() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func updateGameTime() {
        elapsedTime += 0.1
        
        // Calculate words per minute
        if wordsCompleted > 0 {
            let minutesElapsed = elapsedTime / 60.0
            wordsPerMinute = (Double(wordsCompleted) / minutesElapsed).roundToDecimal(1)
        }
        
        // Check if it's time to spawn a new word
        if elapsedTime - lastSpawnTime >= difficulty.spawnInterval {
            spawnWord()
            lastSpawnTime = elapsedTime
        }
    }
    
    // Word spawning and management
    func spawnWord() {
        let newWord = wordGenerating.getNextWord()
        if newWord == "FALLBACK" || newWord.isEmpty {
            print("Word pool is empty or returning fallback")
            return
        }
        
        let xPositions: [CGFloat] = [-140, -120, -100, -80, -60, -40, 0, 30, 50, 70, 90, 130]
        
        if let xPos = xPositions.randomElement() {
            let word = Word(word: newWord, xPos: xPos, yPos: -400)
            print("Spawning new word: \(newWord) at position \(xPos)")
            words.append(word)
        }
    }
    
    func removeWord(_ id: UUID) {
        print("Removing word with ID: \(id)")
        words.removeAll { $0.id == id }
        if activeWordId == id {
            resetWordTyping()
        }
    }
    
    // Input processing
    func processUserInput(letter: Character) -> WordMatchResult {
        // If we're already typing a word
        if let activeId = activeWordId {
            return continueTypingWord(activeId, letter: letter)
        } else {
            return startTypingNewWord(letter)
        }
    }
    
    private func startTypingNewWord(_ letter: Character) -> WordMatchResult {
        // Find a word that starts with this letter
        if let matchingWord = words.first(where: { $0.letter == letter }) {
            activeWordId = matchingWord.id
            letterPosition = 1  // Already matched first letter
            currentTypedWord = String(letter)
            
            return .partialMatch(wordId: matchingWord.id, progress: 1.0 / Double(matchingWord.word.count))
        }
        
        return .noMatch
    }
    
    private func continueTypingWord(_ wordId: UUID, letter: Character) -> WordMatchResult {
        guard let wordIndex = words.firstIndex(where: { $0.id == wordId }),
              letterPosition < words[wordIndex].word.count else {
            return .noMatch
        }
        
        let word = words[wordIndex]
        let letters = Array(word.word)
        
        // Check if the letter matches the next expected letter
        if letters[letterPosition] == letter {
            letterPosition += 1
            currentTypedWord.append(letter)
            
            // Calculate progress
            let progress = Double(letterPosition) / Double(letters.count)
            
            // Check if the word is complete
            if letterPosition == letters.count {
                // Word is complete - IMMEDIATELY remove it from the words array
                let wordScore = calculateScore(word: word)
                // Save the ID before removal
                let completedWordId = wordId
                
                // Remove word immediately
                removeWord(wordId)
                
                // Update stats
                wordsCompleted += 1
                score += wordScore
                
                // Reset typing state
                resetWordTyping()
                
                // Return completion result
                return .completeMatch(wordId: completedWordId, score: wordScore)
            }
            
            return .partialMatch(wordId: wordId, progress: progress)
        } else {
            // Wrong letter, reset word typing
            resetWordTyping()
            return .noMatch
        }
    }
    func resetWordTyping() {
        activeWordId = nil
        letterPosition = 0
        currentTypedWord = ""
    }
    
    // Scoring and lives
    private func calculateScore(word: Word) -> Int {
        // Base score based on word length
        let baseScore = word.word.count * 10
        
        // Bonus for speed (inversely proportional to time taken to type)
        //let speedBonus = Int(20.0 / (elapsedTime - lastSpawnTime))
        
        // Difficulty multiplier
        let difficultyMultiplier: Int
        switch difficulty {
        case .easy:
            difficultyMultiplier = 1
        case .medium:
            difficultyMultiplier = 2
        case .hard:
            difficultyMultiplier = 3
        }
        //Add speedbonus somehow?
        return (baseScore) * difficultyMultiplier
    }
    
    func decrementLives() {
        lives -= 1
    }
    
    // Game status checks
    func isGameOver() -> Bool {
        return lives <= 0
    }
    
    func isGameWon() -> Bool {
        // Game is won when all words are cleared and no more words are available
        return words.isEmpty && wordGenerating.isPoolEmpty()
    }
    
    func handleBackspace() {
        if !currentTypedWord.isEmpty {
            currentTypedWord.removeLast()
            if letterPosition > 0 {
                letterPosition -= 1
            }
            
            // If we've deleted the entire word, reset active word
            if currentTypedWord.isEmpty {
                activeWordId = nil
            }
        }
    }
    
    // Debug functions
    func debugPrintGameState() {
        print("Game State:")
        print("- Words: \(words.count)")
        print("- Score: \(score)")
        print("- Lives: \(lives)")
        print("- Time: \(elapsedTime)")
        print("- WPM: \(wordsPerMinute)")
        print("- Typing: \(currentTypedWord)")
    }
}

// Extension to the WordGenerating protocol
extension WordGenerating {
    func isPoolEmpty() -> Bool {
        return false
    }
}
