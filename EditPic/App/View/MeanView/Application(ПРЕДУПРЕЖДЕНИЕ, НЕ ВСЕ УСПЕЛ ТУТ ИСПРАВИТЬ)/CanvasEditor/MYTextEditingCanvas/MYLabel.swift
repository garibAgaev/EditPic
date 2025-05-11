
import UIKit

class MYLabel: UILabel {

    private var computed_centerXConstraint: NSLayoutConstraint?
    private var computed_centerYConstraint: NSLayoutConstraint?

    var centerXConstraint: NSLayoutConstraint? {
        get { computed_centerXConstraint }
        set {
            computed_centerXConstraint?.isActive = false
            computed_centerXConstraint = newValue
            computed_centerXConstraint?.priority = .defaultHigh
            computed_centerXConstraint?.isActive = true
        }
    }
    var centerYConstraint: NSLayoutConstraint?{
        get { computed_centerYConstraint }
        set {
            computed_centerYConstraint?.isActive = false
            computed_centerYConstraint = newValue
            computed_centerXConstraint?.priority = .defaultHigh
            computed_centerYConstraint?.isActive = true
        }
    }


    required init?(coder: NSCoder) { fatalError() }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = true
    }
}
