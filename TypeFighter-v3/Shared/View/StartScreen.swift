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
    
    
    var body: some View {
        
        if(singlePlayerShow){
            GameView(vm: singlePlayerVM, singlePlayerShow: $singlePlayerShow)
        }else{
            
            ZStack{
                VStack{
                    HStack{
                        Spacer()
                        
                        Button(action:{
                            
                        }){
                            Image(systemName: "person.circle")
                                .frame(width: 35.0,height: 35.0)
                                .foregroundColor(.white)
                            
                        }
                        .buttonStyle(.bordered)
                        .background(Color.purple)
                        
                        
                        
                    }//_Hstack
                    Spacer()
                    
                    Text("TYPE FIGHT")
                        .font(.system(size: 30))
                        .bold()
                        .foregroundColor(.white)
                    Spacer()
                    VStack{
                        ForEach(singlePlayerVM.gameList.gameWords){ wrd in
                            Text(wrd.word).background(Color.white)
                            
                        }
                    }
                    Button(action:{
                        singlePlayerVM.restartGame()
                    }){
                        Text("Fill")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.bordered)
                    .background(Color.purple)
                    
                    Spacer()
                    
                    Button(action:{
                        
                    }){
                        Text("Multiplayer")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.bordered)
                    .background(Color.purple)
                    
                    Spacer()
                    
                    
                    Text("SINGLE PLAYER")
                        .foregroundColor(.white)
                    
                    HStack{
                        Spacer()
                        
                        Button(action:{
                            singlePlayerVM.gameSpeed = 9.0
                            singlePlayerShow.toggle()
                        }){
                            Text("Easy")
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.bordered)
                        .background(Color.purple)
                        
                        Spacer()
                        
                        Button(action:{
                            singlePlayerVM.gameSpeed = 6.5
                            singlePlayerShow.toggle()
                        }){
                            Text("Medium")
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.bordered)
                        .background(Color.purple)
                        
                        Spacer()
                        
                        Button(action:{
                            singlePlayerVM.gameSpeed = 4.0
                            singlePlayerShow.toggle()
                        }){
                            Text("Hard")
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.bordered)
                        .background(Color.purple)
                        
                        Spacer()
                        
                        
                    }//_Hstack
                    
                    Spacer()
                }//_VStack
                
            }
            .background(Color.black)
        }
    }
}


