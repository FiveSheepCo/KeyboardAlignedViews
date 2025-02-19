import SwiftUI
import SwiftUIElements

/// A keyboard aligned scrollview with a footer that contains a text view, suitable for chat views.
public struct KAScrollViewWithTextViewFooter<
    ScrollContent: View,
    BottomContent: View,
    Background: View,
    ScrollViewResult: View
>: View {
    let placeholder: String
    @Binding var text: String
    let externalEditingBinding: Binding<Bool>?
    @State var isEditing: Bool = false
    
    let scrollContent: () -> ScrollContent
    let footer: (KATextView) -> BottomContent
    let footerBackground: () -> Background
    let scrollViewCustomizer: (KAScrollView<ScrollContent>) -> ScrollViewResult
    
    /// Initializes a new `KAScrollViewWithTextViewFooter`.
    /// - Parameters:
    ///   - placeholder: The placeholder the text field shows before content is entered.
    ///   - text: The text the text field contains.
    ///   - isEditing: Binding to the editing state of the text view.
    ///   - scrollContent: The scroll content that covers most of the screen.
    ///   - footer: The footer of the view. Includes a `KATextView` instance that represents the resizable text view.
    ///   - footerBackground: The background for the Footer. Blur view with system Material by default.
    ///   - scrollViewCustomizer: An optional block to customize the scroll view with methods like `scrollPosition`. You can also not use the scroll view at all in certain scenarios, for example when no messages have been sent yet in a chat app.
    public init(
        placeholder: String,
        text: Binding<String>,
        isEditing: Binding<Bool>? = nil,
        @ViewBuilder scrollContent: @escaping () -> ScrollContent,
        @ViewBuilder footer: @escaping (KATextView) -> BottomContent,
        @ViewBuilder footerBackground: @escaping () -> Background = {
            Blur(.systemMaterial)
        },
        @ViewBuilder scrollViewCustomizer: @escaping (KAScrollView<ScrollContent>) -> ScrollViewResult
    ) {
        self.placeholder = placeholder
        self._text = text
        self.externalEditingBinding = isEditing
        self.scrollContent = scrollContent
        self.footer = footer
        self.footerBackground = footerBackground
        self.scrollViewCustomizer = scrollViewCustomizer
    }
    
    /// Initializes a new `KAScrollViewWithTextViewFooter`.
    /// - Parameters:
    ///   - placeholder: The placeholder the text field shows before content is entered.
    ///   - text: The text the text field contains.
    ///   - isEditing: Binding to the editing state of the text view.
    ///   - scrollContent: The scroll content that covers most of the screen.
    ///   - footer: The footer of the view. Includes a `KATextView` instance that represents the resizable text view.
    ///   - footerBackground: The background for the Footer. Blur view with system Material by default.
    public init(
        placeholder: String,
        text: Binding<String>,
        isEditing: Binding<Bool>? = nil,
        @ViewBuilder scrollContent: @escaping () -> ScrollContent,
        @ViewBuilder footer: @escaping (KATextView) -> BottomContent,
        @ViewBuilder footerBackground: @escaping () -> Background = {
            Blur(.systemMaterial)
        }
    ) where ScrollViewResult == KAScrollView<ScrollContent> {
        self.placeholder = placeholder
        self._text = text
        self.externalEditingBinding = isEditing
        self.scrollContent = scrollContent
        self.footer = footer
        self.footerBackground = footerBackground
        self.scrollViewCustomizer = { $0 }
    }
    
    public var body: some View {
        ResizableTextViewContainer(
            placeholder: placeholder,
            text: $text,
            isEditing: externalEditingBinding ?? $isEditing,
            scrollContent: scrollContent,
            footer: footer,
            footerBackground: footerBackground,
            scrollViewCustomizer: scrollViewCustomizer
        )
        .ignoresSafeArea()
    }
}
