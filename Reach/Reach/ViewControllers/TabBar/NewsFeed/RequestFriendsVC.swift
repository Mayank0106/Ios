//
//  RequestFriendsVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

class RequestFriendsVC: UIViewController, FriendAPI, EventAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var txtSearch: UITextField!

    @IBOutlet weak var btnRequestFriend: UIButton!
    @IBOutlet weak var tblVwFriends: UITableView!

    // MARK: - Variables
    var arrFriends = [FriendModel]()

    var arrSelectedFriendList = [Int]()

    let htForRow: CGFloat = 64

    var searchTextFriends = ""

    var pageNumFriends = 1

    var eventID: Int?

    let headerHt: CGFloat = 30

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        btnRequestFriend.setTitle("Done", for: .normal)

        setUpTextField()
        setPullToRefreshOnFriendsTable()
        setInfiniteScrollOnTableFriends()
        listFriendsWebService(pageNo: pageNumFriends,
                              completionHandler: { (_) -> Void in
        })
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        setNavBarHide(hide: true)
    }

    // deinit function
    deinit {

        if let tblView = self.tblVwFriends {
            tblView.dg_removePullToRefresh()
        }
    }

    // MARK: - Set Up UI

    /// Seting up text field
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

    // MARK: - Set Pull To Refresh & Infinte Scroller

    /// Set Infinite Scroll on Table View
    func setInfiniteScrollOnTableFriends() {

        tblVwFriends.hasMoreData = true
        tblVwFriends.addPushRefreshHandler({ [weak self] in
            if let pageNum = self?.pageNumFriends {

                self?.pageNumFriends = pageNum + 1
                self?.loadMoreDataFriends(with: (self?.pageNumFriends)!)
            }
        })
    }

    /// Set the Pull to Refersh on Table View
    func setPullToRefreshOnFriendsTable() {

        /// Set the loading view's indicator color
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.gray

        /// Add handler
        tblVwFriends.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.pageNumFriends = 1
            self?.tblVwFriends.hasMoreData = true
            self?.arrFriends = []
            self?.listFriendsWebService(pageNo: self!.pageNumFriends,
                                        completionHandler: { (_) -> Void in

                self?.tblVwFriends.stopPullToRefreshLoader()
            })
            }, loadingView: loadingView)

        /// Set the background color of pull to refresh
        tblVwFriends.dg_setPullToRefreshFillColor(UIColor.clear)
        tblVwFriends.dg_setPullToRefreshBackgroundColor(tblVwFriends.backgroundColor!)
    }

    /// Load More Data
    ///
    /// - Parameter pageNum: page number
    func loadMoreDataFriends(with pageNum: Int) {

        listFriendsWebService(pageNo: pageNum,
                              completionHandler: { (_) -> Void in

            DispatchQueue.main.async {
                self.tblVwFriends.stopInfiniteScrollLoader()
            }
        })
    }

    // MARK: - Create Models

    /// Create Event Model
    ///
    /// - Returns: Request Model
    func createEventModel() -> RequestModel {

        var objModel = RequestModel()
        objModel.id = eventID
        objModel.friendsID = arrSelectedFriendList
        return objModel
    }

    // MARK: - Web service calls

    /// List All my friends Web service
    ///
    /// - Parameters:
    ///   - pageNo: page number
    ///   - completionHandler: completion handler
    func listFriendsWebService(pageNo: Int,
                               completionHandler: @escaping CompletionHandler) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        guard let eventId = eventID else { return }
        listAllFriendsInRespectToEvent(searchTextFriends,
                                       eventID: eventId,
                                       page: pageNo,
                                       withHandler: { (friendDetails, isFromCache)  in

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

                self.arrFriends.append(contentsOf: friends)
                self.tblVwFriends.reloadData()
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

    /// Request friends for an event Web service
    func requestFriendsForEventWebService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)

            return
        }

        let event = createEventModel()
        requestFriendsForAnEvent(body: event,
                                 withHandler: { (feedDetails, _)  in

            guard let feedInfo = feedDetails else { return }

            if feedInfo.status == AppConstants.successServiceCode {

                self.dismiss(animated: true,
                             completion: nil)

            } else if feedInfo.status == AppConstants.tokenExpired {

                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {

                AppUtility.showAlert("",
                                     message: feedInfo.message,
                                     delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("",
                                 message: "Error",
                                 delegate: nil)
        }
    }

    // MARK: - IBActions
    @IBAction func btnClosePopOverAction(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnRequestAction(_ sender: Any) {

        if arrSelectedFriendList.count > 0 {
            requestFriendsForEventWebService()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @objc func btnImgFriendAction(_ sender: UIButton) {
        
        
        //let friendID = arrFriends[sender.tag]
        //profileAction(userID: friendID.id)
        
    }
    //
}

// MARK: - UITableView Delegate and Datasource Methods

extension RequestFriendsVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

       return self.arrFriends.count
    }

    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RequestFriendTableCell")
            as? RequestFriendTableCell else { return UITableViewCell() }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.setContentToCell(friend: arrFriends[indexPath.row])
        cell.btnImgFriend.tag = indexPath.row
        cell.btnSelect.isUserInteractionEnabled = false
        //cell.btnSelect.isEnabled = false
//        cell.btnImgFriend.addTarget(self, action: #selector(btnImgFriendAction(_:)), for: .touchUpInside)
        
        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        return htForRow
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        guard let isInvited = arrFriends[indexPath.row].isInvited else { return }
        if isInvited { return }

        arrFriends[indexPath.row].isSelected = !arrFriends[indexPath.row].isSelected

        if let cell = self.tblVwFriends.cellForRow(at: IndexPath(item: indexPath.row,
                                                                 section: 0))
            as? RequestFriendTableCell {

            cell.btnSelect.isSelected = arrFriends[indexPath.row].isSelected
            if cell.btnSelect.isSelected {

                self.arrSelectedFriendList.append(arrFriends[indexPath.row].id!)
            } else {

                let index = self.arrSelectedFriendList.index(where: { (friendID) -> Bool in
                    friendID == arrFriends[indexPath.row].id! // test if this is the item you're looking for
                })
                if let indexExists = index {

                    self.arrSelectedFriendList.remove(at: indexExists)
                }
            }
        }
        
        
        if arrSelectedFriendList.count > 0 {
            btnRequestFriend.setTitle("Request", for: .normal)
        } else {
            btnRequestFriend.setTitle("Done", for: .normal)
        }
        //btnRequestFriend
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {

        let containerView = UIView()
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendSectionHeader")
            as? AddFriendSectionHeader else { return nil }
        cell.lblHeader.text = "Your Friends"
        containerView.addSubview(cell)
        return containerView
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {

        return headerHt
    }
}

// MARK: - UITextField Delegate Methods
extension RequestFriendsVC: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        self.view.endEditing(true)
        if textField.text! != searchTextFriends {

            searchTextFriends = textField.text!
            self.pageNumFriends = 1
            self.arrFriends = []
            self.tblVwFriends.hasMoreData = true
            self.tblVwFriends.setContentOffset(.zero, animated: true)
            listFriendsWebService(pageNo: self.pageNumFriends,
                                  completionHandler: { (_) -> Void in
            })
        }

        return true
    }
}
