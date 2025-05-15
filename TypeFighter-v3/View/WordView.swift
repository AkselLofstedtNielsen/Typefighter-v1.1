import Foundation
import SwiftUI

struct WordView : View {
    @ObservedObject var viewModel : SinglePlayerVM
    var word : Word
    
    // Use an environment object for the falling words controller
    @EnvironmentObject var fallingController: FallingWordsController
    
    var body: some View {
        HighlightedText(word.word, matching: viewModel.userText)
            .offset(x: word.xPos, y: calculateYPosition())
            .animation(.linear(duration: viewModel.difficulty.fallingDuration), value: calculateYPosition())
            .onAppear(perform: {
                // Register word with falling controller
                fallingController.registerWord(word)
            })
            .onDisappear {
                // Unregister the word from the falling controller
                fallingController.unregisterWord(word.id)
            }
            .foregroundColor(.white)
            .font(.system(size:24, weight: .bold, design: .rounded))
            .onChange(of: fallingController.wordAnimationStates[word.id]) { _ in
                checkWordFall()
            }
    }
    
    private func calculateYPosition() -> CGFloat {
        guard let animState = fallingController.wordAnimationStates[word.id] else {
            return word.yPos
        }
        
        // Get screen dimensions
        let screenHeight = UIScreen.main.bounds.height
        
        // Calculate the falling distance - from top to the red line (which is at 35% screen height)
        let fallDistance = screenHeight * 0.5
        
        if animState.isFalling {
            // Calculate progress as a percentage of the falling duration
            let progress = min(animState.timer / viewModel.difficulty.fallingDuration, 1.0)
            
            // Calculate the position based on progress
            // Start at the initial position (typically negative or 0) and move down
            return word.yPos + (fallDistance * CGFloat(progress))
        }
        
        return word.yPos
    }
    
    private func checkWordFall() {
        guard let animState = fallingController.wordAnimationStates[word.id],
              animState.isFalling else {
            return
        }
        
        // Get screen dimensions
        let screenHeight = UIScreen.main.bounds.height
        
        // Reference the red line position (35% of screen height as defined in FallingWords.swift)
        let gameOverLineY = screenHeight * 0.35
        
        // Calculate the falling distance and progress
        let fallDistance = screenHeight * 0.5
        let progress = min(animState.timer / viewModel.difficulty.fallingDuration, 1.0)
        
        // Calculate current position
        let currentYPos = word.yPos + (fallDistance * CGFloat(progress))
        
        // Check if word has reached the game over line
        if currentYPos >= gameOverLineY {  // No need for buffer; use exact line position
            let contains = viewModel.gameList.words.contains { $0.id == word.id }
            
            if contains {
                print("Word \(word.word) reached bottom at position \(currentYPos), game over line is at \(gameOverLineY)")
                
                // Mark word as dead
                word.dead = true
                
                // Tell the view model this word was missed (this will handle life decrement)
                viewModel.wordMissed(wordId: word.id)
                
                // Unregister the word from the falling controller
                fallingController.unregisterWord(word.id)
            }
        }
    }
}
