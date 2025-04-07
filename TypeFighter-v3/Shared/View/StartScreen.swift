//
//  StartScreen.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-03-24.
//


import SwiftUI

struct StartScreenView: View {
    @ObservedObject var singlePlayerVM = SinglePlayerVM()
    @State var singlePlayerShow = false
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var showSettings: Bool = false
    
    var body: some View {
        
        if(singlePlayerShow){
            GameView(vm: singlePlayerVM, singlePlayerShow: $singlePlayerShow)
        }else{
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Title
                    Text("TYPE FIGHTER")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .purple, radius: 10)
                    
                    // Game modes
                    VStack(spacing: 20) {
                        Text("GAME MODES")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top)
                        
                        // Single player button
                        Button(action: {
                            singlePlayerShow = true
                        }) {
                            Text("Single Player")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(12)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Multiplayer button - for future implementation
                        Button(action: {
                            // Future multiplayer implementation
                        }) {
                            Text("Multiplayer")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.5))
                                .cornerRadius(12)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .disabled(true) // Disabled until implemented
                    }
                    .padding(.horizontal, 30)
                    
                    // Difficulty selection
                    VStack(spacing: 15) {
                        Text("DIFFICULTY")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 10) {
                            ForEach(Difficulty.allCases) { difficulty in
                                Button(action: {
                                    //First for highlight then vm change
                                    selectedDifficulty = difficulty
                                    singlePlayerVM.difficulty = difficulty
                                }) {
                                    Text(difficulty.rawValue.capitalized)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            selectedDifficulty == difficulty ?
                                            Color.purple : Color.purple.opacity(0.3)
                                        )
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Settings button
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gear")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .sheet(isPresented: $showSettings) {
                        SettingsView()
                    }
                }
                .padding(.vertical, 50)
            }
            .transition(.opacity)
        }
    }
}
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}


