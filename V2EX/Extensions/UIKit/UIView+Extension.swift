import UIKit

extension UIView {

    /// 给View加上圆角
    @IBInspectable var setCornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = newValue > 0
        }
    }

    /// 根据类查找视图
    ///
    /// - Parameter superViewClass: 类
    /// - Returns: View
    func findSuperView<T>(cls superViewClass : T.Type) -> T? {
        
        var xsuperView: UIView! = self.superview!
        var foundSuperView: UIView!
        
        while (xsuperView != nil && foundSuperView == nil) {
            
            if xsuperView.self is T {
                foundSuperView = xsuperView
            } else {
                xsuperView = xsuperView.superview
            }
        }
        return foundSuperView as? T
    }


    @discardableResult
    public func addSubviews(_ subviews: UIView...) -> UIView{
        subviews.forEach(addSubview)
        return self
    }
    
    @discardableResult
    public func addSubviews(_ subviews: [UIView]) -> UIView{
        subviews.forEach (addSubview)
        return self
    }

    /// 删除所有View
    public func removeAllSubviews() {
        while subviews.count != 0 {
            subviews.last?.removeFromSuperview()
        }
    }
    
    public func responderViewController() -> UIViewController {
        var responder: UIResponder!
        var nextResponder = superview?.next
        repeat {
            responder = nextResponder
            nextResponder = nextResponder?.next
            
        } while !(responder.isKind(of: UIViewController.self))
        return responder as! UIViewController
    }

    public func shake() {
        self.transform = CGAffineTransform(translationX: 10, y: 0)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 50, options: [.curveEaseOut, .beginFromCurrentState, .allowUserInteraction], animations: {
            self.transform = .identity
        }, completion: nil)
    }
    
    /// Create a shake effect.
    ///
    /// - Parameters:
    ///   - count: Shakes count. Default is 2.
    ///   - duration: Shake duration. Default is 0.15.
    ///   - translation: Shake translation. Default is 5.
    func shake(count: Float = 2, duration: TimeInterval = 0.15, translation: Float = 5) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = count
        animation.duration = (duration) / TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation
        
        self.layer.add(animation, forKey: "shake")
    }
    

    /// 使用视图的alpha创建一个淡出动画
    public func fadeOut(_ duration: TimeInterval = 0.4, delay: TimeInterval = 0.0, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }

    /// 使用视图的alpha创建一个淡入动画
    public func fadeIn(_ duration: TimeInterval = 0.4, delay: TimeInterval = 0.0, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)
    }

    public func addShadow(with color: UIColor) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 0, height: 5)
    }

    /// Removes specified set of constraints from the views in the receiver's subtree and from the receiver itself.
    ///
    /// - parameter constraints: A set of constraints that need to be removed.
    public func removeConstraintsFromSubtree(_ constraints: Set<NSLayoutConstraint>) {
        var constraintsToRemove = [NSLayoutConstraint]()
        
        for constraint in self.constraints {
            if constraints.contains(constraint) {
                constraintsToRemove.append(constraint)
            }
        }
        
        self.removeConstraints(constraintsToRemove)
        
        for view in self.subviews {
            view.removeConstraintsFromSubtree(constraints)
        }
    }
    
    /// Helper method to instantiate a nib file.
    ///
    /// - Parameter bundle: The bundle where the nib is located, by default we'll use the main bundle.
    /// - Returns: Returns an instance of the nib as a UIView.
    class func instanceFromNib<T: UIView>(bundle: Bundle = .main) -> T {
        return UINib(nibName: String(describing: T.self), bundle: bundle).instantiate(withOwner: nil, options: nil)[0] as! T
    }
}
