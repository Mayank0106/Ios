//
//  ProfileVCExtension.swift
//  Reach
//
//  Created by Aanchal Jain on 12/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Foundation

// MARK: - UITableView Delegate and Datasource Methods

extension ProfileVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        return self.arrFeeds.count
    }

    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell")
            as? ProfileTableViewCell else { return UITableViewCell() }
        cell.setContentToCell(feed: arrFeeds[indexPath.row])
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        let eventID = arrFeeds[indexPath.row].id
        guard let eventDetailVC = tabBarStoryboard.instantiateViewController(withIdentifier: "EventDetailVC")
            as? EventDetailVC else { return }
        eventDetailVC.eventID = eventID
        self.navigationController?.pushViewController(eventDetailVC,
                                                      animated: true)
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        return htForRow

    }
}

extension ProfileVC {

    // MARK: - Web service calls

    /// Web service call to fetch profile
    func callWebserviceToFetchProfileData() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        guard let userID = userID else { return }
        profileData(userID: userID,
                    withHandler: { (userDetails, isFromCache)  in

                        guard let userInfo = userDetails else { return }

                        if userInfo.status == AppConstants.successServiceCode {

                            guard let result = userInfo.response else { return }
                            self.objProfile = result
                            self.setUI()

                        } else if userInfo.status == AppConstants.tokenExpired {

                            appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
                        } else {
                            AppUtility.showAlert("",
                                                 message: userInfo.message,
                                                 delegate: nil)
                        }
        }) { (error) in
            AppUtility.showAlert("",
                                 message: "Error",
                                 delegate: nil)
        }
    }

    /// Web service call to fetch profile events
    ///
    /// - Parameters:
    ///   - showLoader: Show Loader
    ///   - pageNo: page no
    ///   - completionHandler: completion handler
    func callWebserviceToFetchProfileEvents(showLoader: Bool, pageNo: Int,
                                            completionHandler: @escaping CompletionHandler) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        guard let userID = userID else { return }
        profileEvents(showLoader: showLoader, userID: userID,
                      withHandler: { (feedDetails, isFromCache)  in

                        guard let feedInfo = feedDetails else { return }

                        if feedInfo.status == AppConstants.successServiceCode {

                            guard let result = feedInfo.response,
                                let feeds = result.results else { return }

                            if feeds.count < 8 || result.next == nil {
                                self.tblVwEvents.hasMoreData = false
                            }

                            self.arrFeeds.append(contentsOf: feeds)
                            self.tblVwEvents.reloadData()
                            completionHandler(true)

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

                                    self.setButtons(friendStatus: 1)

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

                                self.setButtons(friendStatus: 2)

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
}
