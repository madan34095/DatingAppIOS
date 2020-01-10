//
//  GenderViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/11/29.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class GenderViewController: UIViewController {

    @IBOutlet weak var femaleImg: UIImageView!
    @IBOutlet weak var maleImg: UIImageView!
    @IBOutlet weak var nextImg: UIImageView!
    
    private var isClickable: Bool = false
    private var selectedGender: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

        // Do any additional setup after loading the view.
    }


    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        if isClickable {
            Common.me?.gender = selectedGender
            let vc = NameViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func femaleBtnClicked(_ sender: Any) {
        selectedGender = "female"
        femaleImg.image = UIImage(named: "btn_female")
        maleImg.image = UIImage(named: "btn_male_0")
        nextImg.image = UIImage(named: "btn_next")
        isClickable = true
    }
    
    @IBAction func maleBtnClicked(_ sender: Any) {
        selectedGender = "male"
        femaleImg.image = UIImage(named: "btn_female_0")
        maleImg.image = UIImage(named: "btn_male")
        nextImg.image = UIImage(named: "btn_next")
        isClickable = true
    }
    
    
}
