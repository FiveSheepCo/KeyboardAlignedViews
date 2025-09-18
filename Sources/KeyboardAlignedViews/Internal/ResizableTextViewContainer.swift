import UIKit
import SwiftUI
import FiveKit

struct ResizableTextViewContainer<
    ScrollContent: View,
    BottomContent: View,
    Background: View,
    ScrollViewResult: View,
    ScrollViewOverlay: View
>: UIViewControllerRepresentable {
    let placeholder: String
    @Binding var text: String
    @Binding var isEditing: Bool
    let scrollContent: () -> ScrollContent
    let bottomContent: (KATextView) -> BottomContent
    let background: () -> Background
    let scrollViewCustomizer: (KAScrollView<ScrollContent>) -> ScrollViewResult
    let scrollViewOverlay: () -> ScrollViewOverlay
    
    @State var scrollViewModel: ScrollViewHolderModel = ScrollViewHolderModel()
    
    init(
        placeholder: String,
        text: Binding<String>,
        isEditing: Binding<Bool>,
        @ViewBuilder scrollContent: @escaping () -> ScrollContent,
        @ViewBuilder footer: @escaping (KATextView) -> BottomContent,
        @ViewBuilder footerBackground: @escaping () -> Background,
        @ViewBuilder scrollViewCustomizer: @escaping (KAScrollView<ScrollContent>) -> ScrollViewResult,
        @ViewBuilder scrollViewOverlay: @escaping () -> ScrollViewOverlay
    ) {
        self.placeholder = placeholder
        self._text = text
        self._isEditing = isEditing
        self.scrollContent = scrollContent
        self.bottomContent = footer
        self.background = footerBackground
        self.scrollViewCustomizer = scrollViewCustomizer
        self.scrollViewOverlay = scrollViewOverlay
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Custom SwiftUI Content View in ScrollView
        let scrollHostingController = UIHostingController(
            rootView: scrollViewCustomizer(
                KAScrollView(
                    model: scrollViewModel,
                    scrollContent: scrollContent
                )
            )
            .overlay {
                OverlayView(model: scrollViewModel, overlay: scrollViewOverlay)
            }
        )
        scrollHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let scrollHostingView = scrollHostingController.view!
        viewController.view.addSubview(scrollHostingView)
        
        // Accessory View
        let accessoryView = DetectionAccessoryView()
        accessoryView.backgroundColor = .clear
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        
        // Background Hosting Controller
        let backgroundHostingController = UIHostingController(
            rootView: background().ignoresSafeArea()
        )
        backgroundHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(backgroundHostingController.view)
        let backgroundView = backgroundHostingController.view!
        backgroundView.backgroundColor = .clear

        if #available(iOS 26, macOS 26, *) {
            backgroundView.cornerConfiguration = .uniformCorners(radius: .containerConcentric())
            backgroundView.layer.masksToBounds = true
        }

        // Bottom Hosting Controller
        var bottomLayoutConstraint: NSLayoutConstraint!
        let bottomHostingController = UIHostingController(
            rootView: bottomContent(
                KATextView(
                    placeholder: placeholder,
                    text: $text,
                    isEditing: $isEditing,
                    inputAccessoryView: accessoryView
                )
            )
            .sizeReader(onSizeChange: { newSize in
                let old = scrollViewModel.height
                scrollViewModel.height = newSize.height
                context.coordinator.update(oldHeight: old)
            })
        )
        let bottomView = bottomHostingController.view!
        bottomLayoutConstraint = bottomView.heightAnchor.constraint(equalToConstant: 20)
        bottomLayoutConstraint.isActive = true
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(bottomView)
        bottomView.backgroundColor = .clear

        let guide = viewController.view.keyboardLayoutGuide
        
        let bottomConstraint = bottomView.bottomAnchor.constraint(lessThanOrEqualTo: guide.topAnchor)
        bottomConstraint.isActive = true
        accessoryView.detector.constraint = bottomConstraint
        accessoryView.detector.updater = {
            context.coordinator.update(oldHeight: scrollViewModel.height)
        }
        
        context.coordinator.bottomLayoutConstraint = bottomLayoutConstraint
        context.coordinator.scrollViewContainer = scrollHostingController
        context.coordinator.guide = guide

        // Activate constraints
        NSLayoutConstraint.activate([
            // Scroll View Constraints
            scrollHostingView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            scrollHostingView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            scrollHostingView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            scrollHostingView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor),
            
            // Background Hosting Controller Constraints
            backgroundView.topAnchor.constraint(equalTo: bottomView.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),

            // TextView Constraints
            bottomView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),

            // Accessory View Constraints
            accessoryView.heightAnchor.constraint(equalToConstant: 0)
        ])

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(model: scrollViewModel)
    }
    
    @MainActor
    class Coordinator {
        let model: ScrollViewHolderModel
        
        var scrollViewContainer: UIViewController?
        var guide: UIKeyboardLayoutGuide?
        var bottomLayoutConstraint: NSLayoutConstraint?
        
        private var observer: NSObjectProtocol?
        private var lastRecordedKeyboardMinY: CGFloat = CGFloat.greatestFiniteMagnitude
        
        init(model: ScrollViewHolderModel) {
            self.model = model
            
            observer = NotificationCenter.default.addObserver(
                forName: UIApplication.keyboardWillChangeFrameNotification,
                object: nil,
                queue: nil,
                using: keyboardWillShow(notification:)
            )
        }
        
        var scrollView: UIScrollView? {
            scrollViewContainer?.view.getScrollView()
        }
        
        nonisolated private func keyboardWillShow(notification: Notification) {
            guard
                let userInfo = notification.userInfo,
                let startFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
                let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let animationCurve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
            else {
                assertionFailure()
                return
            }
            
            MainActor.assumeIsolated {
                guard let scrollView else { return }
                
                // Scroll up when the keyboard shows
                let keyboardStartY = min(lastRecordedKeyboardMinY, startFrame.minY, scrollViewMaxY)
                let overflowChange = keyboardStartY - endFrame.minY
                
                // The space that is not filled with content
                let unfilledSpace = max(0, scrollView.visibleSize.height - scrollView.contentSize.height - scrollView.adjustedContentInset.vertical)
                let change = max(0, overflowChange - unfilledSpace)
                
                // Set the lastRecordedKeyboardMinY
                lastRecordedKeyboardMinY = endFrame.minY
                
                if change > 0 && duration > 0 {
                    // When we are at the very bottom, we have to temporarily push content up (maybe SwiftUI interop problems?)
                    model.scrollPushUpAdjustment = overflowChange
                    
                    UIView.animate(
                        withDuration: duration, delay: 0,
                        options: UIView.AnimationOptions(rawValue: animationCurve << 16)
                    ) {
                        scrollView.contentOffset.y += change
                    } completion: { _ in
                        self.model.scrollPushUpAdjustment = 0
                    }
                }
            }
        }
        
        /// The actual bottom edge of the scroll view
        var scrollViewMaxY: CGFloat {
            guard let scrollViewContainer else {
                assertionFailure()
                return 0
            }
            
            let bottomInset = scrollViewContainer.view.safeAreaInsets.bottom - scrollViewContainer.additionalSafeAreaInsets.bottom
            
            return (scrollViewContainer.view.windowMinY + scrollViewContainer.view.frame.maxY) - bottomInset
        }
        
        func update(oldHeight: CGFloat) {
            guard let guide, let bottomLayoutConstraint else {
                assertionFailure()
                return
            }
            
            let height = model.height
            guide.keyboardDismissPadding = height
            bottomLayoutConstraint.constant = height
            
            if oldHeight > 0 {
                scrollView?.contentOffset.y += height - oldHeight
            }
        }
    }
}

#Preview {
    KAScrollViewWithTextViewFooter(
        placeholder: "",
        text: .constant(""),
        scrollContent: {},
        footer: { textView in
            textView
        },
        footerBackground: {
            Color.red
        }
    )
}
