//
//  AWSCameraController.swift
//  DITY
//

import Foundation
import AWSS3
import AWSCore
import ObjectiveC
//import ALCameraViewController

class AWSProtocol: NSObject {
    // In case of edit profile need to check image is uploaded or not
    var isImageUpdate = false
    var countOfImageUpload = 2
    var imageName: String?
    var sizeFull: CGFloat = 3
    var profileLargeImage: UIImage?
    var profileThumbImage: UIImage?
    // completion handler
    var callResizedHandler: ((Bool, UIImage?) -> Void)?
    var uploadedImageCallback: ((Bool, String) -> Void)?

    override init() {
        super.init()
    }

    convenience init(resizeHandler: ((Bool, UIImage?) -> Void)?, onComplete: ((Bool, String) -> Void)?) {
        self.init()
        callResizedHandler = resizeHandler
        uploadedImageCallback = onComplete
    }
}
extension AWSProtocol {

    // MARK: action sheet methods
    func showActionSheetForImage (controller: UIViewController) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Choose An Option", message: "", preferredStyle: .actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in
        }
        actionSheetController.addAction(cancelAction)
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Take Picture", style: .default) { _ -> Void in
            self.openImagePickerForCamera(controller: controller)
        }
        actionSheetController.addAction(takePictureAction)
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Choose From Camera Roll", style: .default) { _ -> Void in
            self.openImagePickerForGallery(controller: controller)
        }
        actionSheetController.addAction(choosePictureAction)
        controller.present(actionSheetController, animated: true, completion: nil)
    }

    /// Open camera picker gallery
    func openImagePickerForGallery (controller: UIViewController) {

        let libraryViewController = CameraViewController.imagePickerViewController(croppingEnabled: true) { image, asset in
            // Get the images with image type and name so that save on temp directory
            if  let img = image, let assetValue = asset?.value(forKey: "filename") as? String {
                self.isImageUpdate = true
                self.resizeImage(pickedImage: img)
                self.imageName = assetValue

            }
            controller.dismiss(animated: true, completion: nil)
        }
        controller.present(libraryViewController, animated: true, completion: nil)
    }

    /// To Resize image Thumb 72 and large 480
    ///
    /// - parameter pickedImage: image want to resize
    func resizeImage(pickedImage: UIImage) {
        var resizedLargeImage = pickedImage
        var resizedThumbImage = pickedImage
        // check if already smaller then not resize other wise make it thumb image
        //        if pickedImage.size.height > (AppConstants.profilePicLargeSize * sizeFull) || pickedImage.size.width > (AppConstants.profilePicLargeSize * sizeFull) {
        //            // resized the image thum and large
        //            resizedLargeImage = pickedImage.resizeImage( targetSize: CGSize.init(width: (AppConstants.profilePicThumbSize * sizeFull), height: (AppConstants.profilePicThumbSize * sizeFull)))
        //            resizedThumbImage = pickedImage.resizeImage( targetSize: CGSize.init(width: (AppConstants.profilePicThumbSize * sizeFull), height: (AppConstants.profilePicThumbSize * sizeFull)))
        //
        //        }
        self.profileLargeImage = resizedLargeImage
        self.profileThumbImage = resizedThumbImage
        self.callResizedHandler?(isImageUpdate, self.profileThumbImage)
    }

    /// Open Image Picker for camera
    func openImagePickerForCamera (controller: UIViewController) {
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {

            let cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true, completion: { [weak self] image, asset in
                // Get the images with image type and name so that save on temp directory
                if  let img = image, let assetValue = asset?.value(forKey: "filename") as? String {
                    self?.isImageUpdate = true
                    self?.resizeImage(pickedImage: img)
                    self?.imageName =  assetValue

                }
                controller.dismiss(animated: true, completion: nil)
            })
            controller.present(cameraViewController, animated: true, completion: nil)
        } else {
            AppUtility.showAlert("NoCameraTitle".localized, message: "NoCameraMsg".localized, delegate: self)
        }
    }

    //
    /// Start uploading Images on s3 bucket
    func uploadImages(controller: UIViewController) {
        guard let thumbImage = profileThumbImage, let largeImage = profileLargeImage, let imgName = self.imageName else {
            return
        }

        let imageNameGuid = UUID().uuidString.lowercased()
        let imageNameWithExtension = imageNameGuid + "." + "jpg"//imgDataExtension.format

        // save images on temp directory
        ImageUtility.saveImageToTemp(thumbImage, withName: imageNameWithExtension, isThumb: true)
        ImageUtility.saveImageToTemp(largeImage, withName: imageNameWithExtension, isThumb: false)
        //DLog(message:"NSTemporaryDirectory:\(NSTemporaryDirectory())")
        // traverse the image to uplaod iamge with its name
        for i in 0...1 {

            let fileNameArr = imgName.components(separatedBy: ".")
            if fileNameArr.count < 2 {
                return
            }
            let nameThumb =  imageNameGuid + AppConstants.addthumbImage  + "jpg"//imgDataExtension.format //fileNameArr[1].lowercased()
            let nameFullImage =  imageNameGuid + "." + "jpg"//imgDataExtension.format //fileNameArr[1].lowercased()
            let orignalImage = i == 0 ? nameThumb.lowercased() : nameFullImage.lowercased()
            let isThumb = i == 0 ? true : false
            // to upload the image withthe name of image
            uploadImage(imageNameUpload: orignalImage, controller: controller, isThumb: isThumb)
        }
    }

    /// Upload imges on s3 bucket with image name
    ///
    /// - Parameter imageName: image name
    func uploadImage(imageNameUpload: String, controller: UIViewController, isThumb: Bool) {
        controller.showLoader()
        let path = NSTemporaryDirectory()
        let imageURL = URL(fileURLWithPath: path+imageNameUpload)
        //defining bucket and upload file name
        let S3BucketName: String = Configuration.s3BucketName()
        var S3UploadKeyName: String = "userprofiles/" + imageNameUpload

        if !isThumb {
            S3UploadKeyName = "userprofiles/" + imageNameUpload
        } else {
            S3UploadKeyName = "userprofiles/thumbs/" + imageNameUpload
        }

        let expression = AWSS3TransferUtilityUploadExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        expression.progressBlock = { (task: AWSS3TransferUtilityTask, progress: Progress) in
        }

        // transfre utility object to check connection on s3 bucket
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadFile(imageURL, bucket: S3BucketName, key: S3UploadKeyName, contentType: ImageUtility.getS3ImageExtension(imageNameUpload), expression: expression) { (complition, error) in

            DispatchQueue.main.async {
                if error != nil {
                    // In case of error loader dismiss and display alert
                    controller.dismissLoader()
                    var errorMsg = "Network Error"
                    if let _ = (error?.localizedDescription) {
                        errorMsg = "Upload Error"
                        print("thing to test", error?.localizedDescription ?? "")
                    }
                    AppUtility.showAlert("", message: errorMsg, delegate: self)
                    //  DLog(message:"Falied with error")
                } else {
                    // if upload count = 0 means all images are uploaded
                    self.countOfImageUpload -= 1
                    if self.countOfImageUpload == 0 {
                        // DLog(message:"Operation Done")
                        controller.dismissLoader()
                        if let _ = self.imageName {
                            self.uploadedImageCallback?(true, imageNameUpload)
                        }
                    }   }
            }
        }
    }

    static func uploadImage(image: UIImage, imageName: String, s3FolderName: String?, controller: UIViewController, progressHandler: @escaping (Float) -> Void, completionHandler: @escaping (Bool, Error?) -> Void) {

        guard let localImageURL = ImageUtility.saveImageToTemp(image, withName: imageName) else {
            completionHandler(false, nil)
            return
        }

        //defining bucket and upload file name
        let S3BucketName: String = Configuration.s3BucketName()
        var S3UploadKeyName: String = imageName

        if let folderName = s3FolderName {
            S3UploadKeyName = folderName + imageName
        }

        let expression = AWSS3TransferUtilityUploadExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        expression.progressBlock = { (task: AWSS3TransferUtilityTask, progress: Progress) in
            DispatchQueue.main.async {
                print("File uploaded \(progress.fractionCompleted)")
                progressHandler(Float(progress.fractionCompleted))
            }
        }

        // transfre utility object to check connection on s3 bucket
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadFile(localImageURL, bucket: S3BucketName, key: S3UploadKeyName, contentType: ImageUtility.getS3ImageExtension(imageName), expression: expression) { (task: AWSS3TransferUtilityUploadTask, error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    NSLog("AWSS3TransferUtility Failed with error: \(error)")
                    completionHandler(false, error)
                } else {
                    completionHandler(true, nil)
                }
            }
        }
    }
}
