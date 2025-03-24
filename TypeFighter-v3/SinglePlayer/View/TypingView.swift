//
//  TypingView.swift
//  WordGameIOS-V.1
//
//  Created by Aksel Nielsen on 2023-01-24.
//

import SwiftUI

    struct TypingView: View {
        @ObservedObject var typingVM: SinglePlayerVM
        
        var body: some View {
            VStack{
                
                if !typingVM.gameRunning{
                    typeHereAnimation()
                }
                
                TextField("", text: $typingVM.userText)
                    .onTapGesture {
                        if !typingVM.gameRunning{
                            typingVM.restartGame()
                        }
                        
                    }
                    .frame(height: 75).border(.purple)
                    .textFieldStyle(.automatic)
                    .multilineTextAlignment(.center)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.characters)
                    .foregroundColor(.white)
                    .onChange(of: typingVM.userText) { newValue in
                        typingVM.userText = typingVM.userText
                        
                        if typingVM.userText.last != nil{
                            typingVM.testing(letter: typingVM.userText.last!)
                        }
                        else{
                            typingVM.wordFound = false
                        }
                        
                    }
            }
        }
    }





