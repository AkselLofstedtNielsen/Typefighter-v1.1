//
//  FallingWords.swift
//  WordGameIOS-V.1
//
//  Created by Aksel Nielsen on 2023-02-02.
//

import SwiftUI
import os

struct FallingWords: View {
    @ObservedObject var viewModel : SinglePlayerVM
    @State var isPlaying = true
        
    var body: some View {
        ZStack{
            if viewModel.gameRunning{
                ForEach(viewModel.gameList.words){ wrd in
                    WordView(viewModel: viewModel, word: wrd)
                }
                Rectangle()
                    .frame(height: 10.0)
                    .foregroundColor(.red)
                    .offset(y: 200)
                
            }else{
                Text("No game")
            }
        }
    }
    
    
}




