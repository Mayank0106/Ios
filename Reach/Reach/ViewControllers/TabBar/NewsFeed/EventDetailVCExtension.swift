//
//  EventDetailVCExtension.swift
//  Reach
//
//  Created by Aanchal Jain on 12/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Foundation

extension EventDetailVC {

    // MARK: - Web service calls

    /// Fetch Event Detail Web Service
    func fetchEventDetailWebService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        guard let eventID = eventID else { return }
        eventDetail(eventID: eventID,
                    withHandler: { (feedDetails, _)  in

                        guard let feedInfo = feedDetails else { return }

                        if feedInfo.status == AppConstants.successServiceCode {

                            guard let result = feedInfo.response else { return }
                            self.eventDetail = result
                            self.setUI()

                        } else if feedInfo.status == AppConstants.tokenExpired {

                            appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
                        } else {

                            AppUtility.showAlert("", message: feedInfo.message, delegate: nil)
                        }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    /// Delete Event Web Service
    func deleteEventWebService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        guard let eventID = eventID else { return }
        deleteEvent(eventID: eventID,
                    withHandler: { (feedDetails, _)  in

                      //  self.vwTransparent.isHidden = true

                        guard let feedInfo = feedDetails else { return }

                        if feedInfo.status == AppConstants.successServiceCode {

                            let alertController = UIAlertController(title: "",
                                                                    message: "Event deleted",
                                                                    preferredStyle: .alert)

                            // Create the actions
                            let okAction = UIAlertAction(title: "OK".localized,
                                                         style: UIAlertActionStyle.default) {
                                                            UIAlertAction in
                                                            self.delegate?.deleteEvent(eventID: self.btnDelete.tag)
                                                            self.navigationController?.popToRootViewController(animated: true)
                            }

                            // Add the actions
                            alertController.addAction(okAction)

                            // Present the controller
                            self.present(alertController, animated: true, completion: nil)

                        } else if feedInfo.status == AppConstants.tokenExpired {

                            appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
                        } else {

                            AppUtility.showAlert("", message: feedInfo.message, delegate: nil)
                        }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    /// Report Event Web Servcie
    ///
    /// - Parameter strText: Message to report
    func reportEventWebService(strText: String) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        let event = createEventModel(strText: strText)
        reportEvent(body: event,
                    withHandler: { (feedDetails, _)  in

                       // self.vwTransparent.isHidden = true

                        guard let feedInfo = feedDetails else { return }

                        if feedInfo.status == AppConstants.successServiceCode {
                            // You reported for event

                        } else if feedInfo.status == AppConstants.tokenExpired {

                            appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
                        } else {

                            AppUtility.showAlert("", message: feedInfo.message, delegate: nil)
                        }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    /// Mark Event as Going Web Service
    func goingForAnEventWebService() {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }
        guard let eventID = eventID else { return }
        goingForEvent(eventID: eventID,
                      withHandler: { (feedDetails, _)  in

                        //self.vwTransparent.isHidden = true

                        guard let feedInfo = feedDetails else { return }

                        if feedInfo.status == AppConstants.successServiceCode {

                            self.btnGoing.isHidden = true
                            self.btnGoingSelected.isHidden = false
                            self.btnGoingSelected.isUserInteractionEnabled = false
                            self.delegate?.updateGoingStatus(isGoing: true,
                                                             eventID: self.btnGoing.tag)
                            self.delegate?.updateGoingCount(eventID: self.btnGoing.tag)
                            // Change button

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
    @objc func removeTransparentView(sender: UIButton) {

        self.vwTransparent.isHidden = true
    }

    @IBAction func btnDoneAction(_ sender: Any) {
        // Add Transition layer
        //        let transition:CATransition = CATransition()
        //        transition.duration = 0.5
        //        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        //        transition.type = kCATransitionReveal
        //        transition.subtype = kCATransitionFromTop
        //        self.navigationController!.view.layer.add(transition, forKey: kCATransition)

        //        let transition = CATransition()
        //        transition.duration = 0.5
        //        transition.type = kCATransitionFade
        //        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnMoreActions(_ sender: Any) {

        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetController: UIAlertController = UIAlertController(title: "", message: "Please select an option", preferredStyle: .actionSheet)

        if isMyEvent() {
            let saveActionButton = UIAlertAction(title: "Delete Event", style: .default) { _ in
                let alertController = UIAlertController(title: "",
                                                        message: "Are you sure you want to delete this event?",
                                                        preferredStyle: .alert)

                // Create the actions
                let okAction = UIAlertAction(title: "OK".localized,
                                             style: UIAlertActionStyle.default) {
                                                UIAlertAction in
                                                self.deleteEventWebService()
                }

                let cancelAction = UIAlertAction(title: "Cancel",
                                                 style: UIAlertActionStyle.destructive) {
                                                    UIAlertAction in
                                                    // do nothing
                }

                // Add the actions
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)

                // Present the controller
                self.present(alertController, animated: true, completion: nil)
            }
            actionSheetController.addAction(saveActionButton)

        } else {

            let deleteActionButton = UIAlertAction(title: "Report Event", style: .default) { _ in
                let alertController = UIAlertController(title: "Report Event",
                                                        message: "Please input something",
                                                        preferredStyle: UIAlertControllerStyle.alert)

                let reportAction = UIAlertAction(title: "Report",
                                           style: .default) { (alertAction) in

                                            let textField = alertController.textFields![0] as UITextField
                                            self.reportEventWebService(strText: textField.text!)
                }

                let cancelAction = UIAlertAction(title: "Cancel",
                                                 style: UIAlertActionStyle.destructive) {
                                                    UIAlertAction in
                                                    // do nothing
                }

                alertController.addTextField { (textField) in
                    textField.placeholder = "Please input something"
                }

                alertController.addAction(cancelAction)
                alertController.addAction(reportAction)

                self.present(alertController, animated: true, completion: nil)
            }
            actionSheetController.addAction(deleteActionButton)
        }

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive) { _ in
        }
        actionSheetController.addAction(cancelActionButton)

        self.present(actionSheetController, animated: true, completion: nil)
       // vwTransparent.isHidden = false
    }

    @IBAction func btnGroupChatAction(_ sender: Any) {

        let chatVC = ChatViewController()
        if let data = KeychainWrapper.standard.object(forKey: AppConstants.userModelKeyChain),
            let userObj = data as? UserModel,
            let userID = userObj.id {

            chatVC.userID = userID
            var arrOpponents = [Int]()
            guard let invitationList = eventDetail.invitationList else { return }
            for invitation in invitationList {
                arrOpponents.append(invitation.id!)
            }
            guard let hostDetails = eventDetail.host,
                let myUserId = hostDetails.id else { return }

            arrOpponents.append(myUserId)
            chatVC.arrOpponentIds = arrOpponents
            chatVC.event = eventDetail
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }

    @IBAction func btnFriendListAction(_ sender: Any) {

        self.performSegue(withIdentifier: "fromEventDetailToInvitationList",
                          sender: nil)

    }

    @IBAction func btnEditAction(_ sender: Any) {

        guard let editEvent = tabBarStoryboard.instantiateViewController(withIdentifier: "EditEventVC")
            as? EditEventVC else { return }
        editEvent.eventID = eventID
        editEvent.isFromEventDetail = true
        self.navigationController?.pushViewController(editEvent,
                                                      animated: true)
    }

    @IBAction func btnRequestFriendAction(_ sender: Any) {

        self.performSegue(withIdentifier: "fromEventDetailToRequestFriends",
                          sender: nil)
    }

    @IBAction func btnGoingAction(_ sender: Any) {

        goingForAnEventWebService()
    }

    @IBAction func btnDeleteEventAction(_ sender: Any) {

    }

    @IBAction func btnReportEventAction(_ sender: Any) {

        let alertController = UIAlertController(title: "Report Event",
                                                message: "Please input something",
                                                preferredStyle: UIAlertControllerStyle.alert)

        let action = UIAlertAction(title: "Report",
                                   style: .default) { (alertAction) in

                                    let textField = alertController.textFields![0] as UITextField
                                    self.reportEventWebService(strText: textField.text!)
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Please input something"
        }

        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

}
