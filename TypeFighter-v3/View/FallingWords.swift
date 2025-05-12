//
//  FallingWords.swift
//  TypeFighter-v3
//
//  Updated on 2025-05-08.
//

import SwiftUI
import os

struct FallingWords: View {
    @ObservedObject var viewModel : SinglePlayerVM
    @StateObject private var fallingController = FallingWordsController()
    
    var body: some View {
        ZStack {
            if viewModel.gameRunning {
                ForEach(viewModel.gameList.words) { word in
                    WordView(viewModel: viewModel, word: word)
                }
                
                Rectangle()
                    .frame(height: 10.0)
                    .foregroundColor(.red)
                    .offset(y: 200)
            } else {
                Text("No game")
            }
        }
        .environmentObject(fallingController)
        .onAppear {
            // Set the game engine reference and start controller
            fallingController.setGameEngine(viewModel.getGameEngine())
            fallingController.start()
        }
        .onDisappear {
            fallingController.stop()
        }
    }
}
