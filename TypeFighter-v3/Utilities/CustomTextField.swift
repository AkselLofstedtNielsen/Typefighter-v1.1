import SwiftUI
import Combine

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var onKeyPress: (String) -> Void
    var onBackspace: () -> Void
    
    //Custom textField without autocorrect, only uppercase, and ofcourse appearance :D
    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .allCharacters
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.textColor = .white
        textField.backgroundColor = .clear
        return textField
    }
    
    //Updates textField when swift needs to refresh the view, makes sure textfield displays correct value
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        uiView.text = text
    }
    
    //Creates coordinator obj that handles communication between uikid and swiftui, because uitextfield uses delegate pattern that swiftui doesnt support
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    //Magic=== Detects when user press backspace(empty string with range length > 0). Detects normal char input. Calls custom handlers. Manually updates swiftui bindings. 
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField
        
        init(_ parent: CustomTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Handle backspace
            if string.isEmpty && range.length > 0 {
                parent.onBackspace()
                return true
            }
            
            // Handle normal character input
            if !string.isEmpty {
                parent.onKeyPress(string)
            }
            
            // Update the binding directly for better control
            if let currentText = textField.text {
                let updatedText: String
                if string.isEmpty {
                    // Backspace: remove the character at the range
                    let textRange = Range(range, in: currentText)!
                    updatedText = currentText.replacingCharacters(in: textRange, with: "")
                } else {
                    // Insert the new character
                    let textRange = Range(range, in: currentText)!
                    updatedText = currentText.replacingCharacters(in: textRange, with: string)
                }
                
                // Update the binding
                DispatchQueue.main.async {
                    self.parent.text = updatedText
                }
            }
            
            return false // We handle the text update manually above
        }
    }
}
