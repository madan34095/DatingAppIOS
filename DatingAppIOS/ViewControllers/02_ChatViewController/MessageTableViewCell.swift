//
//  MessageTableViewCell.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/11.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

@objc protocol MessageTableViewCellDelegate {
    func selectedUserImgView(mInfo: Channel)
    func selectedMessageItem(mInfo: Channel)
}

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var messageLb: UILabel!
    @IBOutlet weak var timeLb: UILabel!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var badgeLb: UILabel!
    
    internal var delegate: MessageTableViewCellDelegate? = nil
       
    private var channel: Channel? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImgView.layer.cornerRadius = 30
        userImgView.clipsToBounds = true
        badgeView.layer.cornerRadius = 10
        badgeView.clipsToBounds = true
        
        badgeLb.isHidden = true
        badgeView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal func initData(messageInfo: Channel) {
        self.channel = messageInfo
        if messageInfo.picture != "" {
            let url = NSURL(string: messageInfo.picture)
            userImgView.sd_setImage(with: url as URL?) { (img, err, type, url) in
            }
        }else {
            self.userImgView.image = UIImage(named: "profile_image_placeholder")
        }
        self.nameLb.text = messageInfo.name
        self.messageLb.text = messageInfo.message
        self.timeLb.text = Common.calExpairedTime(time: Common.getTimeFromString(dateStr: messageInfo.timestamp) * 1000)
        if self.channel!.badge > 0 {
            badgeLb.isHidden = false
            badgeView.isHidden = false
            badgeLb.text = "\(self.channel?.badge ?? 0)"
        }
    }

    @IBAction func userImgBtnClicked(_ sender: Any) {
        delegate?.selectedUserImgView(mInfo: self.channel!)
    }
    
    @IBAction func itemBtnClicked(_ sender: Any) {
        delegate?.selectedMessageItem(mInfo: self.channel!)
    }
    
    
}
