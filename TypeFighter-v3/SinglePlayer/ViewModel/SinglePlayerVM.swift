//
//  SinglePlayerVM.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-03-24.
//

import Foundation

class SinglePlayerVM : ObservableObject {

    @Published var playerLife : Int = 3

    @Published var timePlayed = 0.0

    
    @Published var isTimerRunning = false
    @Published var gameRunning = false
    @Published var WPS : Double = 0.0
    
    @Published var userText = ""
    @Published var wordFound = false
    @Published var id = UUID()
    @Published var letterPosition = 1
    
    @Published var list = WordList()
    
    @Published var gameSpeed : Double = 9.0
    
    @Published var gameWon = false
    @Published var gameLost = false
    

    
    func testing(letter: Character) {
        if wordFound{
            guard let index = list.words.firstIndex(where: {$0.id == id}) else { return }
            
            print("i ord: \(list.words[index].word)")
            
            let wordInLetters = list.words[index].letters
            
            if wordInLetters[letterPosition] == letter{
                if letterPosition == wordInLetters.count - 1{
                    print("Ord skrivet")
                    resetWord()
                    list.words.remove(at: index)
                    
                    if list.gameWords.isEmpty && list.words.isEmpty{
                    
                        gameWon = true
                        stopGame()
  
                    }
                    
                }else{
                    print("Rätt")
                    letterPosition += 1
                }
                
            }else{
                print("Fel")
            }
            
        }
        if !wordFound{
            for word in list.words{
                if word.letter == letter{
                    print("Ja")
                    id = word.id
                    wordFound = true
                    break
                }else{
                    print("Nej")
                }
            }
        }
        
      }
    func addWordToGame(){
        let check: Double = timePlayed .truncatingRemainder(dividingBy: 2.0)
        let checkRounded = check.roundToDecimal(1)
        if  checkRounded == 0.1{
            list.addRandomWord()
        }
    }
    
      func resetWord() {
          letterPosition = 1
          userText = ""
          wordFound = false
      }
      
      func stopGame() {
          timePlayed = 0
          isTimerRunning = false
          gameRunning = false
      }
      
      func restartGame() {
          gameWon = false
          gameLost = false
          list.fillList()
          list.startPositions()
          
          gameRunning = true
          isTimerRunning = true
          timePlayed = 0.0
          playerLife = 3
      }
    func checkDead(){
        if playerLife == 0{
            list.clearAll()
            stopGame()
            gameLost = true
            
        }
        
    }
    
    
  }




   






