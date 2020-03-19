//
//  ChatViewController.swift
//  ModelPay
//
//  Created by ritufonsa on 15/02/19.
//  Copyright © 2019 rajesh kumar. All rights reserved.
//
import UIKit
import FirebaseMessaging
import CoreLocation
import AVKit
import AVFoundation
import Kingfisher
import Firebase
import FirebaseDatabase
import FirebaseAuth
import Kingfisher

class ChatViewController: JSQMessagesViewController {

    // MARK: - Variables And Constants
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!

    var items = [ChatMessage]()
    var chatParticipants = [ChatUser]()
    var userID: Int = 0
    var fcmTokensList: [String] = []
    var senderNotificationId: Int = 0
    var messages = [JSQMessage]()
    var event: MyEventModel?
    var conversationId: String?
    var arrOpponentIds = [Int]()

    // MARK: - View Controller life Cycle
    override func viewDidLoad() {

        super.viewDidLoad()
        chatControllerSettings()

        self.senderId = "\(userID)"
        self.senderDisplayName = ""
        setUISettings()

        automaticallyScrollsToMostRecentMessage = true
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
        self.fetchDataWithRespectToConversationID()
       
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                _ = self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
    }

    /// Chat Controller Settings
    func chatControllerSettings() {

        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "icSendMessage"), for: .normal)
        self.inputToolbar.contentView.textView.placeHolder = "Type something..."
        self.inputToolbar.contentView.textView.placeHolderTextColor = #colorLiteral(red: 0.5568627451, green: 0.5568627451, blue: 0.5764705882, alpha: 1)
        self.inputToolbar.contentView.backgroundColor = UIColor.white

        // Bubbles with tails
        incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with:
            AppConstants.chatSenderBubblecolor)
        outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with:
            AppConstants.chatReceipientBubbleColor)

        /**
         *  Example on showing or removing Avatars based on user settings.
         */
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(
            width: kJSQMessagesCollectionViewAvatarSizeDefault,
            height: kJSQMessagesCollectionViewAvatarSizeDefault )
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(
            width: kJSQMessagesCollectionViewAvatarSizeDefault,
            height: kJSQMessagesCollectionViewAvatarSizeDefault )

        // This is a beta feature that mostly works but to make things more stable it is diabled.
        collectionView?.collectionViewLayout.springinessEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.setNavBarHide(hide: true)
        super.viewWillAppear(true)
    }

    override func btnTappedback(_ sender: UIButton!) {

        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// Set UI Settings
    func setUISettings() {

        guard let eventDetails = event else { return }

        if let name = eventDetails.name, let startTime = eventDetails.startTime, let bannerImageStr = eventDetails.bannerImage, let bannerImageUrl = URL(string: bannerImageStr) {
            self.lblPartyName.text = name.uppercased()
            self.lblPartyDate.text = DateUtility.calculateDateWeekDayFormatWithYear(startTime)
            self.imgVwParty.kf.setImage(with: ImageResource(downloadURL: bannerImageUrl),
                                                             placeholder: UIImage(named: "img-party"),
                                                             options: [KingfisherOptionsInfoItem.cacheMemoryOnly],
                                                             progressBlock: nil,
                                                             completionHandler: nil)
        }
    }

    /// Fetch Data With Respect To Conversation ID
    func fetchDataWithRespectToConversationID() {

        guard let eventDetails = event, let eventId = eventDetails.id else { return }

        Database.database().reference().child("Events").child("\(eventId)")
            .observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                if let snapDict = snapshot.value as? [String: AnyObject] {
                    self.conversationId = snapDict[AppConstants.ConversationId] as? String
                    self.fetchData(conversationId: self.conversationId ?? "")
                }
            }
        })
    }
}

// MARK: - JSQMessagesInputToolbar Delegate Methods
extension JSQMessagesInputToolbar {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        if #available(iOS 11.0, *) {
            if self.window?.safeAreaLayoutGuide != nil {
                self.bottomAnchor
                    .constraintLessThanOrEqualToSystemSpacingBelow((self.window?.safeAreaLayoutGuide.bottomAnchor)!,
                                                                                multiplier: 1.0).isActive = true
            }
        }
    }
}

// MARK: - Send & Fetch Sent Messages
extension ChatViewController {

    /// Did Press Send Button
    ///
    /// - Parameters:
    ///   - button: Sender
    ///   - text: Text To Send
    ///   - senderId: Sender ID
    ///   - senderDisplayName: Sender Display Name
    ///   - date: Date
    override func didPressSend(_ button: UIButton,
                               withMessageText text: String,
                               senderId: String,
                               senderDisplayName: String,
                               date: Date) {
            /**
             *  Sending a message. Your implementation of this method should do *at least* the following:
             *
             *  1. Play sound (optional)
             *  2. Add new id<JSQMessageData> object to your data source
             *  3. Call `finishSendingMessage`
             */

        sendFirebaseChatMessage(type: .text, content: "\(text)")

        self.finishSendingMessage(animated: true)
    }

    /// Send Message
    ///
    /// - Parameters:
    ///   - type: Message Type
    ///   - content: Content
    func sendFirebaseChatMessage(type: MessageType, content: String) {

        let msg = ChatMessage(type: type,
                              content: content,
                              owner: .sender,
                              timestamp: Int(Date().timeIntervalSince1970),
                              isRead: false,
                              messageKey: "",
                              msgLocation: "",
                              fromID: "",
                              toID: "")

        // Remove sender himself
        for (index, opponent) in arrOpponentIds.enumerated() {
            if String(opponent) == self.senderId {
                self.arrOpponentIds.remove(at: index)
            }
        }
        for friendID in arrOpponentIds {
            Database.database().reference().child("token").child("\(friendID)")
                .observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    if let snapDict = snapshot.value as? [String: AnyObject] {
                        let token = snapDict["fcm_token"] as? String
                        guard let eventDetails = self.event else { return }

                        if let eventId = eventDetails.id {
                            //Send Notification
                            ChatMessage.sendChatNotification(body: content,
                                                             recepientId: token ?? "",
                                                             groupName: self.lblPartyName.text!,
                                                             eventID: eventId)
                        }
                    }
                }
            })
        }

        //Send Message
        guard let eventId = event?.id else { return }
        ChatMessage.send(message: msg,
                         eventId: "\(eventId)",
                         userID: "\(userID)",
                         convId: conversationId) {

            (success, convId) in
                print("msg sent: \(success)")
                if self.conversationId == nil {
                    self.conversationId = convId

            }
        }
    }

    /// Fetch Data corresponds to this ID
    ///
    /// - Parameter conversationId: conversation ID
    func fetchData(conversationId: String) {

        ChatMessage.downloadAllMessages(convId: conversationId,
                                        recieverId: "\(userID)",
                                        completion: {[weak weakSelf = self] (message) in

                if let msg = message.content as? String {
                    print("Message Content : \(msg)")

                    let messageJSQ = JSQMessage(senderId: message.fromID,
                                                senderDisplayName: message.userName!,
                                                senderDisplayPicture: message.userImage!,
                                                date: Date(timeIntervalSince1970: TimeInterval(Double(message.timestamp))),
                                                text: msg)
                    weakSelf?.messages.append(messageJSQ!)
                    self.collectionView.reloadData()
                }
                weakSelf?.items.append(message)
                AppConstants.lastChatItem = message
                DispatchQueue.main.async {
                    if let state = weakSelf?.messages.isEmpty, state == false {
                        self.finishReceivingMessage(animated: false)
                    }
                }
            })
    }
}
