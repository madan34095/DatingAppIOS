//
//  PassportViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/15.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PassportViewController: UIViewController
, UIImagePickerControllerDelegate
, UINavigationControllerDelegate {

    @IBOutlet weak var passportImg: UIImageView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var popView: UIView!
    
    var imgUrl:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.isHidden = true
        passportImg.layer.cornerRadius = 6
        passportImg.clipsToBounds = true

        popView.layer.cornerRadius = 6

        
    }

    @IBAction func passportImgBtnClicked(_ sender: Any) {
        alertView.isHidden = false
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cameraBtnClicked(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    @IBAction func galleryBtnClicked(_ sender: Any) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = true
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    @IBAction func closeBtnClicked(_ sender: Any) {
        alertView.isHidden = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        alertView.isHidden = true
        passportImg.image = image
        let imgData = image.jpegData(compressionQuality: 0.3)
        SVProgressHUD.show()
        let refKey = Common.firebaseDb.child("Users").childByAutoId().key
        let storageRef = Common.firebaseStorage.reference()
        let imagesRef = storageRef.child(Common.me!.fbId + "/" + refKey! + ".jpg")
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        imagesRef.putData(imgData!, metadata: metaData) { (metadata, error) in
            SVProgressHUD.dismiss()
                if error != nil {
                    print(error.debugDescription)
                } else {
                    imagesRef.downloadURL(completion: { (url, error) in
                        self.imgUrl = url!.absoluteString
                    })
                }
            }
    }

        
    @IBAction func sendBtnClicked(_ sender: Any) {
        if imgUrl != "" {
            FirebaseApiManager.sendPassportImg(img_path: imgUrl) { (result) in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
}
