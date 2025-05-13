//
//  WordList.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-03-24.
//


import Foundation
import UIKit

class WordListSinglePlayer: ObservableObject{
    @Published var words : [Word] = []
    @Published var gameWords : [Word] = []
    
    @WordListStorage(key: "localDBWords", defaultValue: []) var localDBWords : [String]
    
    
    func fillList(){
        //fill from local if empty check db somehow
        if gameWords.isEmpty{
            if localDBWords.isEmpty{
                // Fill default word list if nothing is saved
                print("Adding default words to local DB")
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
            
            print("Creating game words from local DB. Count: \(localDBWords.count)")
            for word in localDBWords{
                let newWord = Word(word: word, xPos: 0, yPos: 0)
                gameWords.append(newWord)
            }
            
            print("Game words after filling: \(gameWords.count)")
            setStartingPositions()
        }
    }
    
    func addWordToLocalDB(_ word: String){
        if !localDBWords.contains(word){
            localDBWords.append(word.uppercased())
        }
    }
    
    func addRandomWordToGame(){
        guard let word = gameWords.randomElement() else {
            print("No words available to add to game")
            return
        }
        
        let id = word.id
        addToWords(word: word)
        print("Added random word to game: \(word.word)")
        
        // Don't remove from gameWords - this could be causing the issue
        // gameWords.removeAll(where: {$0.id == id})
    }
    
    func setStartingPositions(){
            let xPositions : [CGFloat] = [-140, -120, -100, -80, -60, -40, 0, 30, 50, 70,90,130]
            let screenHeight = UIScreen.main.bounds.height
            let startYPos = -screenHeight * 0.1 // Position slightly above the visible area
            
            for word in gameWords{
                word.xPos = xPositions.randomElement()!
                word.yPos = startYPos
            }
        }
    
    func addToWords(word: Word){
        // Create a new word instance to avoid reference issues
        let newWord = Word(word: word.word, xPos: word.xPos, yPos: word.yPos)
        words.append(newWord)
        print("Added word to active words: \(newWord.word)")
    }
    
    func clearAll(){
        print("Clearing all words")
        words.removeAll()
        gameWords.removeAll()
    }
    
    // Debug function
    func printWordStatus() {
        print("=== WordList Status ===")
        print("Active words: \(words.count)")
        print("Game words pool: \(gameWords.count)")
    }
}
