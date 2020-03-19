//
//  DefineEventVC.swift
//  Reach
//
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

class DefineEventVC: UIViewController, EventAPI {

    // MARK: - IBOutlets
    @IBOutlet weak var tblVwEvents: UITableView!

    // MARK: - Constraints
    @IBOutlet weak var constraintTblVwHt: NSLayoutConstraint!

    // MARK: - Variables
    var arrMyEvents = [MyEventModel]() //List of all those events that i can edit

    let rowHt: CGFloat = 80.0

    let headerHt: CGFloat = 80.0

    var pageNum = 1

    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGeusture()
        constraintTblVwHt.constant = 0
        tblVwEvents.delegate = self
        tblVwEvents.dataSource = self
        setInfiniteScrollOnTable()
        setPullToRefreshOnTable()
        listMyEventsWebService(pageNo: pageNum,
                               completionHandler: { (_) -> Void in
        })

        // Do any additional setup after loading the view.
    }

    func addTapGeusture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOffModal(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setNavBarHide(hide: true)
    }

    // deinit function
    deinit {
        // check atble avialable then remove
        if let tblView = self.tblVwEvents {
            tblView.dg_removePullToRefresh()
        }
    }

    // MARK: - Refresh Data

    /// Refresh data when drafts are created
    func refreshDataWithEditableEvents() {

        self.pageNum = 1
        self.tblVwEvents.hasMoreData = true
        self.arrMyEvents = []
        self.listMyEventsWebService(pageNo: self.pageNum,
                                    completionHandler: { (_) -> Void in

        })
    }

    // MARK: - Calculate Table Height

    /// Calculate Table Height
    func setTableHt() {
        let requiredTblHt = (rowHt * CGFloat(self.arrMyEvents.count)) + headerHt
        let availableHtForTable = UIScreen.main.bounds.height - tabBarHt - 84

        if CGFloat(requiredTblHt) < availableHtForTable {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                self.constraintTblVwHt.constant = CGFloat(requiredTblHt)
                self.view.layoutIfNeeded()
                self.view.updateConstraints()
            }, completion: nil)

        } else {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                self.constraintTblVwHt.constant = availableHtForTable
                self.view.layoutIfNeeded()
                self.view.updateConstraints()
            }, completion: nil)

        }
    }

    // MARK: - Set scroll & Pull to Refresh

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

    /// Set the pull to refersh
    func setPullToRefreshOnTable() {
        /// Set the loading view's indicator color
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.gray

        /// Add handler
        tblVwEvents.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.pageNum = 1
            self?.tblVwEvents.hasMoreData = true
            self?.arrMyEvents = []
            self?.listMyEventsWebService(pageNo: self!.pageNum,
                                         completionHandler: { (_) -> Void in
                self?.tblVwEvents.stopPullToRefreshLoader()
            })
            }, loadingView: loadingView)

        /// Set the background color of pull to refresh
        tblVwEvents.dg_setPullToRefreshFillColor(UIColor.clear)
        tblVwEvents.dg_setPullToRefreshBackgroundColor(tblVwEvents.backgroundColor!)
    }

    /// Load More data
    ///
    /// - Parameter pageNum: page num
    func loadMoreData(with pageNum: Int) {

        listMyEventsWebService( pageNo: pageNum,
                                completionHandler: { (_) -> Void in

            DispatchQueue.main.async {
                self.tblVwEvents.stopInfiniteScrollLoader()
            }
        })
    }

    // MARK: - Web service calls

    /// Validate Mobile Web service
    ///
    /// - Parameters:
    ///   - pageNo: page num
    ///   - completionHandler: completion hanlder
    func listMyEventsWebService(pageNo: Int,
                                completionHandler: @escaping CompletionHandler) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        listAllEvents(withHandler: { (eventDetails, isFromCache)  in

            guard let eventInfo = eventDetails else {

                self.tblVwEvents.hasMoreData = false
                completionHandler(true)
                return
            }

            if eventInfo.status == AppConstants.successServiceCode {

                guard let result = eventInfo.response,
                    let arrEvents = result.results else { return }

                if arrEvents.count < 8 || result.next == nil {
                    self.tblVwEvents.hasMoreData = false
                }

                self.arrMyEvents.append(contentsOf: arrEvents)
                self.tblVwEvents.reloadData()
                self.setTableHt()
                completionHandler(true)

            } else if eventInfo.status == AppConstants.tokenExpired {

                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {

                AppUtility.showAlert("",
                                     message: eventInfo.message,
                                     delegate: nil)
            }
        }) { (error) in
           AppUtility.showAlert("",
                                message: "Error",
                                delegate: nil)
        }
    }

    // MARK: - IBActions
    @IBAction func btnDoneAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {

        if segue.identifier == "openEventSegue" {
            if let createOpenPartyVC = segue.destination as? CreateOpenPartyVC {
                createOpenPartyVC.eventType = 1
            }
        } else {
            if let createClosePartyVC = segue.destination as? CreateClosePartyVC {
                createClosePartyVC.eventType = 2
            }
        }
    }
}

// MARK: - EditEventProtocol delegate Methods
extension DefineEventVC: EditEventProtocol {

    /// Edit Event
    ///
    /// - Parameter eventID: Event ID
    func editEvent(eventID: Int) {

        guard let editEvent = tabBarStoryboard.instantiateViewController(withIdentifier: "EditEventVC")
            as? EditEventVC else { return }
        editEvent.eventID = eventID
        self.navigationController?.pushViewController(editEvent,
                                         animated: true)

    }
}

// MARK: - SelectEventAction delegate Methods
extension DefineEventVC: SelectEventAction {

    /// Select Event Type
    ///
    /// - Parameter eventType: Event Type - Open/Close
    func selectEventType(eventType: Int) {

        if eventType == 1 { // An Open Event

            performSegue(withIdentifier: "openEventSegue", sender: nil)
        } else {            // Close Event

            performSegue(withIdentifier: "closeEventSegue", sender: nil)
        }
    }
}

// MARK: - UITableView Delegate and Datasource Methods

extension DefineEventVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

       return self.arrMyEvents.count
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventsToEditTableCell")
            as? EventsToEditTableCell else { return UITableViewCell() }
        cell.setContentToCell(objEvent: self.arrMyEvents[indexPath.row])
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegateEditEvent = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return rowHt
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DefineEventTableCell")
            as? DefineEventTableCell else { return nil }
        cell.delegateSelectEvent = self
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return headerHt
    }
}

extension DefineEventVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }

    @objc func handleTapOffModal(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}
