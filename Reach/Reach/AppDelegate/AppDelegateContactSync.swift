//
//  AppDelegateContactSync.swift
//  Reach
//
//  Created by Aanchal Jain on 27/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import UIKit
import Contacts

extension AppDelegate: FriendAPI {

    // Get Contacts
    func checkContactsAvailability() {
        let store = CNContactStore()
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            store.requestAccess(for: .contacts, completionHandler: { (_, _) -> Void in
                // do nothing
            })
        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            // do nothing
        } else if CNContactStore.authorizationStatus(for: .contacts) == .denied {
            //AppUtility.openSettingScreen(object: self)
        }
    }

    // Generates array based on page no.
    func generatePageArray(arrAllContacts: [String]) {
        currentPage = 1
        let chunks = stride(from: 0, to: arrAllContacts.count, by: chunkSize).map {
            Array(arrAllContacts[$0..<min($0 + chunkSize, arrAllContacts.count)])
        }
        arrayForUpload = chunks
        maxPageLimit = arrAllContacts.count/chunkSize
        if arrAllContacts.count | chunkSize > 0 {
            maxPageLimit += 1
        }
        pagination()
    }
    // MARK: Service call based on page num
    func pagination() {
        self.callWebServiceForSync(arrPositionChangeStore: arrayForUpload[currentPage-1])
    }

    func callWebServiceForSync(arrPositionChangeStore: [String]) {

        syncContacts(body: arrPositionChangeStore, withHandler: { (responseData, _) in
            guard let statusObj =  responseData?.status, statusObj == AppConstants.successServiceCode else {
                AppUtility.showAlert("", message: "Sync Contact Failure", delegate: nil)
                return
            }
            self.currentPage += 1
            if self.currentPage < self.maxPageLimit {
                self.pagination()
            }
        }) { (error) in
            print(error)
        }
    }
}
