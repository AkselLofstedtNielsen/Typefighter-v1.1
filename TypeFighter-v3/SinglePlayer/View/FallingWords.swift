//
//  FallingWords.swift
//  WordGameIOS-V.1
//
//  Created by Aksel Nielsen on 2023-02-02.
//

import SwiftUI

struct FallingWords: View {
    @ObservedObject var typingVM : SinglePlayerVM
    @State var isPlaying = true



    var body: some View {
        ZStack{
            if typingVM.gameRunning{
                ForEach(typingVM.list.words){ wrd in
                    WordView(typingVM: typingVM, word: wrd)
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




