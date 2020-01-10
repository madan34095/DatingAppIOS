//
//  UserDetailViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/09.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import JXPageControl
import SVProgressHUD

@objc protocol UserDetailViewControllerDelegate {
    func unlikeAction(userInfo: User)
    func likeAction(userInfo: User)
    func matchUnLikeAction(userInfo: User)
    func matchAction(userInfo: User)
    func closeView()
}

class UserDetailViewController: UIViewController
, UIScrollViewDelegate
, UITableViewDelegate
, UITableViewDataSource
{

    internal var userInfo: User? = nil
    internal var swipe: Bool = false
    internal var delegate: UserDetailViewControllerDelegate? = nil

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var imgScrollViewCell: UITableViewCell!
    @IBOutlet var detailViewCell: UITableViewCell!
    @IBOutlet weak var imgContentView: UIView!
    @IBOutlet weak var jobView: UIView!
    
    
    
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var pageControlView: JXPageControlScale!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var jobLb: UILabel!
    @IBOutlet weak var distanceLb: UILabel!
    @IBOutlet weak var jobViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var aboutLb: UILabel!
    
    var arrImg: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if userInfo?.imageUrl1 != "" {
            arrImg.append(userInfo!.imageUrl1)
        }
        if userInfo?.imageUrl2 != "" {
            arrImg.append(userInfo!.imageUrl2)
        }
        if userInfo?.imageUrl3 != "" {
            arrImg.append(userInfo!.imageUrl3)
        }
        if userInfo?.imageUrl4 != "" {
            arrImg.append(userInfo!.imageUrl4)
        }
        if userInfo?.imageUrl5 != "" {
            arrImg.append(userInfo!.imageUrl5)
        }
        if userInfo?.imageUrl6 != "" {
            arrImg.append(userInfo!.imageUrl6)
        }
        
        if arrImg.count == 0 {
            arrImg.append("")
        }

        let imgScrollView = UIScrollView()
        imgScrollView.frame = CGRect(x: 0, y: 0, width: Config.SCREEN_WIDTH, height: Config.SCREEN_HEIGHT - 300)
        imgScrollView.delegate = self
        imgScrollView.isPagingEnabled = true
        imgScrollView.contentSize = CGSize(width: Config.SCREEN_WIDTH * CGFloat(arrImg.count), height: Config.SCREEN_HEIGHT - 300)
        imgScrollView.showsHorizontalScrollIndicator = false
        imgScrollView.backgroundColor = .darkGray
        
        for i in 0 ..< Int(imgScrollView.contentSize.width/Config.SCREEN_WIDTH) {
            
            let ivImage = UIImageView(frame: CGRect(x: Config.SCREEN_WIDTH*CGFloat(i), y: 0, width: Config.SCREEN_WIDTH, height: Config.SCREEN_HEIGHT-300))
            if arrImg[i] != "" {
                let url = NSURL(string: arrImg[i])
                ivImage.sd_setImage(with: url as URL?) { (img, err, type, url) in
                }
            }else {
                ivImage.image = UIImage(named: "profile_image_placeholder")
            }
            ivImage.contentMode = .scaleAspectFill
            ivImage.clipsToBounds = true
            imgScrollView.addSubview(ivImage)
        }
        imgContentView.addSubview(imgScrollView)

        pageControlView.frame = CGRect(x: 0, y: 10, width: Config.SCREEN_WIDTH, height: 20)
        pageControlView.numberOfPages = arrImg.count
        
        self.nameLb.text = userInfo!.name + ", \(userInfo!.age ?? 0)"
//        let attributedText = NSMutableAttributedString(string: userInfo!.about, attributes: [.foregroundColor: UIColor.clear,.font:self.aboutLb.font])
        self.aboutLb.text = userInfo?.about
        
        if userInfo?.jobTitle == "" || userInfo?.jobTitle == "null" {
            self.jobViewHeight.constant = 0
            self.jobView.isHidden = true
        }else {
            self.jobLb.text = userInfo?.jobTitle
        }
        
        var dist = Common.calDistanceFromLocation(lat1: Common.me!.latitude, long1: Common.me!.longitude, lat2: userInfo!.latitude, long2: userInfo!.longitude)
        if dist <= 10 {
            dist = 10
        }

        self.distanceLb.text = "\(dist ?? 0)km"

    }
   
    //-------------------------------------------------------------------------------------------------------------------------
        //                                              Number of sections
        //-------------------------------------------------------------------------------------------------------------------------
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
       
     //-------------------------------------------------------------------------------------------------------------------------
        //                                              Number of rows in section
        //-------------------------------------------------------------------------------------------------------------------------
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 2
        }
        //-------------------------------------------------------------------------------------------------------------------------
        //                                              Cell for row at index path
        //-------------------------------------------------------------------------------------------------------------------------
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = imgScrollViewCell
            switch indexPath.row {
            case 1:
                return detailViewCell
            default:
                return cell!
            }
        }
     //-------------------------------------------------------------------------------------------------------------------------
        //                                              Height for row at indexPath
        //-------------------------------------------------------------------------------------------------------------------------
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if indexPath.row == 0 {
                return Config.SCREEN_HEIGHT - 300
            }else {
                return 300
            }
        }

    //MARK: ## ScrollView Delegate ##
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Added as required
        let progress = scrollView.contentOffset.x / scrollView.bounds.width
        pageControlView.progress = progress
    }

    private func reportThisUser() {
        FirebaseApiManager.reportUser(u_id: userInfo!.fbId, u_name: userInfo!.name) { (result) in
            if result {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func unLikeBtnClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.unlikeAction(userInfo: self.userInfo!)
        }
    }
    
    @IBAction func likeBtnClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            if self.swipe {
                self.delegate?.matchAction(userInfo: self.userInfo!)
            }else {
                self.delegate?.likeAction(userInfo: self.userInfo!)
            }
        }
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reportBtnClicked(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: Config.report,
                                                         message: Config.report_msg as String,
                                                         preferredStyle: .alert);
        let okAction: UIAlertAction = UIAlertAction(title: Config.YES,
                                                        style: .default,
                                                        handler: {
                                                            (action: UIAlertAction!) -> Void in
                                                            self.reportThisUser()
        })
        let noAction: UIAlertAction = UIAlertAction(title: Config.NO,
                                                        style: .default,
                                                        handler: {
                                                            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(okAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
