
//  FallingWordsController
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-05-08.
//

import Foundation
import SwiftUI

/// Controls the falling behavior of words to ensure consistent animation
class FallingWordsController: ObservableObject {
    // Reference to game engine
    //using weak to avoid memory leaks
    private weak var gameEngine: GameEngine?
    
    // Animation update timer
    private var animationTimer: Timer?
    
    // Animation states for words
    @Published var wordAnimationStates: [UUID: Bool] = [:]
    
    // Word tracking
    private var activeFallingWords: Set<UUID> = []
    
    init(gameEngine: GameEngine? = nil) {
        self.gameEngine = gameEngine
    }
    
    /// Set the game engine reference
    func setGameEngine(_ engine: GameEngine) {
        self.gameEngine = engine
    }
    
    /// Start the animation controller
    func start() {
        stopAnimationTimer()
        startAnimationTimer()
    }
    
    /// Stop the animation controller
    func stop() {
        stopAnimationTimer()
        wordAnimationStates.removeAll()
        activeFallingWords.removeAll()
    }
    
    /// Reset the controller state
    func reset() {
        stop()
        wordAnimationStates.removeAll()
        activeFallingWords.removeAll()
    }
    
    /// Add a word to be managed by the controller
    func registerWord(_ word: Word) {
        // Only add if not already tracked
        if !activeFallingWords.contains(word.id) {
            activeFallingWords.insert(word.id)
            
            // Initial state is not falling
            wordAnimationStates[word.id] = false
            
            // Schedule animation to start immediately
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
    
    /// Start the falling animation for a specific word
    func startFallingAnimation(for wordId: UUID) {
        wordAnimationStates[wordId] = true
        objectWillChange.send()
    }
    
    /// Get animation state for a word
    func isWordFalling(_ wordId: UUID) -> Bool {
        return wordAnimationStates[wordId] ?? false
    }
    
    /// Start the animation timer
    private func startAnimationTimer() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.checkAndUpdateAnimations()
        }
    }
    
    /// Stop the animation timer
    private func stopAnimationTimer() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    /// Check and update animations if needed
    private func checkAndUpdateAnimations() {
        guard let engine = gameEngine, !engine.words.isEmpty else { return }
        
        // Ensure all words in the game engine are registered
        for word in engine.words {
            if !activeFallingWords.contains(word.id) {
                registerWord(word)
            }
            
            // If a word isn't falling yet, make it fall
            if wordAnimationStates[word.id] == false {
                startFallingAnimation(for: word.id)
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
