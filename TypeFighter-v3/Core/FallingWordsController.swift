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
    // Reference to game engine
    private weak var gameEngine: GameEngine?
    
    // Animation update timer
    private var animationTimer: Timer?
    
    // Animation states for words with individual timers
    @Published var wordAnimationStates: [UUID: WordFallingState] = [:]
    
    // Word tracking
    private var activeFallingWords: Set<UUID> = []
    
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
            
            // Initial state is not falling, with zero timer
            wordAnimationStates[word.id] = WordFallingState(isFalling: false, timer: 0)
            
            // Schedule animation to start with a small random delay
            DispatchQueue.main.async { [weak self] in
                self?.startFallingAnimation(for: word.id)
            }
        }
    }
    
    /// Remove a word from being tracked
    func unregisterWord(_ wordId: UUID) {
        activeFallingWords.remove(wordId)
        wordAnimationStates.removeValue(forKey: wordId)
    }
    
    func startFallingAnimation(for wordId: UUID) {
        // Randomize start time slightly to create more natural falling
        let randomDelay = Double.random(in: 0...0.5)
        wordAnimationStates[wordId] = WordFallingState(isFalling: true, timer: randomDelay)
        objectWillChange.send()
    }
    
    func isWordFalling(_ wordId: UUID) -> Bool {
        return wordAnimationStates[wordId]?.isFalling ?? false
    }
    
    func getWordAnimationTimer(_ wordId: UUID) -> Double {
        return wordAnimationStates[wordId]?.timer ?? 0
    }
    
    private func startAnimationTimer() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateWordAnimations()
        }
    }
    
    private func stopAnimationTimer() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func updateWordAnimations() {
        guard let engine = gameEngine, !engine.words.isEmpty else { return }
        
        // Ensure all words in the game engine are registered
        for word in engine.words {
            if !activeFallingWords.contains(word.id) {
                registerWord(word)
            }
            
            // Update animation timer for falling words
            if var animState = wordAnimationStates[word.id], animState.isFalling {
                animState.timer += 0.1
                wordAnimationStates[word.id] = animState
            }
        }
        
        // Clean up any words no longer in the game engine
        let currentWordIds = Set(engine.words.map { $0.id })
        let wordsToRemove = activeFallingWords.subtracting(currentWordIds)
        
        for wordId in wordsToRemove {
            unregisterWord(wordId)
        }
    }
}
