//
//  ResizeMultipleImagesViewControllerExtensions.swift

import Foundation
import Photos

let fileNameKey = "filename"
let addthumbImage = "_thumb."
extension MultipleImagesViewController {
    func resizeImage(pickedImage: UIImage) {
        var resizedLargeImage = pickedImage
        var resizedThumbImage = pickedImage
        if pickedImage.size.height > (picLargeSize * 3) || pickedImage.size.width > (picLargeSize * 3) {
            resizedLargeImage = pickedImage.resizeImage( targetSize: CGSize.init(width: picLargeSize * 3, height: (picLargeSize * 3)))
            resizedThumbImage = pickedImage.resizeImage( targetSize: CGSize.init(width: (picThumbSize * 3), height: (picThumbSize * 3)))
        }
        picLargeImage = resizedLargeImage
        picThumbImage = resizedThumbImage
    }

    func putDataInModel(assetValue: PHAsset, thumb: UIImage, fullImage: UIImage) -> Images {
        var imagesObj = Images()
        imagesObj.fullImage = fullImage
        imagesObj.thumbImage = thumb
        imagesObj.assest  = assetValue
        let (thumbImageName, largeImageName) = provideNameFrom(assest: assetValue)
        imagesObj.thumbImageName = thumbImageName
        imagesObj.fullImageName = largeImageName
        return imagesObj
    }

    func provideNameFrom(assest: PHAsset) -> (String?, String?) {
        guard let fileName = assest.value(forKey: fileNameKey) as? String else {
            return(nil, nil)
        }
        let fileNameArr = fileName.components(separatedBy: ".")
        if fileNameArr.count < 2 {
            return(nil, nil)
        }
        let imageName = UUID().uuidString.lowercased()
        let thumbImageName = imageName + addthumbImage  + fileNameArr[1].lowercased()
        let largeImageName = imageName + "." + fileNameArr[1].lowercased()
        return (thumbImageName, largeImageName)
    }

}
