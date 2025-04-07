//
//  WordView.swift
//  WordGameIOS-V.1
//
//  Created by Aksel Nielsen on 2023-02-08.
//

import Foundation
import SwiftUI

struct WordView : View {
    @ObservedObject var typingVM : SinglePlayerVM
    var word : Word
    @State var animate = false
    @State var contains = false

    

    var body: some View{
        HighlightedText(word.word, matching: typingVM.userText)
            .offset(x: word.xPos, y: animate ? 200 : word.yPos)
            .animation(.linear(duration: typingVM.difficulty.fallingDuration), value: animate)
            .onAppear(perform: {
                print( "falling duration: " + typingVM.difficulty.rawValue)
                animate.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + typingVM.difficulty.fallingDuration) {
                    let contains = typingVM.gameList.words.contains { contain in
                        return contain.word == word.word
                    }
                    if contains{
                        word.dead.toggle()
                        typingVM.gameList.words.removeAll(where: {$0.id == word.id})
                        typingVM.playerLife -= 1
                        typingVM.checkDead()
                    }
                }
            })
            .foregroundColor(.white)
            .font(.system(size:24, weight: .bold, design: .rounded))
        

            
            
        

    }
}
