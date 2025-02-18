import SwiftUI

struct TextViewRepresentable: UIViewRepresentable {
    enum Constants {
        static let maxHeight: CGFloat = 200
    }
    
    @Binding var height: CGFloat
    @Binding var text: String
    let inputAccessoryView: UIView
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        // TextView properties
        textView.isScrollEnabled = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = context.coordinator
        
        // Remove all padding
        textView.textContainerInset = .zero
        textView.contentInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.inputAccessoryView = inputAccessoryView
        
        // Delegate height adjustment to the coordinator
        context.coordinator.adjustHeight(of: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextViewRepresentable
        private var heightConstraint: NSLayoutConstraint?
        
        init(_ parent: TextViewRepresentable) {
            self.parent = parent
        }

        func adjustHeight(of textView: UITextView) {
            // Calculate the required height for the content
            let fittingSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
            let height = min(fittingSize.height, Constants.maxHeight)
            
            // Update or create the height constraint
            if let existingConstraint = heightConstraint {
                existingConstraint.constant = height
            } else {
                let newConstraint = textView.heightAnchor.constraint(equalToConstant: height)
                newConstraint.isActive = true
                heightConstraint = newConstraint
            }
            Task { @MainActor in
                self.parent.height = height
            }
            
            // Enable or disable scrolling based on content size
            textView.isScrollEnabled = fittingSize.height > Constants.maxHeight
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
