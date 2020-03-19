//
//  StringExtension.swift

import Foundation
import UIKit

extension String {

	// Length of string
	var length: Int {
		return characters.count
	}
	// Localization
	var localized: String {

		return NSLocalizedString(self, tableName: nil,
			bundle: Bundle.main,
			value: self, comment: "")
	}

	// To check text field or String is blank or notz
	var isBlank: Bool {
		get {
			let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
			return trimmed.isEmpty
		}
	}

	// validate PhoneNumber
	var isPhoneNumber: Bool {
		do {

			let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
			let matches = detector.matches(in: self, options: [],
				range: NSRange.init(location: 0, length: self.characters.count))
			if let res = matches.first {
				return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.characters.count
			} else {
				return false
			}
		} catch {
			return false
		}
	}

	/**
	 This method is used to change the color substring within a String

	 - parameter color: UIColor
	 - parameter range: NSRange

	 - returns: NSAttributedString
	 */
	func changeCololOfSusbstring(toColor color: UIColor, inRange range: NSRange) -> NSAttributedString {

		let attributedString = NSMutableAttributedString(string: self)
		attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
		return attributedString

	}

	/**
	 This method is used to change color , font of substring within a string

	 - parameter color:  UIColor
	 - parameter toFont: UIFont
	 - parameter range:  NSRange , range of substring

	 - returns: NSAttributedString
	 */
	func changeSusbstring(toColor color: UIColor, toFont: UIFont, inRange range: NSRange) -> NSAttributedString {

		let attributedString = NSMutableAttributedString(string: self)
		attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
		let fontAttributes = [NSAttributedStringKey.font: toFont]
		attributedString.addAttributes(fontAttributes, range: range)

		return attributedString

	}

    // height of string with constant width
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    // width of string with constant height
    func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
