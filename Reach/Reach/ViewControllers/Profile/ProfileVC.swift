//
//  ProfileVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileVC: UIViewController, ProfileAPI, FriendAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var lblUserName: UILabel!

    @IBOutlet weak var lblNoOfParties: UILabel!

    @IBOutlet weak var btnSettings: UIButton!

    @IBOutlet weak var imgVwPic: UIImageView!

    @IBOutlet weak var lblName: UILabel!

    @IBOutlet weak var lblAddress: UILabel!

    @IBOutlet weak var btnAddFriend: UIButton!

    @IBOutlet weak var btnFriends: UIButton!

    @IBOutlet weak var btnRequestSent: UIButton!

    @IBOutlet weak var btnRequestAccept: UIButton!

    @IBOutlet weak var tblVwEvents: UITableView!

    @IBOutlet weak var btnEdit: UIButton!

    // MARK: - Constraints
    @IBOutlet weak var constraintTableVwTop: NSLayoutConstraint!

    // MARK: - Variables
    var objProfile: ProfileModel?

    var arrFeeds = [MyEventModel]()

    let htForRow: CGFloat = 192.0

    var pageNum = 1

    var isMyProfile = true

    var userID: Int?

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tabBarController?.tabBar.isHidden = true
        // Add Blur View
        setButtonTags()
        setUIElements()
        setInfiniteScrollOnTable()
        setPullToRefreshOnTable()
        callWebserviceToFetchProfileEvents(showLoader: true, pageNo: pageNum,
                                           completionHandler: { (_) -> Void in
        })
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        callWebserviceToFetchProfileData()
        setNavBarHide(hide: true)
        setButtons(friendStatus: 0)
    }

    // deinit function
    deinit {
        // check atble avialable then remove
        if let tblView = self.tblVwEvents {
            tblView.dg_removePullToRefresh()
        }
    }

    // MARK: - Set Button Tags

    /// Set Button Tags
    func setButtonTags() {

        guard let userID = userID else { return }
        btnAddFriend.tag = userID
        btnFriends.tag = userID
        btnAddFriend.tag = userID
        btnRequestAccept.tag = userID
    }

    // MARK: - Set UI

    /// Set UI ELements
    func setUIElements() {

        guard let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
            let userObj = data as? UserModel,
            let myUserID = userObj.id else {
            return
        }
        guard let userID = userID else { return }
        if myUserID == userID {
            isMyProfile = true
            btnSettings.isHidden = false
        } else {
            isMyProfile = false
            btnSettings.isHidden = true
        }
    }

    /// Set UI after service call
    func setUI() {

        guard let profile = objProfile else { return }
        lblUserName.text = profile.username
        if let goingCount = profile.goingCount {
            if goingCount == 1 {
                lblNoOfParties.text = "Went to " + "\(goingCount)" + " party"

            } else  {
                lblNoOfParties.text = "Went to " + "\(goingCount)" + " parties"

            }
        }

        if let profileImageStr = profile.profileImage,
            let profileImageUrl = URL(string: profileImageStr) {

            imgVwPic.kf.setImage(with: ImageResource(downloadURL: profileImageUrl),
                                 placeholder: UIImage(named: "avatarImage"),
                                 options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                 progressBlock: nil,
                                 completionHandler: nil)
        } else {
            imgVwPic.image = UIImage(named: "avatarImage")
        }

        lblName.text = profile.fullname

        guard let province = profile.state, let stateCode = province.stateCode else { return }
        guard let city = profile.city, let cityName = city.name else { return }
        lblAddress.text = cityName + ", " + stateCode
        setButtons(friendStatus: profile.friendStatus)
    }

    /// Set Buttons as per person status
    ///
    /// - Parameter friendStatus: friend status
    func setButtons(friendStatus: Int?) {

        btnAddFriend.isHidden = true
        btnFriends.isHidden = true
        btnRequestSent.isHidden = true
        btnRequestAccept.isHidden = true

        if isMyProfile {
            constraintTableVwTop.constant = 12
            btnEdit.isHidden = false
        } else {
            constraintTableVwTop.constant = 50
            btnEdit.isHidden = true
            guard let status = friendStatus else { return }
            switch status {
            case 0:
                btnAddFriend.isHidden = false

            case 1:
                btnFriends.isHidden = false

            case 2:
                btnRequestSent.isHidden = false

            default:
                btnRequestAccept.isHidden = false

            }
        }
    }

    // MARK: - Pull To Refresh & Infinte Scroll

    /// Set the pull to refersh
    func setPullToRefreshOnTable() {
        /// Set the loading view's indicator color
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.gray

        /// Add handler
        tblVwEvents.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.pageNum = 1
            self?.tblVwEvents.hasMoreData = true
            self?.arrFeeds = []
            self?.callWebserviceToFetchProfileEvents(showLoader: false, pageNo: self!.pageNum,
                                                     completionHandler: { (_) -> Void in
                self?.tblVwEvents.stopPullToRefreshLoader()
            })
            }, loadingView: loadingView)

        /// Set the background color of pull to refresh
        tblVwEvents.dg_setPullToRefreshFillColor(UIColor.clear)
        tblVwEvents.dg_setPullToRefreshBackgroundColor(tblVwEvents.backgroundColor!)
    }

    /// Set infinite scroll on table view
    func setInfiniteScrollOnTable() {

        tblVwEvents.hasMoreData = true
        tblVwEvents.addPushRefreshHandler({ [weak self] in
            if let pageNum = self?.pageNum {
                self?.pageNum = pageNum + 1
                self?.loadMoreData(with: (self?.pageNum)!)
            }
        })
    }

    /// Load More data
    ///
    /// - Parameter pageNum: page Num
    func loadMoreData(with pageNum: Int) {

        callWebserviceToFetchProfileEvents(showLoader: true, pageNo: pageNum,
                                            completionHandler: { (_) -> Void in

            DispatchQueue.main.async {
                self.tblVwEvents.stopInfiniteScrollLoader()
            }
        })
    }

    // MARK: - IBActions

    @IBAction func btnSettingsAction(_ sender: Any) {

        self.performSegue(withIdentifier: "fromProfileToSettingsSegue",
                          sender: nil)
    }

    @IBAction func btnClosePopOverAction(_ sender: Any) {

        let vcProfile = self
        UIView.animate(withDuration: 0.5,
                       animations: { () -> Void in
                        vcProfile.view.frame = CGRect(x: 0, y: -vcProfile.view.frame.height, width: vcProfile.view.frame.width, height: vcProfile.view.frame.height)
        },
                       completion: { complete -> Void in
                        if complete {
                            self.dismiss(animated: false, completion: nil)
                        }
        })
    }

    @IBAction func btnAddFriendAction(_ sender: Any) {

        let btn = sender as? UIButton
        guard let tag = btn?.tag else { return }
        sendFriendRequestWebService(friendID: tag)
    }

    @IBAction func btnRequestAcceptAction(_ sender: Any) {

        let btn = sender as? UIButton
        guard let tag = btn?.tag else { return }
        acceptFriendRequestWebService(friendID: tag)
    }

    @IBAction func btnEditAction(_ sender: Any) {

        guard let editProfileVC = tabBarStoryboard.instantiateViewController(withIdentifier: "EditProfileVC")
            as? EditProfileVC else { return }
        editProfileVC.objProfile = self.objProfile
        self.navigationController?.pushViewController(editProfileVC,
                                                      animated: false)

    }
}
