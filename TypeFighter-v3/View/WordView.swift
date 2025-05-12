//
//  WordView.swift
//  TypeFighter-v3
//
//  Updated on 2025-05-08.
//

import Foundation
import SwiftUI

struct WordView : View {
    @ObservedObject var viewModel : SinglePlayerVM
    var word : Word
    
    // Use an environment object for the falling words controller
    @EnvironmentObject var fallingController: FallingWordsController
    
    var body: some View {
        HighlightedText(word.word, matching: viewModel.userText)
            .offset(x: word.xPos, y: fallingController.isWordFalling(word.id) ? 200 : word.yPos)
            .animation(.linear(duration: viewModel.difficulty.fallingDuration), value: fallingController.isWordFalling(word.id))
            .onAppear(perform: {
                // Register word with falling controller
                fallingController.registerWord(word)
                
                // Schedule check for word reaching bottom
                DispatchQueue.main.asyncAfter(deadline: .now() + viewModel.difficulty.fallingDuration) {
                    let contains = viewModel.gameList.words.contains { contain in
                        return contain.id == word.id
                    }
                    
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
            })
            .onDisappear {
                // Make sure we unregister the word when the view disappears
                fallingController.unregisterWord(word.id)
            }
            .foregroundColor(.white)
            .font(.system(size:24, weight: .bold, design: .rounded))
    }
}
