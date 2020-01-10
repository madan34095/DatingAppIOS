//
//  CustomHeightTabBar.swift
//  SampleApplicatinX
//
//  Created by ADV on 2019/11/25.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class CustomHeightTabBar : UITabBar {

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatTab = super.sizeThatFits(size)
        sizeThatTab.height = 50
        return sizeThatTab
    }
}
