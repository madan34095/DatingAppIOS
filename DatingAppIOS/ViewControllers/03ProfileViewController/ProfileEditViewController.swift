//
//  ProfileEditViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/12.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ProfileEditViewController: UIViewController
, UITableViewDelegate
, UITableViewDataSource
, UIImagePickerControllerDelegate
, UINavigationControllerDelegate
, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var mainCell: UITableViewCell!
    
    @IBOutlet weak var mainImg: UIImageView!
    
    @IBOutlet weak var subImg1: UIImageView!
    @IBOutlet weak var subImg2: UIImageView!
    @IBOutlet weak var subImg3: UIImageView!
    @IBOutlet weak var subImg4: UIImageView!
    @IBOutlet weak var subImg5: UIImageView!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var popView: UIView!
    @IBOutlet weak var jobEditView: UITextField!
    @IBOutlet weak var introTxt: UITextView!
    @IBOutlet weak var numLb: UILabel!

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
        
        initSetImg(imgView: mainImg, path: Common.me!.imageUrl1)
        initSetImg(imgView: subImg1, path: Common.me!.imageUrl2)
        initSetImg(imgView: subImg2, path: Common.me!.imageUrl3)
        initSetImg(imgView: subImg3, path: Common.me!.imageUrl4)
        initSetImg(imgView: subImg4, path: Common.me!.imageUrl5)
        initSetImg(imgView: subImg5, path: Common.me!.imageUrl6)
        
        jobEditView.text = Common.me?.jobTitle
        introTxt.text = Common.me?.about

        
        popView.layer.cornerRadius = 6

        introTxt.delegate = self

        addDoneButtonOnKeyboard()

    }
    
    private func initSetImg(imgView: UIImageView, path: String?) {
        if path == nil {
            return
        }
        if path != "" {
            let url = NSURL(string: path!)
            imgView.sd_setImage(with: url as URL?) { (img, err, type, url) in
            }
        }else {
            imgView.image = UIImage(named: "profile_image_placeholder")
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = Config.MAXCHARACTER
        let currentString: NSString = textView.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: text) as NSString
        self.numLb.text = "\(newString.length ?? 0)/500"
        return newString.length <= maxLength-1
    }
    

    func textViewDidEndEditing(_ textView: UITextView) {
    }

    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.jobEditView.inputAccessoryView = doneToolbar
        self.introTxt.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        self.jobEditView.resignFirstResponder()
        self.introTxt.resignFirstResponder()
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
            return 1
        }
        //-------------------------------------------------------------------------------------------------------------------------
        //                                              Cell for row at index path
        //-------------------------------------------------------------------------------------------------------------------------
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = mainCell
            return cell!
        }
     //-------------------------------------------------------------------------------------------------------------------------
        //                                              Height for row at indexPath
        //-------------------------------------------------------------------------------------------------------------------------
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 800
        }

    private func updateMyProfile() {
        let addInfo: NSMutableDictionary = (Common.me?.getDictionaryData())!
        addInfo.addEntries(from: ["state" : "1"])
        addInfo.addEntries(from: ["type" : "iphone"])
        addInfo.addEntries(from: ["token" : Common.deviceToken])
        addInfo.addEntries(from: ["created_at" : Common.currentTimeInMiliseconds()])
        FirebaseApiManager.updateUser(u_id: Common.me!.fbId, docData: addInfo) { (result) in
            if result {
                DispatchQueue.main.async
                {
                    self.navigationController?.popViewController(animated: true)
                }
            }else {
                
            }
        }
    }
    
    
        @IBAction func backBtnClicked(_ sender: Any) {
            self.navigationController?.popViewController(animated: true)
        }
        
        @IBAction func previewBtnClicked(_ sender: Any) {
            Common.me?.jobTitle = self.jobEditView.text!
            Common.me?.about = self.introTxt.text
            let vc = ProfileDetailViewController()
            vc.userId = Common.me?.fbId
            self.present(vc, animated: true, completion: nil)
        }
    
        @IBAction func saveBtnClicked(_ sender: Any) {
            Common.me?.jobTitle = self.jobEditView.text!
            Common.me?.about = self.introTxt.text
            updateMyProfile()
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
            self.present(vc, animated: true)
        }
        
        @IBAction func galleryBtnClicked(_ sender: Any) {
            let vc = UIImagePickerController()
            vc.sourceType = .photoLibrary
            vc.allowsEditing = true
            vc.delegate = self
            self.present(vc, animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true)
            guard let image = info[.editedImage] as? UIImage else {
                return
            }
            alertView.isHidden = true
            selectedImgView.image = image
            let imgData = image.jpegData(compressionQuality: 0.3)
            SVProgressHUD.show()
            let refKey = Common.firebaseDb.child("Users").childByAutoId().key
            let storageRef = Common.firebaseStorage.reference()
            let imagesRef = storageRef.child("image/" + refKey! + ".jpg")
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            imagesRef.putData(imgData!, metadata: metaData) { (metadata, error) in
                SVProgressHUD.dismiss()
                    if error != nil {
                        print(error.debugDescription)
                    } else {
                        if self.imgPath != "null" {
    
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
