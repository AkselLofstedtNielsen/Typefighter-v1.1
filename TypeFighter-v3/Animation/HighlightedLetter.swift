//
//  HighlightedLetter.swift
//  WordGameIOS-V.1
//
//  Created by Aksel Nielsen on 2023-01-30.
//

import Foundation
import SwiftUI

struct HighlightedText: View {
//Simple struct for the highlighted letters in the words, FIX- All letters that match are highlighted and not following the current word
let text: String
let matching: String

init(_ text: String, matching: String) {
    self.text = text
    self.matching = matching
}

var body: some View {
    let tagged = text.replacingOccurrences(of: self.matching, with: "<SPLIT>>\(self.matching)<SPLIT>")
    let split = tagged.components(separatedBy: "<SPLIT>")
    return split.reduce(Text("")) { (a, b) -> Text in
        guard !b.hasPrefix(">") else {
            return a + Text(b.dropFirst()).foregroundColor(.purple)
        }
        return a + Text(b)
    }
  }
}
