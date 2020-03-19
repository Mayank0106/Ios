//
//  InvitationListVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

class InvitationListVC: UIViewController, FriendAPI, EventAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var txtVwSearch: UITextField!

    @IBOutlet weak var tblVwFriends: UITableView!

    @IBOutlet weak var lblGirlsBoysCount: UILabel!

    @IBOutlet weak var lblGoingCount: UILabel!

    // MARK: - Variables
    var arrFriends = [FriendModel]()

    let htForSection: CGFloat = 66

    let htForRowRequestedFriends: CGFloat = 128

    let htForRowBringingFriends: CGFloat = 82

    var pageNum = 1

    var searchText = ""

    var eventID: Int?

    var femaleInvitationCount: Int?

    var maleInvitationCount: Int?

    var goingCount: Int?

    var isMyEvent: Bool = false

    var selectedFriendID: Int?

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
       // setUpTextField()
        guard let femaleCount = femaleInvitationCount,
            let maleCount = maleInvitationCount else { return }

        lblGirlsBoysCount.attributedText = AppUtility.setAttributedStringForEventDetail(girls: String(femaleCount) + " Girls",
                                                                                        boys: String(maleCount) + " Boys",
                                                                                        isFromInvitationList: true)
        guard let goingCount = goingCount else { return }
        lblGoingCount.text = String(goingCount) + " Going So Far"

        setInfiniteScrollOnTable()
        setPullToRefreshOnTable()
        listAllInvitationsWebService(pageNo: pageNum,
                                     completionHandler: { (_) -> Void in
        })
        // Do any additional setup after loading the view.
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                _ = self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
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
    }

    // MARK: - Set Up UI

    /// Set Up search in text field
    func setUpTextField() {

        txtVwSearch.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.52)
        txtVwSearch.attributedPlaceholder = NSAttributedString(string: "Search",
                                                               attributes: [NSAttributedStringKey.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.52)])

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

    // MARK: - Set Up pull to refersh & Scrolling

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
            self?.listAllInvitationsWebService(pageNo: self!.pageNum,
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

        listAllInvitationsWebService(pageNo: pageNum,
                                     completionHandler: { (_) -> Void in

            DispatchQueue.main.async {
                self.tblVwFriends.stopInfiniteScrollLoader()
            }
        })
    }

    /// Create Event Model
    ///
    /// - Parameters:
    ///   - isAccept: is accepted
    ///   - frndId: friend id
    /// - Returns: request model
    func createEventModel(isAccept: Bool,
                          frndId: Int) -> RequestModel {

        var objModel = RequestModel()
        objModel.id = eventID
        objModel.frndID = frndId
        objModel.accept = isAccept
        return objModel
    }

    // MARK: - Web service calls

    /// List All Invitations Web service
    func listAllInvitationsWebService(pageNo: Int,
                                      completionHandler: @escaping CompletionHandler) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        guard let eventID = eventID else { return }
        listAllInvitations(eventID,
                           page: pageNo,
                           search: searchText,
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

    /// Accept Invitation For an event web service
    ///
    /// - Parameters:
    ///   - isAccept: Is Accept
    ///   - frndId: Friend ID
    func acceptRejectInvitationForEventWebService(isAccept: Bool,
                                                  frndId: Int) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        let eventModel = createEventModel(isAccept: isAccept,
                                          frndId: frndId)
        acceptRejectInvitation(body: eventModel,
                               withHandler: { (feedDetails, _)  in

            guard let feedInfo = feedDetails else { return }

            if feedInfo.status == AppConstants.successServiceCode {

                for (indexOuter, friend) in self.arrFriends.enumerated() {

                    guard var arrRequestedInvitations = friend.arrRequestedInvitations else { return }
                    for (indexInner, invitation) in arrRequestedInvitations.enumerated() {
                        guard let invitedFrndID = invitation.id else { return }

                        if invitedFrndID == frndId {
                            if isAccept {
                                self.arrFriends[indexOuter].arrRequestedInvitations?[indexInner].isInvited = true
                                self.tblVwFriends.reloadData()
                            } else {
                                arrRequestedInvitations.remove(at: indexInner)
                                self.arrFriends[indexOuter].arrRequestedInvitations = arrRequestedInvitations
                                self.tblVwFriends.reloadData()
                            }
                        }
                    }
                }

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
    @IBAction func btnBackAction(_ sender: Any) {

        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - AcceptRejectInvitation Delegate Methods

extension InvitationListVC: AcceptRejectInvitation {

    /// Accept Invitation
    ///
    /// - Parameter friendID: Friend ID
    func acceptInvitation(friendID: Int) {

        acceptRejectInvitationForEventWebService(isAccept: true,
                                                 frndId: friendID)
    }

    /// Reject Invitation
    ///
    /// - Parameter friendID: Friend ID
    func rejectInvitation(friendID: Int) {

        acceptRejectInvitationForEventWebService(isAccept: false,
                                                 frndId: friendID)
    }
}
