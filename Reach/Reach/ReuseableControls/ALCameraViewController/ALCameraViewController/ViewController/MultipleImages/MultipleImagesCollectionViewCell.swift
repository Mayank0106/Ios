//
//  MultipleImagesCollectionViewCell.swift
//  Pods

import UIKit

class MultipleImagesCollectionViewCell: UICollectionViewCell {
    // MARK: Properties
    var btnCancelImageTapped: ((MultipleImagesCollectionViewCell) -> Void)?
    /// Outlet
    @IBOutlet weak var imgVwThumPic: UIImageView!
    @IBOutlet weak var btnCancel: UIButton!
    // MARK: Nib Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // MARK: - UI setup
    /**
     Set the content of cell
     - parameter image: Image
     */

    @IBAction func btnCancelTapped(_ sender: AnyObject) {
          btnCancelImageTapped?(self)
    }
    func setContentOnCell(imageParcel: UIImage) {
        imgVwThumPic.image = imageParcel
    }

}
