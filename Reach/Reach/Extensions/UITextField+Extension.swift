//
//  UITextField+Extension.swift

import Foundation
import UIKit

extension UITextField {

    // To check text field blank
    var isBlank: Bool {
        get {
            guard let textStr = text, textStr.isBlank == false else {

                return true
            }
            return textStr.isBlank
        }
    }

    /// Returns the text of field
    var textTyped: String {
        get {
            guard let textStr = text, textStr.isBlank == false else {
                return ""
            }
            return textStr
        }
    }
}

@IBDesignable
class TextField: UITextField {
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0

    // placeholder position
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }

    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
}
