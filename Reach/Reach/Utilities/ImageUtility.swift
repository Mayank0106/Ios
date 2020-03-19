//
//  ImageUtility.swift
//  DITY
//

import Foundation
import UIKit

struct ImageUtility {

    /// get the s3 image extension to save depening upon our image extension
    ///
    /// - parameter fileName: file name
    ///
    /// - returns: extension name in string
    static func getS3ImageExtension(_ fileName: String) -> String {
        var contentType = ""
        let fileNameArr = fileName.components(separatedBy: ".")
        if fileNameArr.count >= 2 {
            switch fileNameArr[fileNameArr.count - 1].lowercased() {
            case "mp4":
                contentType = "movie/mp4"
            case "jpg":
                contentType = "image/jpg"
            case "jpeg":
                contentType = "image/jpeg"
            case "png":
                contentType = "image/png"
            case "mp3":
                contentType = "audio/mpeg"
            default:
                contentType = "txt"
            }
        }
        return contentType
    }

    /// Save the image on temp with particular name
    ///
    /// - parameter image:    image which want to save
    /// - parameter fileName: file name of image
    /// - parameter isThumb:  if same name and we want to add thumb then add _thumb after image name
    static func saveImageToTemp(_ image: UIImage, withName fileName: String, isThumb: Bool) {
        let fileNameArr = fileName.components(separatedBy: ".")
        if fileNameArr.count < 2 {
            return
        }
        let name = isThumb ? fileNameArr[0].lowercased() + "_thumb" : fileNameArr[0].lowercased()
        let extensionValue = fileNameArr[1].lowercased()
        var data =  UIImageJPEGRepresentation(image, 1.0)
        if extensionValue == "jpeg" || extensionValue == "jpg"{
            data = UIImageJPEGRepresentation(image, 1.0)
        } else if extensionValue == "png"{
            data = UIImagePNGRepresentation(image)
        } else {
            AppUtility.showAlert( "", message: "sorry invalid format", delegate: nil)
        }
        let tmpDirURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let fullPath = tmpDirURL.appendingPathComponent(name).appendingPathExtension(extensionValue)
        do {
            try data?.write(to: fullPath, options: .atomic)
        } catch {
        }
    }

    /// Save the image on temp with particular name
    ///
    /// - parameter image:    image which want to save
    /// - parameter fileName: file name of image
    static func saveImageToTemp(_ image: UIImage, withName fileName: String) -> URL? {

        let arrFileNameComponents = fileName.components(separatedBy: ".")

        if arrFileNameComponents.count < 2 {
            return nil
        }

        let pathExtension = arrFileNameComponents[arrFileNameComponents.count - 1]
        let name = fileName.replacingOccurrences(of: ".\(pathExtension)", with: "")

        var data = UIImageJPEGRepresentation(image, 0.4)
        if pathExtension == "jpeg" || pathExtension == "jpg"{
            data = UIImageJPEGRepresentation(image, 0.4)
        } else if pathExtension == "png"{
            data = UIImagePNGRepresentation(image)
        }

        let tmpDirURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let fullPathURL = tmpDirURL.appendingPathComponent(name).appendingPathExtension(pathExtension)
        do {
            try data?.write(to: fullPathURL, options: .atomic)
        } catch {

        }

        return fullPathURL
    }
}
