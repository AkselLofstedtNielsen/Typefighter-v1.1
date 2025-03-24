//
//  Word.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-03-24.
//

import Foundation

//a word in the wordlist
class Word : Identifiable, ObservableObject {
    var id = UUID()
    var word : String
    var xPos : CGFloat
    var dead : Bool = false
    @Published var yPos : CGFloat
    
    var letters : [Character]{
        let st = word
        let letArr = Array(st)
        return letArr
    }
    
    var letter : Character{
        return letters.first(where: { $0.isLetter }) ?? "#"
    }
    
    init(word: String, xPos: CGFloat, yPos: CGFloat) {
        self.word = word
        self.xPos = xPos
        self.yPos = yPos
    }
}
