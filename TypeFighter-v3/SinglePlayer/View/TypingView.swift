//
//  TypingView.swift
//  WordGameIOS-V.1
//
//  Created by Aksel Nielsen on 2023-01-24.
//

import SwiftUI
import OSLog

//FIXA !!!om man skriver säg AKSE och sedan backar ur till 0 och sedan börjar skriva ett nytt ord så stannar vi i AKSEL ordet. Fastnar i ord ibland?? HITTA FEL
struct TypingView: View {
    @ObservedObject var singlePlayerVM: SinglePlayerVM
    //@State var finished: Bool = false
    var body: some View {
        ZStack{
            VStack{
                //if !typingVM.gameRunning{
                //    //Bad laggy animation
                //    typeHereAnimation(
                //        finished: $finished
                //    )
                //}
                if !singlePlayerVM.gameRunning{
                    Button(action: {
                        singlePlayerVM.restartGame()
                    }) {
                        Text("Start")
                    }
                }
                
                CustomTextField(text: $singlePlayerVM.userText, onKeyPress: { char in
                    //handle keypresss
                    if let lastChar = char.last{
                        print("char: \(lastChar)")
                        
                        singlePlayerVM.testing(letter: lastChar)
                        
                    }
                }, onBackspace: {
                    // Handle backspace
                    singlePlayerVM.handleBackspace()
                    singlePlayerVM.resetWord()
                }
                )
                .frame(height: 75)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.purple, lineWidth: 2)
                )
                .padding()
            }
            
        }
        
    }
}





