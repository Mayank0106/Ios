//
//  Extensions.swift
//  VLT
//
//  Copyright © 2017 Netsolutions. All rights reserved.
//

import Foundation
import UIKit
// Array Extension
extension Array {
    /// Check  array consist particular index
    ///
    /// - parameter index: index value
    ///
    /// - returns: true/false
    func isIndexWithinBound(index: Int) -> Bool {
        if index >= 0 && self.count > index {
            return true
        }

        return false
    }
}
extension UITableView {

    // MARK: - Table Height find fucntion

    /// Preferred height of table view
    ///
    /// - returns: size of table view
    func preferredContentSizeOfTable() -> CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }
}
//extension UIColor {

//    convenience init(hex: Int, alpha: CGFloat = 1.0) {
//        self.init(
//            red:   CGFloat((hex & 0xFF0000) >> 16) / 255.0,
//            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
//            blue:  CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
//            alpha: alpha
//        )
//    }

//
//}
// MARK: - Hex, Hex + Alpha, RGB, RGB + Alpha

extension UIColor {
    convenience init(hex: Int) {
        self.init(hex: hex, a: 1.0)
    }

    convenience init(hex: Int, a: CGFloat) {
        self.init(r: (hex >> 16) & 0xff, g: (hex >> 8) & 0xff, b: hex & 0xff, a: a)
    }

    convenience init(r: Int, g: Int, b: Int) {
        self.init(r: r, g: g, b: b, a: 1.0)
    }

    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }

    convenience init?(hexString: String) {
        guard let hex = hexString.hex else {
            return nil
        }
        self.init(hex: hex)
    }
}

extension String {
    var hex: Int? {
        return Int(self, radix: 16)
    }

}

extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y:
            locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        return NSLocationInRange(indexOfCharacter, targetRange)
    }

}
