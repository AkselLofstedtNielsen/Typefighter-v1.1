//
//  ContentView.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-03-24.
//

import SwiftUI
import os

struct ContentView: View {
    @ObservedObject var singlePlayerVM = SinglePlayerVM()
    @State var singlePlayerShow: Bool = true
    
    var body: some View {
        ZStack{
            StartScreenView()
        }
    }
}
