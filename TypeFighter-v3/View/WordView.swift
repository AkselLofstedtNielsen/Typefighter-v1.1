import Foundation
import SwiftUI

struct WordView : View {
    @ObservedObject var viewModel : SinglePlayerVM
    var word : Word
    
    // Use an environment object for the falling words controller
    @EnvironmentObject var fallingController: FallingWordsController
    
    // State to track if word has expired
    @State private var hasExpired = false
    
    var body: some View {
        HighlightedText(word.word, matching: viewModel.userText)
            .offset(x: word.xPos, y: calculateYPosition())
            // Only animate if word hasn't expired
            .animation(hasExpired ? .none : .linear(duration: viewModel.difficulty.fallingDuration), value: calculateYPosition())
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
    }
    
    private func calculateYPosition() -> CGFloat {
        guard let animState = fallingController.wordAnimationStates[word.id] else {
            return word.yPos
        }
        
        // Get screen dimensions
        let screenHeight = UIScreen.main.bounds.height
        
        // Define the game over line position (35% from top)
        let gameOverLineY = screenHeight * 0.35
        
        // If word has expired or stopped falling, keep it at the game over line
        if hasExpired || !animState.isFalling {
            return gameOverLineY
        } 
        
        if animState.isFalling {
            // Calculate progress based on time elapsed vs total falling duration
            let progress = min(animState.timer / viewModel.difficulty.fallingDuration, 1.0)
            
            // Calculate total falling distance from starting position to game over line
            let totalFallDistance = gameOverLineY - word.yPos
            
            // Calculate current position based on time progress
            let calculatedY = word.yPos + (totalFallDistance * CGFloat(progress))
            
            // Ensure word stops exactly at the finish line when time is up
            if progress >= 1.0 {
                hasExpired = true
                return gameOverLineY
            }
            
            return calculatedY
        }
        
        return word.yPos
    }
}
