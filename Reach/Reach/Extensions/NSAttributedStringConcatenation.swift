import Foundation
import UIKit
/**
 Concatenate two attributed strings

 - parameter lhs: NSAttributedString
 - parameter rhs: NSAttributedString

 - returns: NSAttributedString
 */
func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {

	guard let a = lhs.mutableCopy() as? NSMutableAttributedString else {
		return NSAttributedString()
	}

	guard let b = rhs.mutableCopy() as? NSMutableAttributedString else {
		return NSAttributedString()
	}

	a.append(b)

	guard let copyA = a.copy() as? NSAttributedString else {
		return NSAttributedString()
	}
	return copyA
}

/**
 Concatenate NSAttributedString with a String

 - parameter lhs: NSAttributedString
 - parameter rhs: String

 - returns: NSAttributedString
 */
func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
	guard let a = lhs.mutableCopy() as? NSMutableAttributedString else {
		return NSAttributedString()
	}
	let b = NSMutableAttributedString(string: rhs)
	return a + b
}

/**
 Concatenate a String with a NSAttributedString

 - parameter lhs: String
 - parameter rhs: NSAttributedString

 - returns: NSAttributedString
 */
func + (lhs: String, rhs: NSAttributedString) -> NSAttributedString {

	let a = NSMutableAttributedString(string: lhs)
	guard let b = lhs.mutableCopy() as? NSMutableAttributedString else {
		return NSAttributedString()
	}
	return a + b
}

/**
 Append NSAttributedString with image as NSTextAttachment image

 - parameter lhs: NSAttributedString
 - parameter rhs: UIImage

 - returns: NSAttributedString
 */
func + (lhs: NSAttributedString, rhs: UIImage) -> NSAttributedString {

	guard let a = lhs.mutableCopy() as? NSMutableAttributedString else {
		return NSAttributedString()
	}
	let b = NSTextAttachment()
	b.image = rhs

	return a + b
}

/**
 Append NSAttributedString to image as NSTextAttachment image

 - parameter lhs: UIImage
 - parameter rhs: NSAttributedString

 - returns: NSAttributedString
 */
func + (lhs: UIImage, rhs: NSAttributedString) -> NSAttributedString {

	let a = NSTextAttachment()
	a.image = lhs
	guard let b = rhs.mutableCopy() as? NSMutableAttributedString else {
		return NSAttributedString()
	}
	return a + b
}

/**
 Concatenate NSAttributedString with NSTextAttachment

 - parameter lhs: NSAttributedString
 - parameter rhs: NSTextAttachment

 - returns: NSAttributedString
 */
func + (lhs: NSAttributedString, rhs: NSTextAttachment) -> NSAttributedString {

	guard let a = lhs.mutableCopy() as? NSMutableAttributedString else {
		return NSAttributedString()
	}
	let b = NSAttributedString(attachment: rhs)

	return a + b
}

/**
 Concatenate NSTextAttachment with NSAttributedString

 - parameter lhs: NSTextAttachment
 - parameter rhs: NSAttributedString

 - returns: NSAttributedString
 */
func + (lhs: NSTextAttachment, rhs: NSAttributedString) -> NSAttributedString {

	let a = NSAttributedString(attachment: lhs)
	guard let b = rhs.mutableCopy() as? NSMutableAttributedString else {
		return NSAttributedString()
	}
	return a + b
}
