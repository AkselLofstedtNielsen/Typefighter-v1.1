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
            .animation(.linear(duration: viewModel.difficulty.fallingDuration), value: word.yPos)
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
        
        if animState.isFalling {
            // Calculate new Y position based on animation timer
            let progress = min(animState.timer / viewModel.difficulty.fallingDuration, 1.0)
            return CGFloat(progress * 200) // Assuming 200 is the bottom of the screen
        }
        
        return word.yPos
    }
    
    private func checkWordFall() {
        guard let animState = fallingController.wordAnimationStates[word.id],
              animState.isFalling,
              animState.timer >= viewModel.difficulty.fallingDuration else {
            return
        }
        
        let contains = viewModel.gameList.words.contains { $0.id == word.id }
        
        if contains {
            print("Word \(word.word) reached bottom")
            word.dead = true
            viewModel.gameList.words.removeAll(where: {$0.id == word.id})
            viewModel.playerLife -= 1
            viewModel.checkDead()
            
            // Unregister the word from the falling controller
            fallingController.unregisterWord(word.id)
        }
    }
}
