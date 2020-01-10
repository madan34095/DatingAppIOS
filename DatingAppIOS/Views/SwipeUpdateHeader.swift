//
//  SwipeUpdateHeader.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/10/15.
//  Copyright © 2019 ADV. All rights reserved.
//

import Foundation
import UIKit
import PullToRefreshKit

class SwipeUpdateHeader: UIView,RefreshableHeader{
        
    let indicate = UIActivityIndicatorView()
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = Config.white
            indicate.startAnimating()
            addSubview(indicate)
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            indicate.center = CGPoint(x: self.bounds.width/2.0, y: frame.height - 20)
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - RefreshableHeader -
        func heightForHeader() -> CGFloat {
            return UIScreen.main.bounds.size.height
        }
        
        func heightForFireRefreshing() -> CGFloat {
            return 40.0
        }
        
        func heightForRefreshingState() -> CGFloat {
            return 40.0
        }
        
        func percentUpdateDuringScrolling(_ percent: CGFloat) {
        }
        func startTransitionAnimation(){
        }
        @objc func transitionFinihsed(){
        }
        //松手即将刷新的状态
        func didBeginRefreshingState(){
        }
        //刷新结束，将要隐藏header
        func didBeginHideAnimation(_ result:RefreshResult){
        }
        //刷新结束，完全隐藏header
        func didCompleteHideAnimation(_ result:RefreshResult){
        }
    }
