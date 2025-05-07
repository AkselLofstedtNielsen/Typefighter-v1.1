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
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
    
    var body: some View {
        ZStack{
            backgroundGradient
            
            
            VStack(spacing: 0){
                TopBarView(vm: vm)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: "0f3460").opacity(0.7))
                            .edgesIgnoringSafeArea(.top)                    )
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
                FallingWords(viewModel: vm)
                Spacer()
                TypingView(singlePlayerVM: vm)
            }
        }
    }
    
}

