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
        
        // Define the game over line position (35% from top as defined in FallingWords.swift)
        let gameOverLineY = screenHeight * 0.35
        
        if animState.isFalling {
            // Calculate progress based on time elapsed vs total falling duration
            let progress = min(animState.timer / viewModel.difficulty.fallingDuration, 1.0)
            
            // Calculate total falling distance from starting position to game over line
            let totalFallDistance = gameOverLineY - word.yPos
            
            // Calculate current position based on time progress
            return word.yPos + (totalFallDistance * CGFloat(progress))
        }
        
        return word.yPos
    }
    
    private func checkWordFall() {
        guard let animState = fallingController.wordAnimationStates[word.id],
              animState.isFalling else {
            return
        }
        
        // Check if the falling time has exceeded the difficulty duration
        if animState.timer >= viewModel.difficulty.fallingDuration {
            let contains = viewModel.gameList.words.contains { $0.id == word.id }
            
            if contains {
                print("Word \(word.word) fell for \(animState.timer) seconds (max: \(viewModel.difficulty.fallingDuration))")
                
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
