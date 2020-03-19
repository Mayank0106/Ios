//
//  ChatVCExtenison.swift
//  Reach
//
//  Created by Aanchal Jain on 12/03/19.
//  Copyright © 2019 Netsolutions. All rights reserved.
//

import Foundation
import Kingfisher

// MARK: - JSQMessages CollectionView DataSource & Delegate Methods
extension ChatViewController {

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {

        return messages.count
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView,
                                 messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {

        return messages[indexPath.item]
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView,
                                 messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {

        return messages[indexPath.item].senderId == self.senderId ? outgoingBubble : incomingBubble
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            as? JSQMessagesCollectionViewCell else {
                return JSQMessagesCollectionViewCell()
        }

        let message = messages[indexPath.item]

        if cell.messageBubbleImageView != nil {
            cell.messageBubbleImageView.contentMode = .scaleToFill
        }
        cell.avatarImageView.contentMode = .scaleAspectFill
        cell.avatarImageView.clipsToBounds = true
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView,
                                 attributedTextForCellTopLabelAt indexPath: IndexPath)
        -> NSAttributedString? {
            /**
             
             *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
             *  The other label text delegate methods should follow a similar pattern.
             *
             *  Show a timestamp for every 3rd message
             */
            if (indexPath.item % 3) == 0 {
                let message = self.messages[indexPath.item]
                print("Date Upper Label", JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date))
                return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
            }

            return nil
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView,
                                 attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath)
        -> NSAttributedString? {

            let message = messages[indexPath.item]

            // Displaying names above messages
            if message.senderId == self.senderId {
                return nil
            }

            return NSAttributedString(string: message.senderDisplayName)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView,
                                 layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
                                 heightForCellTopLabelAt indexPath: IndexPath)
        -> CGFloat {
            /**
             *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
             */

            /**
             *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
             *  The other label height delegate methods should follow similarly
             *
             *  Show a timestamp for every 3rd message
             */

            let message = self.messages[indexPath.item]
            var lastMessageDate = ""
            if indexPath.item > 0 {
                let lastMessage = self.messages[indexPath.item - 1]
                lastMessageDate = AppUtility.getDateString(from: lastMessage.date, format: "dd")
            }
            let currentDate = AppUtility.getDateString(from: message.date, format: "dd")

            if currentDate == lastMessageDate {
                return 0.0
            }
            return kJSQMessagesCollectionViewCellLabelHeightDefault

    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView,
                                 layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout,
                                 heightForMessageBubbleTopLabelAt indexPath: IndexPath)
        -> CGFloat {

            /**
             *  Example on showing or removing senderDisplayName based on user settings.
             *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
             */

            return kJSQMessagesCollectionViewCellLabelHeightDefault
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView,
                                 avatarImageDataForItemAt indexPath: IndexPath)
        -> JSQMessageAvatarImageDataSource? {

            let message = self.messages[indexPath.item]
            if message.senderId == self.senderId {
                return nil
            }
            let userImageView = UIImageView()
            if let profileImageStr = message.senderDisplayPicture,
                let profileImageUrl = URL(string: profileImageStr) {

                userImageView.kf.setImage(with: ImageResource(downloadURL: profileImageUrl),
                                          placeholder: UIImage(named: "avatarImage"),
                                          options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                          progressBlock: nil, completionHandler: nil)
            }
            let imgAvtar = JSQMessagesAvatarImageFactory.avatarImage(with: userImageView.image, diameter: 30)

            return imgAvtar
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 attributedTextForCellBottomLabelAt indexPath: IndexPath!)
        -> NSAttributedString! {

            let message = self.messages[indexPath.item]
            let msgTime = DateUtility.calculateTime12HourFormatFromDate(message.date)
            //        let msgTime = AppUtility.getDateString(from: message.date, format: "hh:mm a")
            return NSAttributedString(string: msgTime)
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!,
                                 heightForCellBottomLabelAt indexPath: IndexPath!)
        -> CGFloat {

            if !(self.messages.count - 1 == indexPath.item) {
                return 0.0
            }
            return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}
