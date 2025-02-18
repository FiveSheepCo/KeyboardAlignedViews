import UIKit

extension UIView {
    func getScrollView() -> UIScrollView? {
        if let scrollView = self as? UIScrollView {
            return scrollView
        }
        
        for subview in subviews {
            if let scrollView = subview.getScrollView() {
                return scrollView
            }
        }
        
        return nil
    }
}
