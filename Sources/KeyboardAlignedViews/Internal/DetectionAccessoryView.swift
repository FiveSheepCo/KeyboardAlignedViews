import UIKit

class DetectionAccessoryView: UIView {
    let detector: DetectionView
    
    init() {
        self.detector = DetectionView()
        
        super.init(frame: .zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if let window {
            window.addSubview(detector)
            detector.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
            detector.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
    }
}
