//
//  FillerSettingViewController.swift
//  DatingAppIOS
//
//  Created by ADV on 2019/12/15.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import SwiftRangeSlider

class FillerSettingViewController: UIViewController {

    @IBOutlet weak var distanceTxt: UILabel!
    @IBOutlet weak var ageTxt: UILabel!
    @IBOutlet weak var distanceSlider: RangeSlider!
    @IBOutlet weak var ageSlider: RangeSlider!
    
    
    var curMinDistance: Double = 10
    var curMaxDistance: Double = 100
    var curMinAge: Double = 15
    var curMaxAge: Double = 80

    override func viewDidLoad() {
        super.viewDidLoad()

        
        curMinDistance = Double(LocalstorageManager.getMinDistance())!
        curMaxDistance = Double(LocalstorageManager.getMaxDistance())!
        curMinAge = Double(LocalstorageManager.getMinAge())!
        curMaxAge = Double(LocalstorageManager.getMaxAge())!
        
        distanceSlider.lowerValue = Double(curMinDistance)
        distanceSlider.upperValue = Double(curMaxDistance)
        distanceTxt.text = "\(Int(curMinDistance) ?? 0)-\(Int(curMaxDistance))km"

        ageSlider.lowerValue = Double(curMinAge)
        ageSlider.upperValue = Double(curMaxAge)
        ageTxt.text = "\(Int(curMinAge) ?? 0)-\(Int(curMaxAge) ?? 0)"
    }
    
    override func viewDidLayoutSubviews() {
        distanceSlider.updateLayerFramesAndPositions()
        ageSlider.updateLayerFramesAndPositions()
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        LocalstorageManager.setMinDistance(code: "\(curMinDistance ?? 0)")
        LocalstorageManager.setMaxDistance(code: "\(curMaxDistance ?? 0)")
        LocalstorageManager.setMinAge(code: "\(curMinAge ?? 0)")
        LocalstorageManager.setMaxAge(code: "\(curMaxAge ?? 0)")
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func distanceSliderChanged(_ sender: RangeSlider) {
        curMinDistance = sender.lowerValue
        curMaxDistance = sender.upperValue
        distanceTxt.text = "\(Int(curMinDistance) ?? 0)-\(Int(curMaxDistance))km"
    }
    
    @IBAction func ageSliderChanged(_ sender: RangeSlider) {
        curMinAge = sender.lowerValue
        curMaxAge = sender.upperValue
        ageTxt.text = "\(Int(curMinAge) ?? 0)-\(Int(curMaxAge) ?? 0)"
    }
    
}

