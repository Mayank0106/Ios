//
//  AddFriendVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

class AddFriendVC: UIViewController, FriendAPI {

    // MARK: - IBOutlets

    @IBOutlet weak var vwMain: UIView!

    @IBOutlet weak var btnProfile: UIButton!

    @IBOutlet weak var vwOuter: UIView!

    @IBOutlet weak var txtVwSearch: UITextField!

    @IBOutlet weak var btnDone: ButtonFontConstraint!

    @IBOutlet weak var tblVwFriends: UITableView!

    // MARK: - Variables
    var arrAllUsers = [FriendModel]()

    var arrAddFriends = [FriendModel]()

    var arrRequestSentRecieved = [FriendModel]()

    let htForRow: CGFloat = 63

    let headerHt: CGFloat = 30

    var pageNum = 1

    var searchText = ""

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        tblVwFriends.register(UINib(nibName: "AddFriendSectionHeaderCell",
                                    bundle: nil),
                              forHeaderFooterViewReuseIdentifier: "AddFriendSectionHeaderCell")
        setUpTextField()
        setPullToRefreshOnTable()
        setInfiniteScrollOnTable()
        listUsersWebService(searchText: searchText,
                            pageNo: pageNum,
                            completionHandler: { (_) -> Void in
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        setNavBarHide(hide: true)
        if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
            let userObj = data as? UserModel,
            let uerImage = userObj.profileImage {
            if let myImageUrl = URL(string: uerImage) {
                btnProfile.kf.setImage(with: ImageResource(downloadURL: myImageUrl),
                                       for: .normal,
                                       placeholder: UIImage(named: "avatarImage"),
                                       options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                       progressBlock: nil,
                                       completionHandler: nil)
            }
        }
    }

    // deinit function
    deinit {
        // check atble avialable then remove
        if let tblView = self.tblVwFriends {
            tblView.dg_removePullToRefresh()
        }
    }

    // MARK: - Set Up UI

    /// Set Up search in text field
    func setUpTextField() {

        txtVwSearch.tintColor = #colorLiteral(red: 0.5529411765, green: 0.5529411765, blue: 0.5529411765, alpha: 1)
        let viewOuter = UIView()
        viewOuter.frame = CGRect(x: 0, y: 0, width: 59, height: 24)

        let imageView = UIImageView()
        let image = UIImage(named: "icSearch")
        imageView.frame = CGRect(x: 22, y: 0, width: 24, height: 24)
        imageView.image = image

        viewOuter.addSubview(imageView)

        txtVwSearch.leftView = viewOuter
        txtVwSearch.leftViewMode = .always
        txtVwSearch.delegate = self
    }

    /// Filter Results Based on ENum Value
    func filterResultsBasedOnEnum() {

        arrAddFriends = arrAllUsers.filter { $0.friendStatus == FriendStatus.NotFriends.status }
        let arrFriendRequestRecieved = arrAllUsers.filter { $0.friendStatus == FriendStatus.RequestRecieved.status}
        let arrFriendRequestSent = arrAllUsers.filter { $0.friendStatus == FriendStatus.RequestSent.status}
        arrRequestSentRecieved = arrFriendRequestRecieved + arrFriendRequestSent
        self.tblVwFriends.reloadData()
    }

    // MARK: - Set scroll & pull to refersh

    /// Set the pull to refersh
    func setPullToRefreshOnTable() {
        /// Set the loading view's indicator color
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.gray

        /// Add handler
        tblVwFriends.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.pageNum = 1
            self?.tblVwFriends.hasMoreData = true
            self?.arrAllUsers = []
            self?.listUsersWebService(searchText: self!.searchText,
                                      pageNo: self!.pageNum,
                                      completionHandler: { (_) -> Void in
                self?.tblVwFriends.stopPullToRefreshLoader()
            })
            }, loadingView: loadingView)

        /// Set the background color of pull to refresh
        tblVwFriends.dg_setPullToRefreshFillColor(UIColor.clear)
        tblVwFriends.dg_setPullToRefreshBackgroundColor(tblVwFriends.backgroundColor!)
    }

    /// Set infinite scroll on table view
    func setInfiniteScrollOnTable() {

        tblVwFriends.hasMoreData = true
        tblVwFriends.addPushRefreshHandler({ [weak self] in
            if let pageNum = self?.pageNum {

                self?.pageNum = pageNum + 1
                self?.loadMoreData(with: (self?.pageNum)!)
            }
        })
    }

    /// Load More Data
    ///
    /// - Parameter pageNum: page num
    func loadMoreData(with pageNum: Int) {

        listUsersWebService(searchText: searchText,
                            pageNo: pageNum,
                            completionHandler: { (_) -> Void in

            DispatchQueue.main.async {
                self.tblVwFriends.stopInfiniteScrollLoader()
            }
        })
    }

    // MARK: - Web service calls

    /// List all users web service
    ///
    /// - Parameter searchText: search text
    func listUsersWebService(searchText: String,
                             pageNo: Int,
                             completionHandler: @escaping CompletionHandler) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        listAllUsers(searchText,
                     page: pageNo,
                     withHandler: { (friendDetails, isFromCache)  in

            guard let friendInfo = friendDetails else {

                self.tblVwFriends.hasMoreData = false
                completionHandler(true)
                return
            }
            if friendInfo.status == AppConstants.successServiceCode {

                guard let response = friendInfo.response, let friends = response.results else { return }

                if friends.count < 8 || response.next == nil {
                    self.tblVwFriends.hasMoreData = false
                }

                if self.pageNum == 1 {
                    self.arrAllUsers = friends
                } else {
                    self.arrAllUsers.append(contentsOf: friends)
                }

                self.filterResultsBasedOnEnum()
                completionHandler(true)

            } else if friendInfo.status == AppConstants.tokenExpired {

                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {
                AppUtility.showAlert("",
                                     message: friendInfo.message,
                                     delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("",
                                 message: "Error",
                                 delegate: nil)
        }
    }

    /// Accept Friend Request
    ///
    /// - Parameter friendID: friend id
    func acceptFriendRequestWebService(friendID: Int) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        acceptFriendRequest(friendID,
                            withHandler: { (friendDetails, isFromCache)  in

            guard let friendInfo = friendDetails else { return }
            if friendInfo.status == AppConstants.successServiceCode {

                let indexInAllUsers = self.arrAllUsers.index(where: { (friend) -> Bool in
                    friend.id == friendID // test if this is the item you're looking for
                })

                let indexInRequestsRecieved = self.arrRequestSentRecieved.index(where: { (friend) -> Bool in
                    friend.id == friendID // test if this is the item you're looking for
                })
                if let indexExists = indexInAllUsers,
                    let indexInRequestRecievedExists = indexInRequestsRecieved {

                    self.arrAllUsers.remove(at: indexExists)
                    self.arrRequestSentRecieved.remove(at: indexInRequestRecievedExists)
                    self.tblVwFriends.deleteRows(at: [IndexPath(item: indexInRequestRecievedExists,
                                                                section: 0)],
                                                 with: .automatic)
                }

            } else if friendInfo.status == AppConstants.tokenExpired {

                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {
                AppUtility.showAlert("",
                                     message: friendInfo.message,
                                     delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("",
                                 message: "Error",
                                 delegate: nil)
        }
    }

    /// Send Friend Request
    ///
    /// - Parameter friendID: friend id
    func sendFriendRequestWebService(friendID: Int) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        sendFriendRequest(friendID,
                          withHandler: { (friendDetails, isFromCache)  in

            guard let friendInfo = friendDetails else { return }
            if friendInfo.status == AppConstants.successServiceCode {

                let indexInAllUsers = self.arrAllUsers.index(where: { (friend) -> Bool in
                    friend.id == friendID // test if this is the item you're looking for
                })

                let indexInAddFriends = self.arrAddFriends.index(where: { (friend) -> Bool in
                    friend.id == friendID // test if this is the item you're looking for
                })
                if let indexExists = indexInAllUsers, let indexInAddFriendsExists = indexInAddFriends {

                    self.arrAllUsers[indexExists].friendStatus = FriendStatus.RequestSent.status
                    self.arrAddFriends[indexInAddFriendsExists].friendStatus = FriendStatus.RequestSent.status
                    self.arrRequestSentRecieved.insert(self.arrAllUsers[indexExists],
                                                       at: self.arrRequestSentRecieved.count)
                    self.arrAddFriends.remove(at: indexInAddFriendsExists)
                    self.tblVwFriends.beginUpdates()
                    self.tblVwFriends.insertRows(at: [IndexPath(item: self.arrRequestSentRecieved.count - 1, section: 0)],
                                                 with: .automatic)
                    self.tblVwFriends.deleteRows(at: [IndexPath(item: indexInAddFriendsExists, section: 1)],
                                                 with: .automatic)
                    self.tblVwFriends.endUpdates()
                }

            } else if friendInfo.status == AppConstants.tokenExpired {

                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {
                AppUtility.showAlert("",
                                     message: friendInfo.message,
                                     delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("",
                                 message: "Error",
                                 delegate: nil)
        }
    }

    // MARK: - IBActions
    @IBAction func btnProfileAction(_ sender: Any) {

        guard let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
            let userObj = data as? UserModel else {
            return
        }
        profileAction(userID: userObj.id)
    }

    @IBAction func btnDoneAction(_ sender: Any) {

        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.popViewController(animated: false)
    }
}

// MARK: - PerformActionsOnFriends Delegate Methods
extension AddFriendVC: PerformActionsOnFriends {

    /// UnFriend
    ///
    /// - Parameter sender: sender
    func unFriend(sender: UIButton) {

        //pending
    }

    /// Accept Request
    ///
    /// - Parameter sender: sender
    func acceptRequest(sender: UIButton) {

        let friendID = sender.tag
        acceptFriendRequestWebService(friendID: friendID)
    }

    /// Add Friend
    ///
    /// - Parameter sender: sender
    func addFriend(sender: UIButton) {

        let friendID = sender.tag
        sendFriendRequestWebService(friendID: friendID)
    }
}
