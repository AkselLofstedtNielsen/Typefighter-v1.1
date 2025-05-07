//
//  GameStateMachine.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-05-07.
//


import Foundation
import SwiftUI

class GameStateMachine: ObservableObject {
    @Published private(set) var currentState: GameState = .notStarted
    private var gameEngine: GameEngine?
    
    // Callback handlers for state changes
    var onGameStart: (() -> Void)?
    var onGamePause: (() -> Void)?
    var onGameResume: (() -> Void)?
    var onGameWin: (() -> Void)?
    var onGameLose: (() -> Void)?
    var onStateChange: ((GameState) -> Void)?
    
    // Initialize with optional game engine
    init(gameEngine: GameEngine? = nil) {
        self.gameEngine = gameEngine
    }
    
    // Set or update the game engine
    func setGameEngine(_ engine: GameEngine) {
        self.gameEngine = engine
    }
    
    // Attempt to transition to a new state
    func transition(to newState: GameState) {
        // Validate allowed transitions
        guard isValidTransition(from: currentState, to: newState) else {
            print("Invalid state transition: \(currentState) -> \(newState)")
            return
        }
        
        // Perform exit actions for current state
        performExitActions(from: currentState)
        
        // Perform entry actions for new state
        performEntryActions(to: newState)
        
        // Update the state
        currentState = newState
        onStateChange?(newState)
        
        // Log the transition
        print("Game state transition: \(currentState)")
    }
    
    // Define valid state transitions
    private func isValidTransition(from: GameState, to: GameState) -> Bool {
        switch (from, to) {
        case (.notStarted, .playing),
             (.playing, .paused),
             (.paused, .playing),
             (.playing, .won),
             (.playing, .lost),
             (.won, .notStarted),
             (.lost, .notStarted),
             (.paused, .notStarted):
            return true
        default:
            return false
        }
    }
    
    // Perform actions when exiting a state
    private func performExitActions(from state: GameState) {
        switch state {
        case .playing:
            // Stop gameplay, timers, etc.
            gameEngine?.stopGame()
        case .paused:
            // Clean up pause state if necessary
            break
        default:
            break
        }
    }
    
    // Perform actions when entering a state
    private func performEntryActions(to state: GameState) {
        switch state {
        case .notStarted:
            // Reset game state
            gameEngine?.resetGameState()
            
        case .playing:
            if currentState == .notStarted {
                // Start a new game
                gameEngine?.startGame()
                onGameStart?()
            } else if currentState == .paused {
                // Resume from pause
                gameEngine?.resumeGame()
                onGameResume?()
            }
            
        case .paused:
            // Pause game
            gameEngine?.pauseGame()
            onGamePause?()
            
        case .won:
            // Handle win condition
            gameEngine?.stopGame()
            onGameWin?()
            
        case .lost:
            // Handle lose condition
            gameEngine?.stopGame()
            onGameLose?()
        }
    }
    
    // Convenience methods for common transitions
    func startGame() {
        transition(to: .playing)
    }
    
    func pauseGame() {
        transition(to: .paused)
    }
    
    func resumeGame() {
        transition(to: .playing)
    }
    
    func endGameAsWon() {
        transition(to: .won)
    }
    
    func endGameAsLost() {
        transition(to: .lost)
    }
    
    func resetGame() {
        transition(to: .notStarted)
    }
    
    // Method to check game status and update state automatically
    func checkGameStatus() {
        guard currentState == .playing, let engine = gameEngine else { return }
        
        if engine.isGameOver() {
            transition(to: .lost)
        } else if engine.isGameWon() {
            transition(to: .won)
        }
    }
}

// Extension to support binding GameState to UI elements
extension GameState: Identifiable {
    var id: String { rawValue }
    
    var rawValue: String {
            switch self {
            case .notStarted: return "notStarted"
            case .playing: return "playing"
            case .paused: return "paused"
            case .won: return "won"
            case .lost: return "lost"
            }
        }
    
    var displayName: String {
        switch self {
        case .notStarted: return "Ready"
        case .playing: return "Playing"
        case .paused: return "Paused"
        case .won: return "Victory!"
        case .lost: return "Game Over"
        }
    }
    
    static var allCases: [GameState] {
        return [.notStarted, .playing, .paused, .won, .lost]
    }
}
