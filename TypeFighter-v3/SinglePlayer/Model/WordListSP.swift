//
//  WordList.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-03-24.
//


import Foundation

class WordListSinglePlayer: ObservableObject{
    @Published var words : [Word] = []
    @Published var gameWords : [Word] = []
    
    @WordListStorage(key: "localDBWords", defaultValue: []) var localDBWords : [String]
    
    
    func fillList(){
        //fill from local if empty check db somehow
        if gameWords.isEmpty{
            if localDBWords.isEmpty{
                //Fill from DB
                //For now
                addWordToLocalDB("FLICKA")
                addWordToLocalDB("SKYMTA")
                addWordToLocalDB("GRILLA")
                addWordToLocalDB("SLÄPA")
                addWordToLocalDB("FLÄTA")
                addWordToLocalDB("ÄRTA")
                addWordToLocalDB("SKÅL")
                addWordToLocalDB("KRONA")
                addWordToLocalDB("SKYNDA")
                addWordToLocalDB("STUNGA")
                addWordToLocalDB("VÄNTA")
                addWordToLocalDB("DÄMPA")
                addWordToLocalDB("KLIVA")
                addWordToLocalDB("GRIMMA")
                addWordToLocalDB("JÄTTE")
                addWordToLocalDB("KAPPA")
                addWordToLocalDB("HEDRA")
                addWordToLocalDB("TÄNKA")
                addWordToLocalDB("SKRIVA")
                addWordToLocalDB("STÄLLA")
            }
            
            for word in localDBWords{
                gameWords.append(Word(word: word, xPos: 0, yPos: 0))
            }
            
        }
    }
    func addWordToLocalDB(_ word: String){
        if !localDBWords.contains(word){
            localDBWords.append(word.uppercased())
        }
    }
    func addRandomWordToGame(){
        guard let word = gameWords.randomElement() else {return}
        
        let id = word.id
        addToWords(word: word)
        gameWords.removeAll(where: {$0.id == id})
        
    }
    func setStartingPositions(){
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
