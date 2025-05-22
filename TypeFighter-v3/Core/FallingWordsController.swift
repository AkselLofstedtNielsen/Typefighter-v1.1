import Foundation
import SwiftUI

struct WordFallingState: Equatable {
    var isFalling: Bool
    var timer: Double
    
    // Explicitly conform to Equatable- comparing the two
    static func == (lhs: WordFallingState, rhs: WordFallingState) -> Bool {
        return lhs.isFalling == rhs.isFalling &&
               abs(lhs.timer - rhs.timer) < 0.1 // Allow small floating point differences
    }
}

class FallingWordsController: ObservableObject {
    private weak var gameEngine: GameEngine?
    
    private var animationTimer: Timer?
    
    // Animation states for words with individual timers
    @Published var wordAnimationStates: [UUID: WordFallingState] = [:]
    
    // Word tracking
    private var activeFallingWords: Set<UUID> = []
    
    // Track expired words to prevent multiple callbacks
    private var expiredWords: Set<UUID> = []
    
    // Callback for when words expire
    var onWordExpired: ((UUID) -> Void)?
    
    init(gameEngine: GameEngine? = nil) {
        self.gameEngine = gameEngine
    }
    
    func setGameEngine(_ engine: GameEngine) {
        self.gameEngine = engine
    }
    
    func start() {
        stopAnimationTimer()
        expiredWords.removeAll()
        startAnimationTimer()
    }
    
    func stop() {
        stopAnimationTimer()
        wordAnimationStates.removeAll()
        activeFallingWords.removeAll()
        expiredWords.removeAll()
    }
    
    func reset() {
        stop()
        wordAnimationStates.removeAll()
        activeFallingWords.removeAll()
        expiredWords.removeAll()
    }
    
    func registerWord(_ word: Word) {
        // Only add if not already tracked
        if !activeFallingWords.contains(word.id) {
            activeFallingWords.insert(word.id)
            
            // Start falling immediately with timer at 0
            wordAnimationStates[word.id] = WordFallingState(isFalling: true, timer: 0.0)
            
            print("Registered word '\(word.word)' (ID: \(word.id)) - starting timer immediately")
        }
    }
    
    func unregisterWord(_ wordId: UUID) {
        activeFallingWords.remove(wordId)
        expiredWords.remove(wordId)
        if let removedState = wordAnimationStates.removeValue(forKey: wordId) {
            print("Unregistered word (ID: \(wordId)) after \(removedState.timer) seconds")
        }
    }
    
    func isWordFalling(_ wordId: UUID) -> Bool {
        return wordAnimationStates[wordId]?.isFalling ?? false
    }
    
    func getWordAnimationTimer(_ wordId: UUID) -> Double {
        return wordAnimationStates[wordId]?.timer ?? 0
    }
    
    private func startAnimationTimer() {
        // CRITICAL FIX: Use main queue timer for UI updates
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.updateWordAnimations()
            }
        }
        
        // Ensure timer runs on main run loop
        if let timer = animationTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopAnimationTimer() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateWordAnimations() {
        guard let engine = gameEngine else { return }
        
        var hasUpdates = false
        var wordsToExpire: [UUID] = []
        
        // Ensure all words in the game engine are registered
        for word in engine.words {
            if !activeFallingWords.contains(word.id) {
                registerWord(word)
                hasUpdates = true
            }
        }
        
        // Update animation timer for falling words and check for expiration
        for wordId in activeFallingWords {
            if var animState = wordAnimationStates[wordId], animState.isFalling {
                animState.timer += 0.1
                wordAnimationStates[wordId] = animState
                hasUpdates = true
                
                // Check if word has expired based on difficulty and hasn't already been marked as expired
                if animState.timer >= engine.difficulty.fallingDuration && !expiredWords.contains(wordId) {
                    wordsToExpire.append(wordId)
                    expiredWords.insert(wordId) // Mark as expired to prevent duplicate calls
                    print("Word \(wordId) expired after \(animState.timer) seconds (limit: \(engine.difficulty.fallingDuration))")
                }
            }
        }
        
        // Handle expired words
        for wordId in wordsToExpire {
            // Stop the word from falling
            if var animState = wordAnimationStates[wordId] {
                animState.isFalling = false
                wordAnimationStates[wordId] = animState
            }
            
            // Notify about expiration - this should trigger word removal
            onWordExpired?(wordId)
            hasUpdates = true
        }
        
        // Clean up any words no longer in the game engine
        let currentWordIds = Set(engine.words.map { $0.id })
        let wordsToRemove = activeFallingWords.subtracting(currentWordIds)
        
        for wordId in wordsToRemove {
            unregisterWord(wordId)
            hasUpdates = true
        }
        
        // Force UI update if there were changes
        if hasUpdates {
            self.objectWillChange.send()
        }
    }
}
