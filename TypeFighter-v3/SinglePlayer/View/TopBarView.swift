//
//  TopBarView.swift
//  WordGameIOS-V.1
//
//  Created by Aksel Nielsen on 2023-02-01.
//

import SwiftUI

struct TopBarView: View {
    @ObservedObject var vm: SinglePlayerVM
    @State var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var stringTime : String{
        return String(format: "%.1f", vm.elapsedTime)
    }
    
    var body: some View {
        HStack{
           
            if vm.gameRunning{
                ForEach(0..<vm.playerLife, id: \.self){_ in
                    Image(systemName: "heart")
                        .foregroundColor(.purple)
                }
                Spacer()
                Text("Time: \(stringTime)")
                    .bold()
                    .foregroundColor(.purple)
                    .onReceive(timer){ _ in
                        if vm.isTimerRunning{
                            vm.elapsedTime += 0.1
                            vm.addWordToGame()
                        }
                    }
            }
            
        }
    }
    
}
