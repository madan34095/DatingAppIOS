//
//  MatchesCollectionViewCell.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/11.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class MatchesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImgView.layer.cornerRadius = 40
        userImgView.clipsToBounds = true
    }

    internal func initData(matchInfo: Match) {
        if matchInfo.picture != "" {
            let url = NSURL(string: matchInfo.picture)
            userImgView.sd_setImage(with: url as URL?) { (img, err, type, url) in
            }
        }else {
            self.userImgView.image = UIImage(named: "profile_image_placeholder")
        }
        self.nameLb.text = matchInfo.name
    }
}
