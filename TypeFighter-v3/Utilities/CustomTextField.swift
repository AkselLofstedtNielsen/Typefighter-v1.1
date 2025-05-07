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
        // Only update if different to avoid cycle
        if uiView.text != text {
            uiView.text = text
            // Place cursor at end of text for better typing experience
            if let newPosition = uiView.position(from: uiView.beginningOfDocument, offset: text.count) {
                uiView.selectedTextRange = uiView.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    //Creates coordinator obj that handles communication between uikid and swiftui, because uitextfield uses delegate pattern that swiftui doesnt support
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    //Magic=== Detects when user press backspace(empty string with range length > 0). Detects normal char input. Calls custom handlers. Manually updates swiftui bindings.
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField
        // Track if we're currently updating from external source
        var isExternalUpdate = false
        
        init(_ parent: CustomTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Check if this is an external update
            if isExternalUpdate {
                return true
            }
            
            // Handle backspace
            if string.isEmpty && range.length > 0 {
                parent.onBackspace()
                return true
            }
            
            // Handle normal character input
            if !string.isEmpty {
                parent.onKeyPress(string)
                return false // Handled by the onKeyPress callback
            }
            
            return true
        }
        
        // Add this method to handle text clearing more explicitly
        func textFieldDidChangeSelection(_ textField: UITextField) {
            // Make sure the binding matches the field, but only update if needed
            if let text = textField.text, text != parent.text {
                DispatchQueue.main.async {
                    self.parent.text = text
                }
            }
        }
    }
}
