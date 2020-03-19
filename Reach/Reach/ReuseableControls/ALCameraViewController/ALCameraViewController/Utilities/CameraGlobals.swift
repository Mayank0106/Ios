//
//  CameraGlobals.swift
//  ALCameraViewController

import UIKit
import AVFoundation

internal let itemSpacing: CGFloat = 1
internal let columns: CGFloat = 4
internal let thumbnailDimension = (UIScreen.main.bounds.width - ((columns * itemSpacing) - itemSpacing))/columns
internal let scale = UIScreen.main.scale

public class CameraGlobals {
    public static let shared = CameraGlobals()

    public var bundle = Bundle(for: CameraViewController.self)
    public var stringsTable = "CameraView"
    public var photoLibraryThumbnailSize = CGSize(width: thumbnailDimension, height: thumbnailDimension)
    public var defaultCameraPosition = AVCaptureDevice.Position.back
}
