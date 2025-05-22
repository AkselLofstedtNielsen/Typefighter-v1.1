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
                        .id(word.id)
                }
                
                Rectangle()
                    .frame(height: 10.0)
                    .foregroundColor(.red)
                    .offset(y: UIScreen.main.bounds.height * 0.35) // Position relative to screen size
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
        .onChange(of: viewModel.gameRunning) { isRunning in
            if isRunning {
                fallingController.start()
            } else {
                fallingController.stop()
            }
        }
    }
}
