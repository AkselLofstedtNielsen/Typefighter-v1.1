import Foundation
import SwiftUI

struct WordFallingState: Equatable {
    var isFalling: Bool
    var timer: Double
    
    // Explicitly conform to Equatable
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
        startAnimationTimer()
    }
    
    func stop() {
        stopAnimationTimer()
        wordAnimationStates.removeAll()
        activeFallingWords.removeAll()
    }
    
    func reset() {
        stop()
        wordAnimationStates.removeAll()
        activeFallingWords.removeAll()
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
    
    /// Remove a word from being tracked
    func unregisterWord(_ wordId: UUID) {
        activeFallingWords.remove(wordId)
        if let removedState = wordAnimationStates.removeValue(forKey: wordId) {
            print("Unregistered word (ID: \(wordId)) after \(removedState.timer) seconds")
        }
    }
    
    func startFallingAnimation(for wordId: UUID) {
        // This method is no longer needed since we start falling immediately in registerWord
        if wordAnimationStates[wordId] != nil {
            wordAnimationStates[wordId]?.isFalling = true
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
        var expiredWords: [UUID] = []
        
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
                
                // Check if word has expired based on difficulty
                if animState.timer > engine.difficulty.fallingDuration {
                    expiredWords.append(wordId)
                    print("Word \(wordId) expired after \(animState.timer) seconds (limit: \(engine.difficulty.fallingDuration))")
                }
                
                // Debug print every second
                if Int(animState.timer * 10) % 10 == 0 {
                    print("Word ID \(wordId) timer: \(String(format: "%.1f", animState.timer))s")
                }
            }
        }
        
        // Handle expired words
        for wordId in expiredWords {
            // Stop the word from falling
            if var animState = wordAnimationStates[wordId] {
                animState.isFalling = false
                wordAnimationStates[wordId] = animState
            }
            
            // Notify about expiration
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
