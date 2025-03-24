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
            .animation(.linear(duration: typingVM.gameSpeed), value: animate)
            .onAppear(perform: {
                animate.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + typingVM.gameSpeed) {
                    let contains = typingVM.list.words.contains { contain in
                        return contain.word == word.word
                    }
                    if contains{
                        word.dead.toggle()
                        typingVM.list.words.removeAll(where: {$0.id == word.id})
                        typingVM.playerLife -= 1
                        typingVM.checkDead()
                    }
                }
            })
            .foregroundColor(.white)
            .font(.system(size:24, weight: .bold, design: .rounded))
        

            
            
        

    }
}
