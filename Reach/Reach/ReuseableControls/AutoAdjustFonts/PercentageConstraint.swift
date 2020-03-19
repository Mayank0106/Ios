//
//  PercentageConstraint.swift
//
//  Copyright © 2018 Rajesh Chauhan. All rights reserved.
//

import Foundation
import UIKit
// MARK: Constraints
/// Layout constraint to calculate size based on multiplier.
class PercentLayoutConstraint: NSLayoutConstraint {

    @IBInspectable var marginPercent: CGFloat = 0 {
        didSet {
            guard marginPercent > 0 else { return }
            layoutDidChange()
        }
    }

    var screenSize: (width: CGFloat, height: CGFloat) {
        return (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }

    @objc func layoutDidChange() {
        guard marginPercent > 0 else { return }

        switch firstAttribute {
        case .top, .topMargin, .bottom, .bottomMargin:
            constant = screenSize.height * marginPercent
        case .leading, .leadingMargin, .trailing, .trailingMargin:
            constant = screenSize.width * marginPercent
        default: break
        }
    }
}
// MARK: TextFeild
class TextFontConstraint: SkyFloatingLabelTextField { //FloatLabelTextField {

    @IBInspectable var fontRatio: CGFloat = 1.0 {
        didSet {
            guard fontRatio > 0 else { return }
            ratioDidChange()
        }
    }
    var screenSize: (width: CGFloat, height: CGFloat) {
        return (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }
    @objc func ratioDidChange() {
        guard fontRatio > 0 else { return }
        let fontName = self.font?.fontName ?? "System"
        self.font = UIFont(name: fontName, size: screenSize.height * fontRatio)
    }
}
// MARK: Label
open class LabelFontConstraint: UILabel {
    @IBInspectable var fontRatio: CGFloat = 0.0 {
        didSet {
            guard fontRatio > 0 else { return }
            ratioDidChange()
        }
    }
    var screenSize: (width: CGFloat, height: CGFloat) {
        return (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }
    @objc func ratioDidChange() {
        guard fontRatio > 0 else { return }
        if self.tag == 0 {
            self.tag = 1
            let newFontSize = self.font.pointSize.dp // we get old font size and adaptive it with multiply it with dp.
            let oldFontName = self.font.fontName
            self.font = UIFont(name: oldFontName, size: newFontSize) // and set new font here .
        }
    }
}
// MARK: Button
class ButtonFontConstraint: UIButton {
    @IBInspectable var fontRatio: CGFloat = 0.0 {
        didSet {
            guard fontRatio > 0 else { return }
            ratioDidChange()
        }
    }
    var screenSize: (width: CGFloat, height: CGFloat) {
        return (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }
    @objc func ratioDidChange() {
        guard fontRatio > 0 else { return }
        if self.tag == 0 {
            self.tag = 1
            let newFontSize = self.titleLabel?.font.pointSize.dp // we get old font size and adaptive it with multiply it with dp.
            let oldFontName = self.titleLabel?.font.fontName ?? "System"
            self.titleLabel?.font = UIFont(name: oldFontName, size: newFontSize!)! // and set new font here .
        }
    }
}
// MARK: TextView
class TextViewFontConstraint: FloatLabelTextView {

    @IBInspectable var fontRatio: CGFloat = 0.0 {
        didSet {
            guard fontRatio > 0 else { return }
            ratioDidChange()
        }
    }
    var screenSize: (width: CGFloat, height: CGFloat) {
        return (UIScreen.main.bounds.width, UIScreen.main.bounds.height)
    }
    @objc func ratioDidChange() {
        guard fontRatio > 0 else { return }
        if self.tag == 0 {
            self.tag = 1
            let newFontSize = self.font?.pointSize.dp // we get old font size and adaptive it with multiply it with dp.
            let oldFontName = self.font?.fontName ?? "System"
            self.font = UIFont(name: oldFontName, size: newFontSize!) // and set new font here .
        }
    }
}

extension CGFloat {
    /**
     The relative dimension to the corresponding screen size.
     
     //Usage
     let someView = UIView(frame: CGRect(x: 0, y: 0, width: 320.dp, height: 40.dp)
     
     **Warning** Only works with size references from @1x mockups.
     
     */
    var dp: CGFloat {
        return (self / 375) * UIScreen.main.bounds.width
    }
}
