//
//  IncomingUserMessageTableViewCell.swift
//  SendBird-iOS-LocalCache-Sample-swift
//
//  Created by Jed Kyung on 10/6/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage
import TTTAttributedLabel

class IncomingUserMessageTableViewCell: UITableViewCell, TTTAttributedLabelDelegate {
    weak var delegate: MessageDelegate?
    
    @IBOutlet weak var dateSeperatorView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: TTTAttributedLabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    
    @IBOutlet weak var dateSeperatorViewTopMargin: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dateSeperatorViewBottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var profileImageLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var profileImageWidth: NSLayoutConstraint!
    @IBOutlet weak var messageDateLabelWidth: NSLayoutConstraint!

    @IBOutlet weak var messageContainerLeftPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerRightPadding: NSLayoutConstraint!
    @IBOutlet weak var messageContainerTopPadding: NSLayoutConstraint!
    
    @IBOutlet weak var messageDateLabelLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var messageDateLabelRightMargin: NSLayoutConstraint!

    private var message: SBDUserMessage!
    private var prevMessage: SBDBaseMessage?
    private var displayNickname: Bool = true

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    @objc private func clickProfileImage() {
        if self.delegate != nil {
            self.delegate?.clickProfileImage(viewCell: self, user: self.message!.sender!)
        }
    }
    
    @objc private func clickUserMessage() {
        if self.delegate != nil {
//            self.delegate?.clickMessage(view: self, message: self.message!)
        }
    }
    
    func setModel(aMessage: SBDUserMessage) {
        self.message = aMessage
        
        self.profileImageView.af_setImage(withURL: URL(string: (self.message.sender?.profileUrl!)!)!, placeholderImage: UIImage(named: "img_profile"))
        
        let profileImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickProfileImage))
        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(profileImageTapRecognizer)

        // Message Date
        let messageDateAttribute = [
            NSAttributedString.Key.font: Constants.messageDateFont(),
            NSAttributedString.Key.foregroundColor: Constants.messageDateColor()
        ]
        
        let messageTimestamp = Double(self.message.createdAt) / 1000.0
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let messageCreatedDate = NSDate(timeIntervalSince1970: messageTimestamp)
        let messageDateString = dateFormatter.string(from: messageCreatedDate as Date)
        let messageDateAttributedString = NSMutableAttributedString(string: messageDateString, attributes: messageDateAttribute)
        self.messageDateLabel.attributedText = messageDateAttributedString
        
        // Seperator Date
        let seperatorDateFormatter = DateFormatter()
        seperatorDateFormatter.dateStyle = DateFormatter.Style.medium
        self.dateSeperatorLabel.text = seperatorDateFormatter.string(from: messageCreatedDate as Date)
        
        // Relationship between the current message and the previous message
        self.profileImageView.isHidden = false
        self.dateSeperatorView.isHidden = false
        self.dateSeperatorViewHeight.constant = 24.0
        self.dateSeperatorViewTopMargin.constant = 10.0
        self.dateSeperatorViewBottomMargin.constant = 10.0
        self.displayNickname = true
        if self.prevMessage != nil {
            // Day Changed
            let prevMessageDate = NSDate(timeIntervalSince1970: Double((self.prevMessage?.createdAt)!) / 1000.0)
            let currMessageDate = NSDate(timeIntervalSince1970: Double(self.message.createdAt) / 1000.0)
            let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: prevMessageDate as Date)
            let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currMessageDate as Date)
            
            if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
                // Show date seperator.
                self.dateSeperatorView.isHidden = false
                self.dateSeperatorViewHeight.constant = 24.0
                self.dateSeperatorViewTopMargin.constant = 10.0
                self.dateSeperatorViewBottomMargin.constant = 10.0
            }
            else {
                // Hide date seperator.
                self.dateSeperatorView.isHidden = true
                self.dateSeperatorViewHeight.constant = 0
                self.dateSeperatorViewBottomMargin.constant = 0
                
                // Continuous Message
                if self.prevMessage is SBDAdminMessage {
                    self.dateSeperatorViewTopMargin.constant = 10.0
                }
                else {
                    var prevMessageSender: SBDUser?
                    var currMessageSender: SBDUser?
                    
                    if self.prevMessage is SBDUserMessage {
                        prevMessageSender = (self.prevMessage as! SBDUserMessage).sender
                    }
                    else if self.prevMessage is SBDFileMessage {
                        prevMessageSender = (self.prevMessage as! SBDFileMessage).sender
                    }
                    
                    currMessageSender = self.message.sender
                    
                    if prevMessageSender != nil && currMessageSender != nil {
                        if prevMessageSender?.userId == currMessageSender?.userId {
                            // Reduce margin
                            self.dateSeperatorViewTopMargin.constant = 5.0
                            self.profileImageView.isHidden = true
                            self.displayNickname = false
                        }
                        else {
                            // Set default margin.
                            self.profileImageView.isHidden = false
                            self.dateSeperatorViewTopMargin.constant = 10.0
                        }
                    }
                    else {
                        self.dateSeperatorViewTopMargin.constant = 10.0
                    }
                }
            }
        }
        else {
            // Show date seperator.
            self.dateSeperatorView.isHidden = false
            self.dateSeperatorViewHeight.constant = 24.0
            self.dateSeperatorViewTopMargin.constant = 10.0
            self.dateSeperatorViewBottomMargin.constant = 10.0
        }
        
        let fullMessage = self.buildMessage()
        self.messageLabel.attributedText = fullMessage
        self.messageLabel.isUserInteractionEnabled = true
        self.messageLabel.linkAttributes = [
            NSAttributedString.Key.font: Constants.messageFont(),
            NSAttributedString.Key.foregroundColor: Constants.incomingMessageColor(),
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let detector: NSDataDetector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: self.message.message!, options: [], range: NSMakeRange(0, (self.message.message?.count)!))
        if matches.count > 0 {
            self.messageLabel.delegate = self
            self.messageLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
            for item in matches {
                let match = item
                let rangeOfOriginalMessage = match.range
                var range: NSRange
                if self.displayNickname {
                    range = NSMakeRange((self.message.sender?.nickname?.count)! + 1 + rangeOfOriginalMessage.location, rangeOfOriginalMessage.length)
                }
                else {
                    range = rangeOfOriginalMessage
                }
                
                self.messageLabel.addLink(to: match.url, with: range)
            }
        }
        
        self.layoutIfNeeded()
    }
    
    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    
    func buildMessage() -> NSAttributedString {
        var nicknameAttribute: [NSAttributedString.Key:AnyObject]?
        switch (self.message.sender?.nickname?.utf8.count)! % 5 {
        case 0:
            nicknameAttribute = [
                NSAttributedString.Key.font: Constants.nicknameFontInMessage(),
                NSAttributedString.Key.foregroundColor: Constants.nicknameColorInMessageNo0()
            ]
            break
        case 1:
            nicknameAttribute = [
                NSAttributedString.Key.font: Constants.nicknameFontInMessage(),
                NSAttributedString.Key.foregroundColor: Constants.nicknameColorInMessageNo1()
            ]
            break
        case 2:
            nicknameAttribute = [
                NSAttributedString.Key.font: Constants.nicknameFontInMessage(),
                NSAttributedString.Key.foregroundColor: Constants.nicknameColorInMessageNo2()
            ]
            break
        case 3:
            nicknameAttribute = [
                NSAttributedString.Key.font: Constants.nicknameFontInMessage(),
                NSAttributedString.Key.foregroundColor: Constants.nicknameColorInMessageNo3()
            ]
            break
        case 4:
            nicknameAttribute = [
                NSAttributedString.Key.font: Constants.nicknameFontInMessage(),
                NSAttributedString.Key.foregroundColor: Constants.nicknameColorInMessageNo4()
            ]
            break
        default:
            nicknameAttribute = [
                NSAttributedString.Key.font: Constants.nicknameFontInMessage(),
                NSAttributedString.Key.foregroundColor: Constants.nicknameColorInMessageNo0()
            ]
            break
        }
        
        let messageAttribute = [
            NSAttributedString.Key.font: Constants.messageFont()
        ]
        
        let nickname = self.message.sender?.nickname
        let message = self.message.message
        
        var fullMessage: NSMutableAttributedString? = nil
        if self.displayNickname, let theNickName: String = nickname {
            fullMessage = NSMutableAttributedString.init(string: "\(theNickName)\n\(message ?? "")")
            
            fullMessage?.addAttributes(nicknameAttribute!, range: NSMakeRange(0, (nickname?.utf16.count)!))
            fullMessage?.addAttributes(messageAttribute, range: NSMakeRange((nickname?.utf16.count)! + 1, (message?.utf16.count)!))
        }
        else {
            fullMessage = NSMutableAttributedString.init(string: "\(message ?? "")")
            fullMessage?.addAttributes(messageAttribute, range: NSMakeRange(0, (message?.utf16.count)!))
        }
        
        return fullMessage!
    }
    
    func getHeightOfViewCell() -> CGFloat {
        let fullMessage = self.buildMessage()
        
        var fullMessageSize: CGSize

        var messageLabelMaxWidth: CGFloat = UIScreen.main.bounds.size.width
        messageLabelMaxWidth -= self.profileImageLeftMargin.constant
        messageLabelMaxWidth -= self.profileImageWidth.constant
        messageLabelMaxWidth -= self.messageContainerLeftMargin.constant
        messageLabelMaxWidth -= self.messageContainerLeftPadding.constant
        messageLabelMaxWidth -= self.messageContainerRightPadding.constant
        messageLabelMaxWidth -= self.messageDateLabelLeftMargin.constant
        messageLabelMaxWidth -= self.messageDateLabelWidth.constant
        messageLabelMaxWidth -= self.messageDateLabelRightMargin.constant
        let framesetter = CTFramesetterCreateWithAttributedString(fullMessage)
        fullMessageSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0,length: 0), nil, CGSize(width: messageLabelMaxWidth, height: CGFloat(LONG_LONG_MAX)), nil)

        let cellHeight = self.dateSeperatorViewTopMargin.constant + self.dateSeperatorViewHeight.constant + self.dateSeperatorViewBottomMargin.constant + self.messageContainerTopPadding.constant + fullMessageSize.height + self.messageContainerBottomPadding.constant
        
        return cellHeight
    }
    
    // MARK: TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let options: Dictionary<UIApplication.OpenExternalURLOptionsKey, Any> = Dictionary<UIApplication.OpenExternalURLOptionsKey, Any>()
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: options, completionHandler: nil)
        }
    }
}
