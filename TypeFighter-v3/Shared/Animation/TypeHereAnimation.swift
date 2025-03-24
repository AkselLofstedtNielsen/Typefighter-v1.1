//
//  TypeHereAnimation.swift
//  WordGameIOS-V.1
//
//  Created by Aksel Nielsen on 2023-01-30.
//

import Foundation
import SwiftUI

struct typeHereAnimation: View{
    @State var bouncing = false

    var body: some View {
        VStack{
            VStack(spacing: 5){
                Text("Tap when ready")
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
}
