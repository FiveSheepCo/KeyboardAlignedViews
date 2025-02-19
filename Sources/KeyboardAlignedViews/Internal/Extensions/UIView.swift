import UIKit

extension UIView {
    var windowMinY: CGFloat {
        return (superview?.windowMinY ?? 0) + self.frame.origin.y
    }
    
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
