//
//  InviteFriendsCollectionCell.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

class InviteFriendsCollectionCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var lblCategory: UILabel!

    @IBOutlet weak var vwLine: UIView!

    // MARK: - Set Content To Cell
    /// Set Content To Cell
    ///
    /// - Parameters:
    ///   - categoryName: category name
    ///   - isHide: is hidden
    func setContentToCell(categoryName: String, isHide: Bool) {

        lblCategory.text = categoryName
        vwLine.isHidden = isHide
    }
}
