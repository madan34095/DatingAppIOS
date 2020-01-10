//
//  TabBarViewController.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/09/28.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController , UITabBarControllerDelegate {
    
    var clickItem : UITabBarItem?
    var curVC : UIViewController?
    var prevIndex : NSInteger = 0;
    private var delegateObj: AppDelegate?;

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self;
        
//        let item1 = self.tabBar.items![0] as UITabBarItem;
//        let item2 = self.tabBar.items![1] as UITabBarItem;
//
//        item1.image = UIImage(named: "posting.png")?.withRenderingMode(.alwaysOriginal);
//        item1.imageInsets = UIEdgeInsets(top: _h, left: 0, bottom: _b, right: 0);
//        item2.image = UIImage(named: "search.png")?.withRenderingMode(.alwaysOriginal);
//        item2.imageInsets = UIEdgeInsets(top: _h, left: 0, bottom: _b, right: 0);
//
//        item1.title = "";
//        item2.title = "";
//
//        item1.selectedImage = UIImage(named: "posting_selected.png")?.withRenderingMode(.alwaysOriginal);
//        item2.selectedImage = UIImage(named: "search_selected.png")?.withRenderingMode(.alwaysOriginal);
        
        setNeedsStatusBarAppearanceUpdate();
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        clickItem = item;
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabitem = tabBarController.selectedIndex;
        let currentNavView :UINavigationController = tabBarController.selectedViewController as! UINavigationController
        currentNavView.popToRootViewController(animated: true)
    }
}
