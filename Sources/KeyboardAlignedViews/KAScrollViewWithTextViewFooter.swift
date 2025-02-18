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
    let scrollContent: () -> ScrollContent
    let footer: (KATextView) -> BottomContent
    let footerBackground: () -> Background
    let scrollViewCustomizer: (KAScrollView<ScrollContent>) -> ScrollViewResult
    
    /// Initializes a new `KAScrollViewWithTextViewFooter`.
    /// - Parameters:
    ///   - placeholder: The placeholder the text field shows before content is entered.
    ///   - text: The text the text field contains.
    ///   - scrollContent: The scroll content that covers most of the screen.
    ///   - footer: The footer of the view. Includes a `KATextView` instance that represents the resizable text view.
    ///   - footerBackground: The background for the Footer. Blur view with system Material by default.
    ///   - scrollViewCustomizer: An optional block to customize the scroll view with methods like `scrollPosition`.
    public init(
        placeholder: String,
        text: Binding<String>,
        @ViewBuilder scrollContent: @escaping () -> ScrollContent,
        @ViewBuilder footer: @escaping (KATextView) -> BottomContent,
        @ViewBuilder footerBackground: @escaping () -> Background = {
            Blur(.systemMaterial)
        },
        @ViewBuilder scrollViewCustomizer: @escaping (KAScrollView<ScrollContent>) -> ScrollViewResult
    ) {
        self.placeholder = placeholder
        self._text = text
        self.scrollContent = scrollContent
        self.footer = footer
        self.footerBackground = footerBackground
        self.scrollViewCustomizer = scrollViewCustomizer
    }
    
    /// Initializes a new `KAScrollViewWithTextViewFooter`.
    /// - Parameters:
    ///   - placeholder: The placeholder the text field shows before content is entered.
    ///   - text: The text the text field contains.
    ///   - scrollContent: The scroll content that covers most of the screen.
    ///   - footer: The footer of the view. Includes a `KATextView` instance that represents the resizable text view.
    ///   - footerBackground: The background for the Footer. Blur view with system Material by default.
    public init(
        placeholder: String,
        text: Binding<String>,
        @ViewBuilder scrollContent: @escaping () -> ScrollContent,
        @ViewBuilder footer: @escaping (KATextView) -> BottomContent,
        @ViewBuilder footerBackground: @escaping () -> Background = {
            Blur(.systemMaterial)
        }
    ) where ScrollViewResult == AnyView {
        self.placeholder = placeholder
        self._text = text
        self.scrollContent = scrollContent
        self.footer = footer
        self.footerBackground = footerBackground
        self.scrollViewCustomizer = { AnyView($0) }
    }
    
    public var body: some View {
        ResizableTextViewContainer(
            placeholder: placeholder,
            text: $text,
            scrollContent: scrollContent,
            footer: footer,
            footerBackground: footerBackground,
            scrollViewCustomizer: scrollViewCustomizer
        )
        .ignoresSafeArea()
    }
}
