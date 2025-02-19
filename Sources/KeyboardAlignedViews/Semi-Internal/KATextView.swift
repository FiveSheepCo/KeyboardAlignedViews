import SwiftUI

/// A text view that is used by `KAScrollViewWithTextViewFooter`. Use this through the `footer` view.
public struct KATextView: View {
    let placeholder: String
    @Binding var text: String
    @Binding var isEditing: Bool
    let inputAccessoryView: UIView
    
    @State private var height: CGFloat = 0
    
    public var body: some View {
        TextViewRepresentable(
            height: $height,
            text: $text,
            isEditing: $isEditing,
            inputAccessoryView: inputAccessoryView
        )
        .frame(height: height)
        .overlay(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
