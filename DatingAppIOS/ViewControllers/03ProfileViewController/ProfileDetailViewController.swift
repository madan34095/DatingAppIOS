//
//  ProfileDetailViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/12.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import JXPageControl
import SVProgressHUD

class ProfileDetailViewController: UIViewController
, UIScrollViewDelegate {
    
    internal var userId: String? = nil

    @IBOutlet weak var scMain: UIScrollView!
    @IBOutlet weak var pageControlView: JXPageControlScale!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var aboutLb: UILabel!
    @IBOutlet weak var jobTitleTxt: UILabel!
    @IBOutlet weak var distanceLb: UILabel!
    @IBOutlet weak var distanceIcon: UIImageView!
    
    @IBOutlet weak var jobIcon: UIImageView!
    var arrImg: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userId == Common.me?.fbId {
            distanceLb.isHidden = true
            distanceIcon.isHidden = true
            initUserInfo(userInfo: Common.me!)
        }else {
            getUserInfo()
        }

        }
    
    private func initUserInfo(userInfo: User) {
        if userInfo.imageUrl1 != "" {
            arrImg.append(userInfo.imageUrl1)
            }
        if userInfo.imageUrl2 != "" {
            arrImg.append(userInfo.imageUrl2)
            }
        if userInfo.imageUrl3 != "" {
            arrImg.append(userInfo.imageUrl3)
            }
        if userInfo.imageUrl4 != "" {
            arrImg.append(userInfo.imageUrl4)
            }
        if userInfo.imageUrl5 != "" {
            arrImg.append(userInfo.imageUrl5)
            }
        if userInfo.imageUrl6 != "" {
            arrImg.append(userInfo.imageUrl6)
            }
            
            if arrImg.count == 0 {
                arrImg.append("")
            }

            scMain.frame = CGRect(x: 0, y: 0, width: Config.SCREEN_WIDTH, height: Config.SCREEN_HEIGHT - 80)
            scMain.delegate = self
            scMain.isPagingEnabled = true
            scMain.contentSize = CGSize(width: Config.SCREEN_WIDTH * CGFloat(arrImg.count), height: Config.SCREEN_HEIGHT - 200)
            //sc_main.contentOffset = CGPoint(x: sc_main.frame.size.width, y: 0) //<- Only Start Page Not first Page
            
            for i in 0 ..< Int(scMain.contentSize.width/Config.SCREEN_WIDTH) {
                
                let ivImage = UIImageView(frame: CGRect(x: Config.SCREEN_WIDTH*CGFloat(i), y: 0, width: Config.SCREEN_WIDTH, height: Config.SCREEN_HEIGHT-200))
                if arrImg[i] != "" {
                    let url = NSURL(string: arrImg[i])
                    ivImage.sd_setImage(with: url as URL?) { (img, err, type, url) in
                    }
                }else {
//                    ivImage.image = UIImage(named: "profile_image_placeholder")
                }
                ivImage.contentMode = .scaleAspectFill
                ivImage.clipsToBounds = true
                scMain.addSubview(ivImage)
            }

            pageControlView.frame = CGRect(x: 0, y: 10, width: Config.SCREEN_WIDTH, height: 20)
            pageControlView.numberOfPages = arrImg.count

        self.nameLb.text = userInfo.name + ", \(userInfo.age ?? 0)"
        self.aboutLb.text = userInfo.about
        
        if userInfo.jobTitle == "" || userInfo.jobTitle == "null" {
            self.jobTitleTxt.isHidden = true
            self.jobIcon.isHidden = true
        }else {
            self.jobTitleTxt.text = userInfo.jobTitle
        }
        
        var dist = Common.calDistanceFromLocation(lat1: Common.me!.latitude, long1: Common.me!.longitude, lat2: userInfo.latitude, long2: userInfo.longitude)
        if dist <= 10 {
            dist = 10
        }

        self.distanceLb.text = "\(dist ?? 0)km"
    }
    
    private func getUserInfo() {
        FirebaseApiManager.getUserInfo(u_id: userId!) { (result) in
            if result != nil {
                self.initUserInfo(userInfo: result!)
            }
        }
    }
        //MARK: ## ScrollView Delegate ##
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let progress = scrollView.contentOffset.x / scrollView.bounds.width
            pageControlView.progress = progress
        }

    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
