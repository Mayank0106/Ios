//
//  EditEventWebservicesExtension.swift
//  Reach
//
//  Created by Aanchal Jain on 29/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit

extension EditEventVC {

    // MARK: - Web service calls

    /// Get Party Datas Web Service
    func getDataWebService() {

        self.view.endEditing(true)
        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        guard let eventId = self.eventID else { return }

        eventDetail(eventID: eventId,
                    withHandler: { (feedDetails, _)  in

                        guard let feedInfo = feedDetails else { return }

                        if feedInfo.status == AppConstants.successServiceCode {

                            guard let result = feedInfo.response else { return }
                            self.eventDetail = result
                            self.setDataManager()
                        } else if feedInfo.status == AppConstants.tokenExpired {

                            appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
                        } else {

                            AppUtility.showAlert("", message: feedInfo.message, delegate: nil)
                        }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    /// Edit Party Event Web Service
    ///
    /// - Parameter bannerImageURL: Banner Image URL
    /// - Parameter isDraft: isDraft
    func editPartyEventWebService(bannerImageURL: String?) {

        self.view.endEditing(true)
        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("",
                                 message: "NetworkError".localized,
                                 delegate: self)
            return
        }

        guard let eventId = eventID else { return }
        guard let eventModel = self.createEventModel(bannerImageURL: bannerImageURL) else { return }

        editEvent(eventID: eventId, eventModel, withHandler: { (eventDetails, isFromCache)  in

            guard let eventInfo = eventDetails else { return }

            if eventInfo.status == AppConstants.successServiceCode {

                if self.isFromEventDetail {

                    self.navigationController?.popToRootViewController(animated: true)
                } else {
                    guard let tabbar = appDelegate.window?.rootViewController
                        as? UITabBarController else { return }

                    guard let newsFeedNavController = tabbar.viewControllers?[0]
                        as? UINavigationController else { return }
                    guard let newsFeedController = newsFeedNavController.viewControllers[0]
                        as? NewsFeedVC else { return }

                    newsFeedController.refreshDataWithNewEvents()
                    self.dismiss(animated: true, completion: nil)
                }

            } else if eventInfo.status == AppConstants.tokenExpired {

                appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
            } else {

                print(eventInfo.message)
                AppUtility.showAlert("", message: eventInfo.message, delegate: nil)
            }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    /// Delete Event Invitations
    ///
    /// - Parameters:
    ///   - eventID: event id
    ///   - userModel: user model
    func deleteEventInvitationsWebService(eventID: Int, handler: @escaping CompletionHandler) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        deleteInvitation(eventID: eventID,
                      withHandler: { (feedDetails, _)  in

                        guard let feedInfo = feedDetails else { return }

                        if feedInfo.status == AppConstants.successServiceCode {

                            handler(true)

                        } else if feedInfo.status == AppConstants.tokenExpired {

                            appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
                        } else {

                            AppUtility.showAlert("", message: feedInfo.message, delegate: nil)
                        }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

}
