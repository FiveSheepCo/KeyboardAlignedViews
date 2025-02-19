import SwiftUI

public struct KAScrollView<ScrollContent: View>: View {
    let model: ScrollViewHolderModel
    let scrollContent: () -> ScrollContent
    
    public var body: some View {
        ScrollView {
            scrollContent()
                .contentShape(Rectangle())
            Rectangle()
                .fill(Color.clear)
                .frame(height: model.scrollPushUpAdjustment)
        }
        .contentMargins(.bottom, model.height)
        .scrollDismissesKeyboard(.interactively)
        .scrollClipDisabled()
    }
}

public struct OverlayView<Overlay: View>: View {
    let model: ScrollViewHolderModel
    let overlay: () -> Overlay
    
    public var body: some View {
        overlay().padding(.bottom, model.height)
    }
}
