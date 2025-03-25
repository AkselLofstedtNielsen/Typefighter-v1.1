//
//  TypeHereAnimation.swift
//  WordGameIOS-V.1
//
//  Created by Aksel Nielsen on 2023-01-30.
//

import Foundation
import SwiftUI

struct typeHereAnimation: View{
    @Binding var finished: Bool

    @State var bouncing = false
    @State var timeRemaining: Int = 5
    
    let countDownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack{
            VStack{
                VStack(spacing: 5){
                    Text("\(timeRemaining)")
                        .foregroundColor(.white)
                    Image(systemName: "arrow.down")
                        .foregroundColor(.white)
                }
                .offset(y: bouncing ? -5: -15)
                .animation(.easeIn(duration: 1).repeatForever())
                .onAppear(){
                    self.bouncing.toggle()
                }
            }
        }
        .onReceive(countDownTimer){time in
            if timeRemaining > 0{
                timeRemaining -= 1
            }else{
                finished = true
            }
        }
        
    }
}
