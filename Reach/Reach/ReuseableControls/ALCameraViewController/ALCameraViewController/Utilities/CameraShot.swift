//
//  CameraShot.swift
//  ALCameraViewController

import UIKit
import AVFoundation

public typealias CameraShotCompletion = (UIImage?) -> Void

public func takePhoto(_ stillImageOutput: AVCaptureStillImageOutput, videoOrientation: AVCaptureVideoOrientation, cropSize: CGSize, completion: @escaping CameraShotCompletion) {

    guard let videoConnection: AVCaptureConnection = stillImageOutput.connection(with: AVMediaType.video) else {
        completion(nil)
        return
    }

    videoConnection.videoOrientation = videoOrientation

    stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { buffer, _ in

        guard let buffer = buffer,
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
            let image = UIImage(data: imageData) else {
            completion(nil)
            return
        }

        completion(image)
    })
}
