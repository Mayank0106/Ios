//
//  AddFriendVCExtension.swift
//  Reach
//
//  Created by Aanchal Jain on 12/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Foundation

// MARK: - UITableView Delegate and Datasource Methods
extension AddFriendVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 2
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return self.arrRequestSentRecieved.count
        default:
            return self.arrAddFriends.count
        }

    }

    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell")
            as? FriendTableViewCell else { return UITableViewCell() }

        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.delegate = self
        switch indexPath.section {
        case 0:

            cell.setContentToCell(friend: arrRequestSentRecieved[indexPath.row])

        default:

            cell.setContentToCell(friend: arrAddFriends[indexPath.row])
        }
        return cell
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {

        return htForRow
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {

        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddFriendSectionHeaderCell")
            as? AddFriendSectionHeaderCell else { return nil }

        switch section {
        case 0:
            headerView.lblHeader.text = "Friend Requests"
        default:
            headerView.lblHeader.text = "Suggested Friends"
        }

        return headerView

    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {

        return headerHt
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        var friendID: Int?

        switch indexPath.section {
        case 0:

            friendID = arrRequestSentRecieved[indexPath.row].id

        default:

            friendID = arrAddFriends[indexPath.row].id

        }
        profileAction(userID: friendID)
    }
}

// MARK: - UITextFieldDelegate methods
extension AddFriendVC: UITextFieldDelegate {

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        self.view.endEditing(true)
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let strText = textField.text! as NSString

        searchText = strText.replacingCharacters(in: range, with: string)

        self.pageNum = 1
        self.arrAllUsers = []
        self.tblVwFriends.hasMoreData = true
        self.tblVwFriends.setContentOffset(.zero,
                                           animated: true)
        listUsersWebService(searchText: searchText,
                            pageNo: self.pageNum,
                            completionHandler: { (_) -> Void in
        })

        return true
    }
}
