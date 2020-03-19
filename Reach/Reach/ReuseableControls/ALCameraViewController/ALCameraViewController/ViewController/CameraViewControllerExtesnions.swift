//
//  CameraViewControllerExtesnions.swift
//

import Foundation
import AVFoundation
import Photos

//public typealias CameraViewCompletion = (UIImage?, PHAsset?) -> Void
public extension CameraViewController {
    public class func imagePickerViewController(croppingEnabled: Bool, completion: @escaping CameraViewCompletion) -> UINavigationController {
        let imagePicker = PhotoLibraryViewController()
        let navigationController = UINavigationController(rootViewController: imagePicker)
        navigationController.navigationBar.barTintColor = UIColor.black
        navigationController.navigationBar.barStyle = UIBarStyle.black
        navigationController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        imagePicker.onSelectionComplete = { [weak imagePicker] asset in
            if let asset = asset {
                let confirmController = ConfirmViewController(asset: asset, allowsCropping: croppingEnabled)
                confirmController.onComplete = { [weak imagePicker] image, asset in
                    if let image = image, let asset = asset {
                        completion(image, asset)
                    } else {
                        imagePicker?.dismiss(animated: true, completion: nil)
                    }
                }
                confirmController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                imagePicker?.present(confirmController, animated: true, completion: nil)
            } else {
                completion(nil, nil)
            }
        }
        return navigationController
    }
    // MARK: Button Actions
    internal func close() {
        onCompletion?(nil, nil)
    }

    internal func showLibrary() {
        let imagePicker = CameraViewController.imagePickerViewController(croppingEnabled: allowCropping) { image, asset in
            defer {
                self.dismiss(animated: true, completion: nil)
            }
            guard let image = image, let asset = asset else {
                return
            }
            self.onCompletion?(image, asset)
        }
        present(imagePicker, animated: true) {
            self.cameraView.stopSession()
        }
    }

    internal func toggleFlash() {
        cameraView.cycleFlash()

        guard let device = cameraView.device else {
            return
        }

        let image = UIImage(named: flashImage(device.flashMode),
                            in: Bundle(for: CameraViewController.self),
                            compatibleWith: nil)

        flashButton.setImage(image, for: .normal)
    }
    internal func swapCamera() {
        cameraView.swapCameraInput()
        flashButton.isHidden = cameraView.currentPosition == AVCaptureDevice.Position.front
    }
    // Toggle the buttons status, based on the actual state of the camera.
    internal func toggleButtons(enabled: Bool) {
        [cameraButton,
         closeButton,
         swapButton,
         libraryButton].forEach({ $0.isEnabled = enabled })
    }

    @objc func rotateCameraView() {
        cameraView.rotatePreview()
    }
    func setTransform(transform: CGAffineTransform) {
        self.closeButton.transform = transform
        self.swapButton.transform = transform
        self.libraryButton.transform = transform
        self.flashButton.transform = transform
    }
    // Validate the permissions of the camera and  library, if the user do not accept these  permissions, it shows an view that notifies the user that it not allow the permissions.
    internal func checkPermissions() {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) != .authorized {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                DispatchQueue.main.async {
                    if !granted {
                        self.showNoPermissionsView()
                    }
                }
            }
        }
    }
    // This method will be called when the user  try to take the picture. It will lock any button while the shot is taken, then, realease the buttons and save  the picture on the device.
    internal func capturePhoto() {
        guard let output = cameraView.imageOutput,
            let connection = output.connection(with: AVMediaType.video) else {
                return
        }
        if connection.isEnabled {
            toggleButtons(enabled: false)
            cameraView.capturePhoto { image in
                guard let image = image else {
                    self.toggleButtons(enabled: true)
                    return
                }
                self.saveImage(image: image)
            }
        }
    }

    internal func saveImage(image: UIImage) {
        _ = SingleImageSaver()
            .setImage(image)
            .onSuccess { asset in
                self.layoutCameraResult(asset: asset)
            }
            .onFailure { _ in
                self.toggleButtons(enabled: true)
                self.showNoPermissionsView(library: true)
            }
            .save()
    }
    // Generate the view of no permission.
    internal func showNoPermissionsView(library: Bool = false) {
        let permissionsView = PermissionsView(frame: view.bounds)
        let title: String
        let desc: String
        if library {
            title = localizedString("permissions.library.title")
            desc = localizedString("permissions.library.description")
        } else {
            title = localizedString("permissions.title")
            desc = localizedString("permissions.description")
        }

        permissionsView.configureInView(view, title: title, descriptiom: desc, completion: close)
    }

}
