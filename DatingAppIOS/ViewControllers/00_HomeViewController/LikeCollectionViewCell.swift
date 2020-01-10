//
//  LikeCollectionViewCell.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/05.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class LikeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userInfoLb: UILabel!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImgView.layer.cornerRadius = 10
        userImgView.clipsToBounds = true
        blurView.layer.cornerRadius = 10
        blurView.clipsToBounds = true
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        blurView.effect = blurEffect
    }
    
    internal func initData(userInfo: User, purchased: Bool) {
        if userInfo.imageUrl1 != "" {
            let url = NSURL(string: userInfo.imageUrl1)
            userImgView.sd_setImage(with: url as URL?) { (img, err, type, url) in
            }
        }else {
            self.userImgView.image = UIImage(named: "profile_image_placeholder")
        }
        self.userInfoLb.text = userInfo.name + ", \(userInfo.age ?? 0)"
        blurView.isHidden = purchased
    }


}
