//
//  UIViewController.swift
//  SampleApplicatinX
//
//  Created by ADV on 2019/11/15.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

extension UIViewController {
    static func createFromNib<T: UIViewController>(storyBoardId: String) -> T?{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: storyBoardId) as? T
    }
}
