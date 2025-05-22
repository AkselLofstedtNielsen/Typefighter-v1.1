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
            setupFallingController()
        }
        .onDisappear {
            fallingController.stop()
        }
        .onChange(of: viewModel.gameRunning) { isRunning in
            if isRunning {
                setupFallingController()
                fallingController.start()
            } else {
                fallingController.stop()
            }
        }
    }
    
    private func setupFallingController() {
        // Set the game engine reference
        fallingController.setGameEngine(viewModel.getGameEngine())
        
        // Set up the word expiration callback ONCE for ALL words
        // This handles any word that expires, regardless of which one it is
        fallingController.onWordExpired = { [weak viewModel] expiredWordId in
            print("FallingWords: Word expired with ID: \(expiredWordId)")
            DispatchQueue.main.async {
                viewModel?.wordMissed(wordId: expiredWordId)
            }
        }
        
        print("FallingController setup complete with callback")
    }
}
