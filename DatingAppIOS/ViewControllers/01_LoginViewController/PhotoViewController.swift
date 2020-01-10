//
//  PhotoViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/11/29.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PhotoViewController: UIViewController
, UIImagePickerControllerDelegate
, UINavigationControllerDelegate {

    @IBOutlet weak var mainImg: UIImageView!
    
    @IBOutlet weak var subImg1: UIImageView!
    @IBOutlet weak var subImg2: UIImageView!
    @IBOutlet weak var subImg3: UIImageView!
    @IBOutlet weak var subImg4: UIImageView!
    @IBOutlet weak var subImg5: UIImageView!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var popView: UIView!
    
    private var selectedImgView: UIImageView = UIImageView()
    private var selectedImgName = ""
    private var imgPath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

        alertView.isHidden = true
        
        mainImg.layer.cornerRadius = 6
        mainImg.clipsToBounds = true
        subImg1.layer.cornerRadius = 6
        subImg1.clipsToBounds = true
        subImg2.layer.cornerRadius = 6
        subImg2.clipsToBounds = true
        subImg3.layer.cornerRadius = 6
        subImg3.clipsToBounds = true
        subImg4.layer.cornerRadius = 6
        subImg4.clipsToBounds = true
        subImg5.layer.cornerRadius = 6
        subImg5.clipsToBounds = true
        
        popView.layer.cornerRadius = 6
    }


    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        let vc = LocationViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func mainImgClicked(_ sender: Any) {
        selectedImgView = mainImg
        imgPath = Common.me?.imageUrl1 != nil ? Common.me!.imageUrl1 : "null"
        selectedImgName = "image1"
        alertView.isHidden = false
    }
    @IBAction func subImgClicked1(_ sender: Any) {
        selectedImgView = subImg1
        imgPath = Common.me?.imageUrl2 != nil ? Common.me!.imageUrl2 : "null"
        selectedImgName = "image2"
        alertView.isHidden = false
    }
    @IBAction func subImgClicked2(_ sender: Any) {
        selectedImgView = subImg2
        imgPath = Common.me?.imageUrl3 != nil ? Common.me!.imageUrl3 : "null"
        selectedImgName = "image3"
        alertView.isHidden = false
    }
    @IBAction func subImgClicked3(_ sender: Any) {
        selectedImgView = subImg3
        imgPath = Common.me?.imageUrl4 != nil ? Common.me!.imageUrl4 : "null"
        selectedImgName = "image4"
        alertView.isHidden = false
    }
    @IBAction func subImgClicked4(_ sender: Any) {
        selectedImgView = subImg4
        imgPath = Common.me?.imageUrl5 != nil ? Common.me!.imageUrl5 : "null"
        selectedImgName = "image5"
        alertView.isHidden = false
    }
    @IBAction func subImgClicked5(_ sender: Any) {
        selectedImgView = subImg5
        imgPath = Common.me?.imageUrl6 != nil ? Common.me!.imageUrl6 : "null"
        selectedImgName = "image6"
        alertView.isHidden = false
    }

    @IBAction func closeBtnClicked(_ sender: Any) {
        alertView.isHidden = true
    }
    
    @IBAction func cameraBtnClicked(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        NSLog("Camera" )

        self.present(vc, animated: true)
    }
    
    @IBAction func galleryBtnClicked(_ sender: Any) { 
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        print("gal" )
        self.present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        print("img1:" )

        alertView.isHidden = true
        selectedImgView.image = image
        let imgData = image.jpegData(compressionQuality: 0.3)
        SVProgressHUD.show()
               print("img2:" )
        let refKey = Common.firebaseDb.child("Users").childByAutoId().key
        print("img3:" )
        let storageRef = Common.firebaseStorage.reference()
        print("img4:" )
        let imagesRef = storageRef.child(Common.me!.fbId + "/" + refKey! + ".jpg")
        
        print("img:" + Common.me!.fbId + "/" + refKey! + ".jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        imagesRef.putData(imgData!, metadata: metaData) { (metadata, error) in
            SVProgressHUD.dismiss()
                if error != nil {
                    print(error.debugDescription)
                } else {
                        var delurl = "";
                                            if self.selectedImgName == "image1" {
                                                delurl = Common.me?.imageUrl1 ?? "";
                                                               }else if self.selectedImgName == "image2" {
                                                delurl = Common.me?.imageUrl2 ?? "";
                                                               }else if self.selectedImgName == "image3" {
                                                  delurl = Common.me?.imageUrl3 ?? "";
                                                               }else if self.selectedImgName == "image4" {
                                                  delurl = Common.me?.imageUrl4 ?? "";
                                                               }else if self.selectedImgName == "image5" {
                                                  delurl = Common.me?.imageUrl5 ?? "";
                                                               }else if self.selectedImgName == "image6" {
                                                  delurl = Common.me?.imageUrl6 ?? "";
                                                               }
                                            if(delurl != ""  ){
                                                Common.firebaseStorage.reference(forURL:  delurl).delete(completion: nil)
                                            }
                    imagesRef.downloadURL(completion: { (url, error) in
                        if self.selectedImgName == "image1" {
                            Common.me?.imageUrl1 = (url?.absoluteString as String?)!
                        }else if self.selectedImgName == "image2" {
                            Common.me?.imageUrl2 = (url?.absoluteString as String?)!
                        }else if self.selectedImgName == "image3" {
                            Common.me?.imageUrl3 = (url?.absoluteString as String?)!
                        }else if self.selectedImgName == "image4" {
                            Common.me?.imageUrl4 = (url?.absoluteString as String?)!
                        }else if self.selectedImgName == "image5" {
                            Common.me?.imageUrl5 = (url?.absoluteString as String?)!
                        }else if self.selectedImgName == "image6" {
                            Common.me?.imageUrl6 = (url?.absoluteString as String?)!
                        }
                    })
                }
            }
    }

}
