//
//  NewsFeedVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Kingfisher

class NewsFeedVC: UIViewController, EventAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var tblVwNews: UITableView!

    @IBOutlet weak var lblNoEvents: UILabel!

    @IBOutlet weak var btnProfile: UIButton!

    // MARK: - Variables
    var arrFeeds = [MyEventModel]()

    let htForRow: CGFloat = 486.0

    var pageNum = 1

    var viewLoadCalled: Bool = false

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        viewLoadCalled = true
        self.tblVwNews.delegate = self
        self.tblVwNews.dataSource = self

        setInfiniteScrollOnTable()
        setPullToRefreshOnTable()

        // Feeds Webservice
        listMyNewsFeedWebService(pageNo: pageNum,
                                 completionHandler: { (_) -> Void in
        })
        //Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {

        setNavBarHide(hide: true)
        if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
            let userObj = data as? UserModel,
            let uerImage = userObj.profileImage {

            if let myImageUrl = URL(string: uerImage) {
                btnProfile.kf.setImage(with: ImageResource(downloadURL: myImageUrl),
                                       for: .normal, placeholder: UIImage(named: "avatarImage"),
                                       options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                       progressBlock: nil,
                                       completionHandler: nil)
            }
        }

        if !viewLoadCalled && arrFeeds.isEmpty {
            listMyNewsFeedWebService(pageNo: pageNum,
                                     completionHandler: { (_) -> Void in
            })
        }
        viewLoadCalled = false
    }

    override func viewWillDisappear(_ animated: Bool) {

         btnProfile.isUserInteractionEnabled = true
    }

    // deinit function
    deinit {
        // check atble avialable then remove
        if let tblView = self.tblVwNews {
            tblView.dg_removePullToRefresh()
        }
    }

    // MARK: - Refresh Data With New Events

    /// Refresh Data with new events
    func refreshDataWithNewEvents() {
        self.pageNum = 1
        self.tblVwNews.hasMoreData = true
        self.arrFeeds = []
        self.listMyNewsFeedWebService(pageNo: self.pageNum,
                                      completionHandler: { (_) -> Void in

        })
    }

    // MARK: - Show/Hide Table

    /// Show Hide Table/No Events Label
    func showHideTable() {

        if self.arrFeeds.isEmpty {
            self.lblNoEvents.isHidden = false
            self.tblVwNews.isHidden = true
        } else {
            self.lblNoEvents.isHidden = true
            self.tblVwNews.isHidden = false
        }
    }

    // MARK: - Set Pull & Infinte Scroller To Refresh

    /// Set the pull to refersh
    func setPullToRefreshOnTable() {
        /// Set the loading view's indicator color
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.gray

        /// Add handler
        tblVwNews.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in

            self?.pageNum = 1
            self?.tblVwNews.hasMoreData = true
            self?.arrFeeds = []
            self?.listMyNewsFeedWebService(pageNo: self!.pageNum,
                                           completionHandler: { (_) -> Void in
                self?.tblVwNews.stopPullToRefreshLoader()
            })
            }, loadingView: loadingView)

        /// Set the background color of pull to refresh
        tblVwNews.dg_setPullToRefreshFillColor(UIColor.clear)
        tblVwNews.dg_setPullToRefreshBackgroundColor(tblVwNews.backgroundColor!)
    }

    /// Set infinite scroll on table view
    func setInfiniteScrollOnTable() {
        tblVwNews.hasMoreData = true
        tblVwNews.addPushRefreshHandler({ [weak self] in
            if let pageNum = self?.pageNum {
                self?.pageNum = pageNum + 1
                self?.loadMoreData(with: (self?.pageNum)!)
            }
        })
    }

    /// Load More data
    ///
    /// - Parameter pageNum: page number
    func loadMoreData(with pageNum: Int) {

        listMyNewsFeedWebService( pageNo: pageNum,
                                  completionHandler: { (_) -> Void in

            DispatchQueue.main.async {
                self.tblVwNews.stopInfiniteScrollLoader()
            }
        })
    }

    // MARK: - Web service calls

    /// List my news feed
    ///
    /// - Parameters:
    ///   - pageNo: page no
    ///   - completionHandler: completion handler
    func listMyNewsFeedWebService(pageNo: Int,
                                  completionHandler: @escaping CompletionHandler) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        listAllFeeds(page: pageNo,
                     withHandler: { (feedDetails, _)  in

            guard let feedInfo = feedDetails else {
                self.tblVwNews.hasMoreData = false
                completionHandler(true)
                return
            }

            if feedInfo.status == AppConstants.successServiceCode {
                guard let result = feedInfo.response, let feeds = result.results else { return }

                if feeds.count < 8 || result.next == nil {
                    self.tblVwNews.hasMoreData = false
                }
                self.arrFeeds.append(contentsOf: feeds)
                self.tblVwNews.reloadData()
                self.showHideTable()
                completionHandler(true)

            } else if feedInfo.status == AppConstants.tokenExpired {
                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {
                AppUtility.showAlert("", message: feedInfo.message, delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    /// Mark Going for an event
    ///
    /// - Parameters:
    ///   - eventID: event id
    ///   - userModel: user model
    func goingForAnEventWebService(eventID: Int,
                                   userModel: FriendModel) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        goingForEvent(eventID: eventID,
                      withHandler: { (feedDetails, _)  in

            guard let feedInfo = feedDetails else { return }

            if feedInfo.status == AppConstants.successServiceCode {

                let index = self.arrFeeds.index(where: { (feed) -> Bool in
                    feed.id == eventID // test if this is the item you're looking for
                })
                if let indexExists = index {

                    self.arrFeeds[indexExists].isGoing = true
                    if let goingCount = self.arrFeeds[indexExists].goingCount {
                        self.arrFeeds[indexExists].goingCount = goingCount + 1
                    }
                    if self.arrFeeds[indexExists].peopleGoing != nil {
                        self.arrFeeds[indexExists].peopleGoing?.append(userModel)
                    }
                    let indexPath = IndexPath(row: indexExists,
                                              section: 0)
                    self.tblVwNews.reloadRows(at: [indexPath],
                                              with: UITableViewRowAnimation.none)
                }

            } else if feedInfo.status == AppConstants.tokenExpired {

                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {

                AppUtility.showAlert("", message: feedInfo.message, delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
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
}

// MARK: - GoingForEvent Delegate Methods
extension NewsFeedVC: GoingForEvent {

    /// Mark Event as Going
    ///
    /// - Parameters:
    ///   - eventID: event ID
    ///   - userModel: User Model
    func markEventAsGoing(eventID: Int,
                          userModel: FriendModel) {

        goingForAnEventWebService(eventID: eventID,
                                  userModel: userModel)
    }

    func openEditEvent(eventID: Int) {

        guard let editEvent = tabBarStoryboard.instantiateViewController(withIdentifier: "EditEventVC")
            as? EditEventVC else { return }
        editEvent.eventID = eventID
        editEvent.isFromEventDetail = true
        self.navigationController?.pushViewController(editEvent,
                                                      animated: true)
    }
}

// MARK: - UpdateNewsFeed Delegate Methods
extension NewsFeedVC: UpdateNewsFeed {

    /// Update Going Sttaus
    ///
    /// - Parameters:
    ///   - isGoing: True/False
    ///   - eventID: Event ID
    func updateGoingStatus(isGoing: Bool,
                           eventID: Int) {

        let index = self.arrFeeds.index(where: { (feed) -> Bool in
            feed.id == eventID // test if this is the item you're looking for
        })
        if let indexExists = index {

            self.arrFeeds[indexExists].isGoing = true
            let indexPath = IndexPath(item: indexExists,
                                      section: 0)
            tblVwNews.reloadRows(at: [indexPath],
                                 with: .top)

        }
    }

    /// Delete Event
    ///
    /// - Parameter eventID: Event ID
    func deleteEvent(eventID: Int) {
        let index = self.arrFeeds.index(where: { (feed) -> Bool in
            feed.id == eventID // test if this is the item you're looking for
        })

        if let indexExists = index {

            self.arrFeeds.remove(at: indexExists)
            self.tblVwNews.deleteRows(at: [IndexPath(item: indexExists,
                                                     section: 0)],
                                      with: .automatic)

        }
    }

    /// Update Going Count
    ///
    /// - Parameter eventID: Event ID
    func updateGoingCount(eventID: Int) {

        let index = self.arrFeeds.index(where: { (feed) -> Bool in
            feed.id == eventID // test if this is the item you're looking for
        })
        if let indexExists = index {

            guard let goingCount = self.arrFeeds[indexExists].goingCount else { return }
            self.arrFeeds[indexExists].goingCount = goingCount + 1
            let indexPath = IndexPath(item: indexExists,
                                      section: 0)
            tblVwNews.reloadRows(at: [indexPath],
                                 with: .top)

        }
    }
}

// MARK: - UITableView Delegate and Datasource Methods

extension NewsFeedVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.arrFeeds.count
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsFeedTableCell")
            as? NewsFeedTableCell else { return UITableViewCell() }
        cell.setContentToCell(feed: arrFeeds[indexPath.row])
        cell.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let event = arrFeeds[indexPath.row]
        let eventID = event.id

        // Add Transition layer
        /*
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionReveal
        transition.subtype = kCATransitionFromBottom
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)*/

        guard let eventDetailVC = tabBarStoryboard.instantiateViewController(withIdentifier: "EventDetailVC")
            as? EventDetailVC else { return }
        eventDetailVC.eventID = eventID
        eventDetailVC.delegate = self
        eventDetailVC.imageURL = event.bannerImage
        self.navigationController?.pushViewController(eventDetailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return htForRow
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return htForRow
    }
}
