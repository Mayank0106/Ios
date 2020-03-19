//
//  UIImageExtension.swift
//  DITY

import Foundation
import UIKit

// MARK: - Resize image

extension UIImage {

    /// Resize the image
    ///
    /// - parameter targetSize: size to resize the image
    ///
    /// - returns: ui image after resize
    func resizeImage(targetSize: CGSize) -> UIImage {

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize

        var actualHeight = Double(self.size.height)
        var actualWidth = Double(self.size.width)
        var imgRatio = Double(actualWidth / actualHeight)
        let maxRatio = Double(targetSize.width / targetSize.height)

        if imgRatio != maxRatio {
            if imgRatio < maxRatio {
                imgRatio = Double(targetSize.height) / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = Double(targetSize.height)
            } else {
                imgRatio = Double(targetSize.width) / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = Double(targetSize.width)
            }
        } else {
            actualWidth = Double(targetSize.width)
            actualHeight = Double(targetSize.height)
        }

        newSize = CGSize.init(width: CGFloat(actualWidth), height: CGFloat(actualHeight))

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.8)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

}
