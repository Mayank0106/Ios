//
//  InviteFriendsVCExtension.swift
//  Reach
//
//  Created by Aanchal Jain on 12/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Foundation

// MARK: - UITableView Delegate and Datasource Methods

extension InviteFriendsVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        switch objCategory {
        case .friends:
            return self.arrFriends.count
        default:
            return self.arrAddInvite.count
        }
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InviteFriendsTableCell")
            as? InviteFriendsTableCell else { return UITableViewCell() }
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        switch objCategory {
        case .friends:

            if eventID != nil {
                cell.setContentToCell(friend: arrFriends[indexPath.row],
                                      isFriendsView: true, isEditEvent: true)
            } else {
                cell.setContentToCell(friend: arrFriends[indexPath.row],
                                      isFriendsView: true)
            }

        default:
            if eventID != nil {
                cell.setContentToCell(friend: arrAddInvite[indexPath.row],
                                      isFriendsView: false, isEditEvent: true)
            } else {
                cell.setContentToCell(friend: arrAddInvite[indexPath.row],
                                      isFriendsView: false)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        return htForRow
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        if objCategory == .friends {
            arrFriends[indexPath.row].isSelected = !arrFriends[indexPath.row].isSelected

            if let cell = self.tblVwFriends.cellForRow(at: IndexPath(item: indexPath.row,
                                                                     section: 0)) as? InviteFriendsTableCell {

                cell.btnSelect.isSelected = arrFriends[indexPath.row].isSelected
                if cell.btnSelect.isSelected {
                    cell.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
                    cell.lblName.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    var friendModel = FriendModel()
                    friendModel.id = arrFriends[indexPath.row].id
                    friendModel.isFriend = true
                    friendModel.profileImage = arrFriends[indexPath.row].profileImage
                    self.arrSelectedFriendList.append(friendModel)
                } else {
                    cell.backgroundColor = UIColor.white
                    cell.lblName.textColor = #colorLiteral(red: 0.2039215686, green: 0.2039215686, blue: 0.2039215686, alpha: 1)
                    let index = self.arrSelectedFriendList.index(where: { (friend) -> Bool in
                        friend.id == arrFriends[indexPath.row].id! // test if this is the item you're looking for
                    })
                    if let indexExists = index {

                        self.arrSelectedFriendList.remove(at: indexExists)
                    }
                }
            }
        } else {
            arrAddInvite[indexPath.row].isSelected = !arrAddInvite[indexPath.row].isSelected

            if let cell = self.tblVwAddInvite.cellForRow(at: IndexPath(item: indexPath.row,
                                                                       section: 0)) as? InviteFriendsTableCell {

                cell.btnAddInvite.isSelected = arrAddInvite[indexPath.row].isSelected

                if cell.btnAddInvite.isSelected {
                    var friendModel = FriendModel()
                    friendModel.id = arrAddInvite[indexPath.row].id
                    friendModel.isFriend = false
                    friendModel.profileImage = arrAddInvite[indexPath.row].profileImage
                    self.arrSelectedFriendList.append(friendModel)
                } else {

                    let index = self.arrSelectedFriendList.index(where: { (friend) -> Bool in
                        friend.id == arrAddInvite[indexPath.row].id! // test if this is the item you're looking for
                    })
                    if let indexExists = index {

                        self.arrSelectedFriendList.remove(at: indexExists)
                    }
                }
            }
        }

        self.lblNoOfPeople.text = String(self.arrSelectedFriendList.count)
    }
}

// MARK: - UITextFieldDelegate Methods
extension InviteFriendsVC: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let strText = textField.text! as NSString
        let newText = strText.replacingCharacters(in: range, with: string)
        setDefaultSettingsAndfetchData(strSearch: newText)
        return true
    }
}

// MARK: - UICollection view delegate and datasource methods
extension InviteFriendsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return arrCollectionItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InviteFriendsCollectionCell",
                                                            for: indexPath) as? InviteFriendsCollectionCell else { return UICollectionViewCell() }

        if objCategory.rawValue == indexPath.row {
            cell.setContentToCell(categoryName: arrCollectionItems[indexPath.row],
                                  isHide: false)

        } else {
            cell.setContentToCell(categoryName: arrCollectionItems[indexPath.row],
                                  isHide: true)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {

        if objCategory.rawValue != indexPath.row {

            vwCollection.reloadData()
            selectCategory(index: indexPath.row)
            setUIAfterWebserviceCall()
            selectAlreadySelectedFriends()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 93, height: 30)
    }
}

extension InviteFriendsVC {

    // MARK: - Web service calls

    /// List All my friends Web service
    ///
    /// - Parameters:
    ///   - pageNo: page no
    ///   - completionHandler: completion hanlder
    func listFriendsWebService(pageNo: Int,
                               completionHandler: @escaping CompletionHandler) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        tblVwAddInvite.isUserInteractionEnabled = false
        listAllFriends(searchTextFriends,
                       page: pageNo,
                       withHandler: { (friendDetails, isFromCache)  in
                        self.tblVwAddInvite.isUserInteractionEnabled = true
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
                            self.selectAlreadySelectedFriends()
                            self.setUIAfterWebserviceCall() // It reloads table and set number of people text
                            completionHandler(true)
                        } else if friendInfo.status == AppConstants.tokenExpired {
                            appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
                        } else {
                            AppUtility.showAlert("", message: friendInfo.message, delegate: nil)
                        }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
            self.tblVwAddInvite.isUserInteractionEnabled = true
        }
    }

    /// List All my friends In respect To Event Web service
    ///
    /// - Parameters:
    ///   - pageNo: page number
    ///   - completionHandler: completion handler
    func listAllFriendsInRespectToEventWebService(pageNo: Int,
                                                  completionHandler: @escaping CompletionHandler) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        self.tblVwFriends.isUserInteractionEnabled = false

        guard let eventId = eventID else { return }
        listAllFriendsInRespectToEvent(searchTextFriends,
                                       eventID: eventId,
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

                                            self.arrFriends.append(contentsOf: friends)
                                            self.setUIAfterWebserviceCall()
                                            completionHandler(true)

                                        } else if friendInfo.status == AppConstants.tokenExpired {

                                            appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
                                        } else {
                                            AppUtility.showAlert("", message: friendInfo.message, delegate: nil)
                                        }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
            self.tblVwFriends.isUserInteractionEnabled = true
        }
    }

    /// List all users Web service
    ///
    /// - Parameters:
    ///   - pageNo: page num
    ///   - completionHandler: completion handler
    func listUsersWebService(pageNo: Int,
                             completionHandler: @escaping CompletionHandler) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        listAllUsers(searchTextUsers,
                     page: pageNo,
                     withHandler: { (friendDetails, isFromCache)  in

                        guard let friendInfo = friendDetails else {

                            self.tblVwAddInvite.hasMoreData = false
                            completionHandler(true)
                            return
                        }
                        if friendInfo.status == AppConstants.successServiceCode {

                            guard let response = friendInfo.response,
                                let friends = response.results else { return }

                            if friends.count < 8 || response.next == nil {
                                self.tblVwAddInvite.hasMoreData = false
                            }

//                            guard let response = friendInfo.response,
//                                let friends = response.results else { return }
//
//                            if friends.count < 8 || response.next == nil {
//                                self.tblVwFriends.hasMoreData = false
//                            }
                            if pageNo == 1 {
                                self.arrAddInvite = friends
                            } else {
                                self.arrAddInvite.append(contentsOf: friends)
                            }
                            
                            
                            
                            
                            self.selectAlreadySelectedFriends()
                            self.setUIAfterWebserviceCall() // It reloads table and set number of people text
                            completionHandler(true)

                        } else if friendInfo.status == AppConstants.tokenExpired {

                            appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
                        } else {
                            AppUtility.showAlert("", message: friendInfo.message, delegate: nil)
                        }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }

    /// List all users with respect to event Web service
    ///
    /// - Parameters:
    ///   - pageNo: page num
    ///   - completionHandler: completion handler
    func listAllUsersInRespectToEventWebService(pageNo: Int,
                                                completionHandler: @escaping CompletionHandler) {

        if !AppUtility.isNetworkAvailable() {
            AppUtility.showAlert("", message: "NetworkError".localized, delegate: self)
            return
        }

        guard let eventId = eventID else { return }
        listAllUsersInRespectToEvent(searchTextUsers, eventID: eventId,
                     page: pageNo,
                     withHandler: { (friendDetails, isFromCache)  in

                        guard let friendInfo = friendDetails else {

                            self.tblVwAddInvite.hasMoreData = false
                            completionHandler(true)
                            return
                        }
                        if friendInfo.status == AppConstants.successServiceCode {

                            guard let response = friendInfo.response,
                                let friends = response.results else { return }

                            if friends.count < 8 || response.next == nil {
                                self.tblVwAddInvite.hasMoreData = false
                            }

                            self.arrAddInvite.append(contentsOf: friends)
                            self.setUIAfterWebserviceCall() // It reloads table and set number of people text
                            completionHandler(true)

                        } else if friendInfo.status == AppConstants.tokenExpired {

                            appDelegate.navigationToLoginIfAppTokenNotAvailableOrLogOut()
                        } else {
                            AppUtility.showAlert("", message: friendInfo.message, delegate: nil)
                        }
        }) { (error) in
            AppUtility.showAlert("", message: "Error", delegate: nil)
        }
    }
}
