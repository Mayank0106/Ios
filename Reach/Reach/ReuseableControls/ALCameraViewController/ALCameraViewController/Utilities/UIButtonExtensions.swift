//
//  UIButtonExtensions.swift
//  ALCameraViewController
//
//  Copyright © 2016 zero. All rights reserved.
//

import UIKit

typealias ButtonAction = () -> Void

extension UIButton {

    private struct AssociatedKeys {
        static var ActionKey = "ActionKey"
    }

    private class ActionWrapper {
        let action: ButtonAction
        init(action: @escaping ButtonAction) {
            self.action = action
        }
    }

    var action: ButtonAction? {
        set(newValue) {
            removeTarget(self, action: #selector(performAction), for: .touchUpInside)
            var wrapper: ActionWrapper? = nil
            if let newValue = newValue {
                wrapper = ActionWrapper(action: newValue)
                addTarget(self, action: #selector(performAction), for: .touchUpInside)
            }

            objc_setAssociatedObject(self, &AssociatedKeys.ActionKey, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let wrapper = objc_getAssociatedObject(self, &AssociatedKeys.ActionKey) as? ActionWrapper else {
                return nil
            }

            return wrapper.action
        }
    }

     @objc func performAction() {
        guard let action = action else {
            return
        }

        action()
    }
}

public enum UIButtonBorderSide {
    case Top, Bottom, Left, Right
}

extension UIButton {

    public func addBorder(side: UIButtonBorderSide, color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = UIColor.red.cgColor

        switch side {
        case .Top:
            border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: width)
        case .Bottom:
            border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        case .Left:
            border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        case .Right:
            border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        }

        self.layer.addSublayer(border)
    }
}
