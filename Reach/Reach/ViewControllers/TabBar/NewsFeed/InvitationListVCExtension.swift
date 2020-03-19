//
//  InvitationListVCExtension.swift
//  Reach
//
//  Created by Aanchal Jain on 12/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Foundation

// MARK: - UITableView Delegate and Datasource Methods

extension InvitationListVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return self.arrFriends.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        guard let arRequestedInvitations = self.arrFriends[section].arrRequestedInvitations
            else { return 0}
        return arRequestedInvitations.count
    }

    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationListTableViewCell")
            as? InvitationListTableViewCell else { return UITableViewCell() }

        guard let arRequestedInvitations = self.arrFriends[indexPath.section].arrRequestedInvitations
            else { return UITableViewCell() }

        cell.delegate = self
        cell.isMyEvent = isMyEvent
        cell.setContentToCell(friend: arRequestedInvitations[indexPath.row],
                              upperFriendDetails: self.arrFriends[indexPath.section])
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt
        indexPath: IndexPath) -> CGFloat {

        if self.arrFriends[indexPath.section].isSelected {

            guard let requestedInvitations = self.arrFriends[indexPath.section].arrRequestedInvitations
                else { return 0 }

            if let isInvited = requestedInvitations[indexPath.row].isInvited {
                if isInvited {
                    return htForRowBringingFriends
                } else {
                    return htForRowRequestedFriends
                }
            }
        }
        return 0
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InvitationListSectionHeader")
            as? InvitationListSectionHeader else { return UITableViewCell() }

        cell.setContentToCell(friend: arrFriends[section])
        cell.delegate = self
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {

        return htForSection
    }
}

// MARK: - UITextFieldDelegate Methods
extension InvitationListVC: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        self.view.endEditing(true)
        if textField.text! != searchText {

            searchText = textField.text!
            self.pageNum = 1
            self.arrFriends = []
            self.tblVwFriends.hasMoreData = true
            self.tblVwFriends.setContentOffset(.zero,
                                               animated: true)
            listAllInvitationsWebService(pageNo: pageNum,
                                         completionHandler: { (_) -> Void in
            })
        }

        return true
    }
}

// MARK: - CollapseExpandSectionHeader Delegate Methods
extension InvitationListVC: CollapseExpandSectionHeader {

    /// Collapse Expand Section Header
    ///
    /// - Parameters:
    ///   - friendID: friend id
    ///   - isSelected: is selected
    func collapseExpandSectionHeader(friendID: Int,
                                     isSelected: Bool) {

        let index = self.arrFriends.index(where: { (friend) -> Bool in
            friend.id == friendID // test if this is the item you're looking for
        })
        if let indexExists = index {

            self.arrFriends[indexExists].isSelected = isSelected
            self.tblVwFriends.reloadData()
        }
    }
}
