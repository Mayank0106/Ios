//
//  ALUtilities.swift
//  ALCameraViewController
//
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit
import AVFoundation

internal func radians(_ degrees: Double) -> Double {
    return degrees / 180 * M_PI
}

internal func localizedString(_ key: String) -> String {
    return NSLocalizedString(key, tableName: CameraGlobals.shared.stringsTable, bundle: CameraGlobals.shared.bundle, comment: key)
}

internal func currentRotation(_ oldOrientation: UIInterfaceOrientation, newOrientation: UIInterfaceOrientation) -> Double {
    switch oldOrientation {
    case .portrait:
        switch newOrientation {
        case .landscapeLeft: return 90
        case .landscapeRight: return -90
        case .portraitUpsideDown: return 180
        default: return 0
        }

    case .landscapeLeft:
        return landScape(newOrientation: newOrientation, isRight: false)

    case .landscapeRight:
        return landScape(newOrientation: newOrientation)

    default: return 0
    }
}

func landScape(newOrientation: UIInterfaceOrientation, isRight: Bool = true) -> Double {
    if isRight {
        switch newOrientation {
        case .portrait: return -90
        case .landscapeRight: return 180
        case .portraitUpsideDown: return 90
        default: return 0
        }
    } else {
        switch newOrientation {
        case .portrait: return 90
        case .landscapeLeft: return 180
        case .portraitUpsideDown: return -90
        default: return 0
        }
    }
}

internal func largestPhotoSize() -> CGSize {
    let scale = UIScreen.main.scale
    let screenSize = UIScreen.main.bounds.size
    let size = CGSize(width: screenSize.width * scale, height: screenSize.height * scale)
    return size
}

internal func errorWithKey(_ key: String, domain: String) -> NSError {
    let errorString = localizedString(key)
    let errorInfo = [NSLocalizedDescriptionKey: errorString]
    let error = NSError(domain: domain, code: 0, userInfo: errorInfo)
    return error
}

internal func normalizedRect(_ rect: CGRect, orientation: UIImage.Orientation) -> CGRect {
    let normalizedX = rect.origin.x
    let normalizedY = rect.origin.y

    let normalizedWidth = rect.width
    let normalizedHeight = rect.height

    var normalizedRect: CGRect

    switch orientation {
    case .up, .upMirrored:
        normalizedRect = CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
    case .down, .downMirrored:
        normalizedRect = CGRect(x: 1-normalizedX-normalizedWidth, y: 1-normalizedY-normalizedHeight, width: normalizedWidth, height: normalizedHeight)
    case .left, .leftMirrored:
        normalizedRect = CGRect(x: 1-normalizedY-normalizedHeight, y: normalizedX, width: normalizedHeight, height: normalizedWidth)
    case .right, .rightMirrored:
        normalizedRect = CGRect(x: normalizedY, y: 1-normalizedX-normalizedWidth, width: normalizedHeight, height: normalizedWidth)
    }

    return normalizedRect
}

internal func flashImage(_ mode: AVCaptureDevice.FlashMode) -> String {
    let image: String
    switch mode {
    case .auto:
        image = "flashAutoIcon"
    case .on:
        image = "flashOnIcon"
    case .off:
        image = "flashOffIcon"
    }
    return image
}

struct ScreenSize {
    static let SCREENWIDTH         = UIScreen.main.bounds.size.width
    static let SCREENHEIGHT        = UIScreen.main.bounds.size.height
    static let SCREENMAXLENGTH    = max(ScreenSize.SCREENWIDTH, ScreenSize.SCREENHEIGHT)
}

struct DeviceConfig {
    static let SCREENMULTIPLIER: CGFloat = {
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch ScreenSize.SCREENMAXLENGTH {
            case 568.0: return 1.5
            case 667.0: return 2.0
            case 736.0: return 4.0
            default: return 1.0
            }
        } else {
            return 1.0
        }
    }()
}
