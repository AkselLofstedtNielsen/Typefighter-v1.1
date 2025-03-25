//
//  GameView.swift
//  WordGameIOS-V.1
//
//  Created by Aksel Nielsen on 2023-02-08.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var vm : SinglePlayerVM
    @Binding var singlePlayerShow : Bool
    
    var body: some View {
        ZStack{
            VStack{
                TopBarView(vm: vm)
                Spacer()
                    .alert("Good job!" , isPresented: $vm.gameWon){
                        Button(action: {
                            vm.restartGame()
                        }){
                            Text("Try again")
                        }
                        Button(action:{
                            singlePlayerShow.toggle()
                        }){
                            Text("Back to homescreen")
                        }
                    }
                    .alert("Better luck next time!", isPresented: $vm.gameLost){
                        Button(action:{
                            vm.restartGame()
                        }){
                            Text("Try again")
                        }
                        Button(action:{
                            singlePlayerShow.toggle()
                        }){
                            Text("Back to homescreen")
                        }
                    }
                FallingWords(typingVM: vm)
                Spacer()
                TypingView(singlePlayerVM: vm)
            }
            .background(Color.black)

        }
    }

}

