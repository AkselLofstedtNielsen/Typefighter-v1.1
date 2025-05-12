//
//  SettingsView.swift
//  TypeFighter-v3
//
//  Created by Aksel Nielsen on 2025-04-07.
//

import SwiftUICore
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    @AppStorage("playerName") private var playerName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Player")) {
                    TextField("Player Name", text: $playerName)
                }
                
                Section(header: Text("Game Settings")) {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                    Toggle("Haptic Feedback", isOn: $hapticFeedback)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
