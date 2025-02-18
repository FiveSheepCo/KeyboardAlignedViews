import UIKit

class DetectionView: UIView {
    var constraint: NSLayoutConstraint?
    var updater: () -> Void = {}
    
    init() {
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        constraint?.constant = 0 // Apparently this just needs to refresh, no need for calculations
        updater()
    }
}
