//
//  FriendVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

typealias CompletionHandler = (_ complete: Bool) -> Void

class FriendVC: UIViewController, FriendAPI {

    // MARK: - IBOutlets

    @IBOutlet weak var vwMain: UIView!

    @IBOutlet weak var btnProfile: UIButton!

    @IBOutlet weak var vwOuter: UIView!

    @IBOutlet weak var txtVwSearch: UITextField!

    @IBOutlet weak var btnAddFriend: ButtonFontConstraint!

    @IBOutlet weak var tblVwFriends: UITableView!

    @IBOutlet weak var vwTransparent: UIView!

    @IBOutlet weak var btnRemoveFriend: ButtonFontConstraint!

    // MARK: - Variables
    var arrFriends = [FriendModel]()

    let htForRow: CGFloat = 63

    let headerHt: CGFloat = 54

    var friendIdForDeletion: Int?

    var pageNum = 1

    var searchText = ""

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        setUpTextField()
        setInfiniteScrollOnTable()
        setPullToRefreshOnTable()
        addTapGestureToRemoveFriendView()
        listFriendsWebService(searchText: searchText,
                              pageNo: pageNum,
                              completionHandler: { (_) -> Void in
        })
        // Do any additional setup after loading the view.
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

    override func viewDidDisappear(_ animated: Bool) {
        vwTransparent.removeFromSuperview()
    }

    // deinit function
    deinit {
        // check atble avialable then remove
        if let tblView = self.tblVwFriends {
            tblView.dg_removePullToRefresh()
        }
    }

    // MARK: - Add Tap Gesture

    /// Add Tap Gesture To Remove Friend's View
    func addTapGestureToRemoveFriendView() {

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(removeTransparentView(sender:)))
        vwTransparent.addGestureRecognizer(tap)
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

    // MARK: - Set scroll & Pull To Refresh

    /// Set the pull to refersh
    func setPullToRefreshOnTable() {
        /// Set the loading view's indicator color
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.gray

        /// Add handler
        tblVwFriends.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.pageNum = 1
            self?.tblVwFriends.hasMoreData = true
            self?.arrFriends = []
            self?.listFriendsWebService(searchText: self!.searchText,
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

        listFriendsWebService(searchText: searchText,
                              pageNo: pageNum,
                              completionHandler: { (_) -> Void in

            DispatchQueue.main.async {
                self.tblVwFriends.stopInfiniteScrollLoader()
            }
        })
    }

    // MARK: - Web service calls

    /// List All my friends Web service
    ///
    /// - Parameters:
    ///   - searchText: search text
    ///   - pageNo: page no
    ///   - completionHandler: completion handler
    func listFriendsWebService(searchText: String,
                               pageNo: Int,
                               completionHandler: @escaping CompletionHandler) {

        self.tblVwFriends.isUserInteractionEnabled = false

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        listAllFriends(searchText,
                       page: pageNo,
                       withHandler: { (friendDetails, isFromCache)  in

                        self.tblVwFriends.isUserInteractionEnabled = true

            guard let friendInfo = friendDetails else {

                self.tblVwFriends.hasMoreData = false
                completionHandler(true)
                return
            }
            if friendInfo.status == AppConstants.successServiceCode {

                guard let response = friendInfo.response,
                    let friends = response.results else { return }

                if friends.count < 8 || response.next == nil {
                    self.tblVwFriends.hasMoreData = false
                }
                if self.pageNum == 1 {
                    self.arrFriends = friends
                } else {
                    self.arrFriends.append(contentsOf: friends)
                }
                self.tblVwFriends.reloadData()
                completionHandler(true)

            } else if friendInfo.status == AppConstants.tokenExpired {
                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {
                AppUtility.showAlert("", message: friendInfo.message, delegate: nil)
            }
        }) { (error) in
            self.tblVwFriends.isUserInteractionEnabled = true
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    /// Unfriend
    func unfriend() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        guard let frndID = friendIdForDeletion else { return }

        self.tblVwFriends.isUserInteractionEnabled = false
        unfriend(frndID, withHandler: { (friendDetails, isFromCache)  in

            self.tblVwFriends.isUserInteractionEnabled = true
            guard let friendInfo = friendDetails else { return }
            if friendInfo.status == AppConstants.successServiceCode {
                self.vwTransparent.removeFromSuperview()
                let index = self.arrFriends.index(where: { (friend) -> Bool in
                    friend.id == frndID // test if this is the item you're looking for
                })
                if let indexExists = index {

                    self.arrFriends.remove(at: indexExists)
                    self.tblVwFriends.deleteRows(at: [IndexPath(item: indexExists,
                                                                section: 0)], with: .automatic)
                }
            } else if friendInfo.status == AppConstants.tokenExpired {

                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {
                AppUtility.showAlert("", message: friendInfo.message, delegate: nil)
            }
            }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    // MARK: - IBActions

    @objc func removeTransparentView(sender: UIButton) {

        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: {
            self.vwTransparent.alpha = 0.0
        }, completion: { finished in
            self.vwTransparent.removeFromSuperview()
        })
    }

    @IBAction func btnProfileAction(_ sender: Any) {
        guard let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
            let userObj = data as? UserModel else { return }
        profileAction(userID: userObj.id)
    }

    @IBAction func btnRemoveFriendAction(_ sender: Any) {
        unfriend()
    }

    @IBAction func btnAddFriendAction(_ sender: Any) {

        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)

        if let addFriendVC = tabBarStoryboard.instantiateViewController(withIdentifier: "AddFriendVC")
            as? AddFriendVC {
            self.navigationController?.pushViewController(addFriendVC, animated: false)
        }
    }
}

// MARK: - PerformActionsOnFriends Methods

extension FriendVC: PerformActionsOnFriends {

    /// Unfriend
    ///
    /// - Parameter sender: sender
    func unFriend(sender: UIButton) {

        friendIdForDeletion = sender.tag

        self.vwTransparent.frame = CGRect(x: self.vwMain.frame.origin.x,
                                          y: self.vwMain.frame.origin.y + 54,
                                          width: self.vwMain.frame.width,
                                          height: self.vwMain.frame.height - 54 + 76)
        let frame = sender.convert(sender.bounds,
                                   to: self.vwMain)
        self.btnRemoveFriend.frame = CGRect(x: frame.origin.x - 100,
                                            y: frame.origin.y - 64 + 35,
                                            width: 154,
                                            height: 52)
        appDelegate.window?.addSubview(self.vwTransparent)
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseIn, animations: {

            self.vwTransparent.alpha = 1.0

        }, completion: { finished in
            print("Napkins opened!")
        })

    }

    /// Accept Request
    ///
    /// - Parameter sender: sender
    func acceptRequest(sender: UIButton) {}

    /// Add Friend
    ///
    /// - Parameter sender: sender
    func addFriend(sender: UIButton) {}
}

// MARK: - UITableView Delegate and Datasource Methods

extension FriendVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        return self.arrFriends.count
    }

    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell")
            as? FriendTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        cell.setContentToCell(friend: arrFriends[indexPath.row])
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        return htForRow
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let friendID = arrFriends[indexPath.row]
        profileAction(userID: friendID.id)
    }
}

// MARK: - UITextFieldDelegate Methods
extension FriendVC: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        self.view.endEditing(true)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let strText = textField.text! as NSString

        searchText = strText.replacingCharacters(in: range, with: string)
        self.pageNum = 1
        self.arrFriends = []
        self.tblVwFriends.hasMoreData = true
        self.tblVwFriends.setContentOffset(.zero,
                                           animated: true)
        listFriendsWebService(searchText: searchText,
                              pageNo: self.pageNum,
                              completionHandler: { (_) -> Void in
        })

        return true
    }
}
