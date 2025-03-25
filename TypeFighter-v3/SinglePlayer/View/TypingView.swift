//
//  TypingView.swift
//  WordGameIOS-V.1
//
//  Created by Aksel Nielsen on 2023-01-24.
//

import SwiftUI
import OSLog

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
                    
                    TextField("", text: $singlePlayerVM.userText)
                        .frame(height: 75).border(.purple)
                        .textFieldStyle(.automatic)
                        .multilineTextAlignment(.center)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.characters)
                        .foregroundColor(.white)
                        .onChange(of: singlePlayerVM.userText) { newValue in
                            singlePlayerVM.userText = singlePlayerVM.userText
                            
                            if singlePlayerVM.userText.last != nil{
                                singlePlayerVM.testing(letter: singlePlayerVM.userText.last!)
                            }
                            else{
                                singlePlayerVM.wordFound = false
                            }
                            
                        }
                }
            }

        }
    }





