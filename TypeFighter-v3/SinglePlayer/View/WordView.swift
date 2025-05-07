//
//  WordView.swift
//  WordGameIOS-V.1
//
//  Created by Aksel Nielsen on 2023-02-08.
//

import Foundation
import SwiftUI

struct WordView : View {
    @ObservedObject var viewModel : SinglePlayerVM
    var word : Word
    @State var animate = false
    @State var contains = false

    var body: some View{
        HighlightedText(word.word, matching: viewModel.userText)
            .offset(x: word.xPos, y: animate ? 200 : word.yPos)
            .animation(.linear(duration: viewModel.difficulty.fallingDuration), value: animate)
            .onAppear(perform: {
                print("Word appearing: \(word.word), falling duration: \(viewModel.difficulty.fallingDuration)")
                
                // Start the animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animate = true
                }
                
                // Check if word reaches bottom
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
                    }
                }
            })
            .foregroundColor(.white)
            .font(.system(size:24, weight: .bold, design: .rounded))
    }
}
