import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
    var isEnableAlpha: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: base) { button, valid in
            button.isEnabled = valid
            button.alpha = valid ? 1.0 : 0.5
        }
    }
}
