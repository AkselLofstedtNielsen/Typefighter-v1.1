//
//  WordList.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-03-24.
//


import Foundation

//Wordlist = fylls av firebase, fyller resten av projekten.
class WordListSinglePlayer: ObservableObject{
    @Published var words : [Word] = []
    @Published var gameWords : [Word] = []
    
    
    
    func fillList(list: [String]){
        for wrd in list{
            gameWords.append(Word(word: wrd, xPos: 0, yPos: 0))
        }
    }
    func addRandomWord(){
        guard let word = gameWords.randomElement() else {return}
        
        let id = word.id
        addToWords(word: word)
        gameWords.removeAll(where: {$0.id == id})
        
    }
    func startPositions(){
        let xPositions : [CGFloat] = [-140, -120, -100, -80, -60, -40, 0, 30, 50, 70,90,130]
        for word in gameWords{
            word.xPos = xPositions.randomElement()!
            word.yPos = -400
        }
    }
    func addToWords(word: Word){
        words.append(word)
    }
    func clearAll(){
        words.removeAll()
        gameWords.removeAll()
    }

}
