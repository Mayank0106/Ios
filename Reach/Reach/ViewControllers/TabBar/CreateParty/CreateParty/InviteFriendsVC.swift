//
//  InviteFriendsVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

protocol SelectedFriendsList: class {
    func sendBackSelectedFriendList(arrSelectedFriends: [FriendModel])
}

enum Category: Int {

    case friends = 0
    case addAndInvite = 1
}

class InviteFriendsVC: UIViewController, FriendAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var btnBack: UIButton!

    @IBOutlet weak var txtSearch: UITextField!

    @IBOutlet weak var vwCollection: UICollectionView!

    @IBOutlet weak var lblNoOfPeople: UILabel!

    @IBOutlet weak var vwLine: UIView!

    @IBOutlet weak var tblVwFriends: UITableView!

    @IBOutlet weak var tblVwAddInvite: UITableView!

    // MARK: - Variables
    var arrFriends = [FriendModel]()

    var arrAddInvite = [FriendModel]()

    // Collection View At Top Bar
    var arrCollectionItems = ["Your Friends", "Add & Invite"]

    var objCategory = Category.friends

    let htForRow: CGFloat = 68

    var arrSelectedFriendList = [FriendModel]()

    weak var delegate: SelectedFriendsList?

    var searchTextFriends = ""

    var searchTextUsers = ""

    var pageNumFriends = 1

    var pageNumUsers = 1

    var eventID: Int?

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        self.lblNoOfPeople.text = String(arrSelectedFriendList.count)
        setUpTextField()
        setPullToRefreshOnFriendsTable()
        setPullToRefreshOnUsersTable()

        setInfiniteScrollOnTableFriends()
        setInfiniteScrollOnTableUser()

        selectCategory(index: 0)

        if eventID != nil {
            listAllFriendsInRespectToEventWebService(pageNo: pageNumFriends,
                                                     completionHandler: { (_) -> Void in
            })

            listAllUsersInRespectToEventWebService(pageNo: pageNumUsers,
                                                   completionHandler: { (_) -> Void in
            })
        } else {
            listFriendsWebService(pageNo: pageNumFriends,
                                  completionHandler: { (_) -> Void in
            })
            listUsersWebService(pageNo: pageNumUsers,
                                completionHandler: { (_) -> Void in
            })
        }

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        setNavBarHide(hide: true)
    }

    // deinit function
    deinit {
        // check atble avialable then remove
        if let tblView = self.tblVwFriends {
            tblView.dg_removePullToRefresh()
        }

        if let tblView = self.tblVwAddInvite {
            tblView.dg_removePullToRefresh()
        }
    }

    // MARK: - Set Up UI

    /// Set Up search in text field
    func setUpTextField() {

        txtSearch.tintColor = #colorLiteral(red: 0.5529411765, green: 0.5529411765, blue: 0.5529411765, alpha: 1)
        let viewOuter = UIView()
        viewOuter.frame = CGRect(x: 0, y: 0, width: 59, height: 24)

        let imageView = UIImageView()
        let image = UIImage(named: "icSearch")
        imageView.frame = CGRect(x: 22, y: 0, width: 24, height: 24)
        imageView.image = image

        viewOuter.addSubview(imageView)

        txtSearch.leftView = viewOuter
        txtSearch.leftViewMode = .always
        txtSearch.delegate = self
    }

    /// Select Category
    ///
    /// - Parameter index: Index
    func selectCategory(index: Int) {

        if index == 0 {

            objCategory = Category.friends
            self.txtSearch.text = searchTextFriends
            tblVwFriends.isHidden = false
            tblVwAddInvite.isHidden = true

        } else {

            objCategory = Category.addAndInvite
            self.txtSearch.text = searchTextUsers
            tblVwFriends.isHidden = true
            tblVwAddInvite.isHidden = false
        }
    }

    /// Set UI After Web service Call
    func setUIAfterWebserviceCall() {

        if objCategory == .friends {
            self.tblVwFriends.reloadData()

        } else {
            self.tblVwAddInvite.reloadData()

        }
    }

    /// Select already selected friends
    func selectAlreadySelectedFriends() {

        if objCategory == Category.friends {
            for (outerIndex, friend) in arrFriends.enumerated() {
                for selectedFriend in arrSelectedFriendList where selectedFriend.id == friend.id {

                    self.arrFriends[outerIndex].isSelected = true
                }
            }

        } else {
            for (outerIndex, friend) in arrAddInvite.enumerated() {
                for selectedFriend in arrSelectedFriendList where selectedFriend.id == friend.id {

                    self.arrAddInvite[outerIndex].isSelected = true
                }
            }
        }
    }

    // MARK: - Fetch Data as per category

    /// Set Default Settings and fetch data
    ///
    /// - Parameter strSearch: search text
    func setDefaultSettingsAndfetchData(strSearch: String) {

        if objCategory == .friends {
            if searchTextFriends == strSearch { return }
            searchTextFriends = strSearch
            self.pageNumFriends = 1
            self.arrFriends = []
            self.tblVwFriends.hasMoreData = true

            if eventID != nil {
                listAllFriendsInRespectToEventWebService(pageNo: pageNumFriends,
                                                         completionHandler: { (_) -> Void in
                      self.tblVwFriends.setContentOffset(.zero, animated: true)
                })

            } else {
                listFriendsWebService(pageNo: pageNumFriends,
                                      completionHandler: { (_) -> Void in
                      self.tblVwFriends.setContentOffset(.zero, animated: true)
                })
            }

        } else {
            if searchTextUsers == strSearch { return }
            searchTextUsers = strSearch
            self.pageNumUsers = 1
            self.arrAddInvite = []
            self.tblVwAddInvite.hasMoreData = true

            if eventID != nil {
                listAllUsersInRespectToEventWebService(pageNo: pageNumUsers,
                                                       completionHandler: { (_) -> Void in

                    self.tblVwAddInvite.setContentOffset(.zero, animated: true)
                })
            } else {

                listUsersWebService(pageNo: pageNumUsers,
                                    completionHandler: { (_) -> Void in

                    self.tblVwAddInvite.setContentOffset(.zero, animated: true)
                })
            }
        }
    }

    // MARK: - Set scroll

    /// Set infinite scroll on table friends
    func setInfiniteScrollOnTableFriends() {

        tblVwFriends.hasMoreData = true
        tblVwFriends.addPushRefreshHandler({ [weak self] in
            if let pageNum = self?.pageNumFriends {
                self?.pageNumFriends = pageNum + 1
                self?.loadMoreDataFriends(with: (self?.pageNumFriends)!)
            }
        })
    }

    /// Set infinite scroll on table add & invite
    func setInfiniteScrollOnTableUser() {

        tblVwAddInvite.hasMoreData = true
        tblVwAddInvite.addPushRefreshHandler({ [weak self] in
            if let pageNum = self?.pageNumUsers {
                self?.pageNumUsers = pageNum + 1
                self?.loadMoreDataUsers(with: (self?.pageNumUsers)!)
            }
        })
    }

    /// Set the pull to refersh on table friends
    func setPullToRefreshOnFriendsTable() {
        /// Set the loading view's indicator color
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.gray

        /// Add handler
        if eventID != nil {
            tblVwFriends.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
                self?.pageNumFriends = 1
                self?.tblVwFriends.hasMoreData = true
                self?.arrFriends = []

                self?.listAllFriendsInRespectToEventWebService(pageNo: self!.pageNumFriends,
                                                               completionHandler: { (_) -> Void in
                                                self?.tblVwFriends.stopPullToRefreshLoader()
                })
                }, loadingView: loadingView)
        } else {
            tblVwFriends.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
                self?.pageNumFriends = 1
                self?.tblVwFriends.hasMoreData = true
                self?.arrFriends = []

                self?.listFriendsWebService(pageNo: self!.pageNumFriends,
                                            completionHandler: { (_) -> Void in
                                                self?.tblVwFriends.stopPullToRefreshLoader()
                })
                }, loadingView: loadingView)
        }

        /// Set the background color of pull to refresh
        tblVwFriends.dg_setPullToRefreshFillColor(UIColor.clear)
        tblVwFriends.dg_setPullToRefreshBackgroundColor(tblVwFriends.backgroundColor!)
    }

    /// Set the pull to refersh on table add & invite
    func setPullToRefreshOnUsersTable() {
        /// Set the loading view's indicator color
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.gray

        /// Add handler
        if let _ = eventID {
            tblVwAddInvite.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
                self?.pageNumUsers = 1
                self?.tblVwAddInvite.hasMoreData = true
                self?.arrAddInvite = []
                self?.listAllUsersInRespectToEventWebService(pageNo: self!.pageNumUsers,
                                                             completionHandler: { (_) -> Void in
                                            self?.tblVwAddInvite.stopPullToRefreshLoader()
                })
                }, loadingView: loadingView)

        } else {
            tblVwAddInvite.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
                self?.pageNumUsers = 1
                self?.tblVwAddInvite.hasMoreData = true
                self?.arrAddInvite = []
                self?.listUsersWebService(pageNo: self!.pageNumUsers,
                                          completionHandler: { (_) -> Void in
                                            self?.tblVwAddInvite.stopPullToRefreshLoader()
                })
                }, loadingView: loadingView)

        }

        /// Set the background color of pull to refresh
        tblVwAddInvite.dg_setPullToRefreshFillColor(UIColor.clear)
        tblVwAddInvite.dg_setPullToRefreshBackgroundColor(tblVwAddInvite.backgroundColor!)
    }

    /// Load More data of friends
    ///
    /// - Parameter pageNum: page number
    func loadMoreDataFriends(with pageNum: Int) {

        if let _ = eventID {
            listAllFriendsInRespectToEventWebService(pageNo: pageNum,
                                                     completionHandler: { (_) -> Void in

                                    DispatchQueue.main.async {
                                        self.tblVwFriends.stopInfiniteScrollLoader()
                                    }
            })
        } else {
            listFriendsWebService(pageNo: pageNum,
                                  completionHandler: { (_) -> Void in

                                    DispatchQueue.main.async {
                                        self.tblVwFriends.stopInfiniteScrollLoader()
                                    }
            })
        }
    }

    /// Load More Data of Users
    ///
    /// - Parameter pageNum: page num
    func loadMoreDataUsers(with pageNum: Int) {

        if let _ = eventID {
            listAllUsersInRespectToEventWebService(pageNo: pageNum,
                                completionHandler: { (_) -> Void in

                                    DispatchQueue.main.async {
                                        self.tblVwAddInvite.stopInfiniteScrollLoader()
                                    }
            })
        } else {
            listUsersWebService(pageNo: pageNum,
                                completionHandler: { (_) -> Void in

                                    DispatchQueue.main.async {
                                        self.tblVwAddInvite.stopInfiniteScrollLoader()
                                    }
            })
        }
    }

    // MARK: - IBActions
    @IBAction func btnBackAction(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnDoneAction(_ sender: Any) {

        delegate?.sendBackSelectedFriendList(arrSelectedFriends: self.arrSelectedFriendList)
        self.dismiss(animated: true, completion: nil)
    }
}
