//
//  GameStateMachine.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-04-15.
//

class GameStateMachine {
    private(set) var currentState: GameState = .notStarted
    
    func transition(to newState: GameState) {
        // Validate allowed transitions
        guard isValidTransition(from: currentState, to: newState) else {
            return
        }
        
        // Perform exit actions for current state
        switch currentState {
        case .playing:
            // Stop timers, save progress, etc.
            break
        default:
            break
        }
        
        // Perform entry actions for new state
        switch newState {
        case .playing:
            // Start timers, reset values, etc.
            break
        default:
            break
        }
        
        currentState = newState
    }
    
    private func isValidTransition(from: GameState, to: GameState) -> Bool {
        // Define valid state transitions
        switch (from, to) {
        case (.notStarted, .playing),
             (.playing, .paused),
             (.paused, .playing),
             (.playing, .won),
             (.playing, .lost),
             (.won, .notStarted),
             (.lost, .notStarted):
            return true
        default:
            return false
        }
    }
}
