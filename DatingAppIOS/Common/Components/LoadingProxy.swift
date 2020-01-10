//
//  LoadingProxy.swift
//  IOSChattingApp
//
//  Created by ADV on 2019/09/28.
//  Copyright © 2019 ADV. All rights reserved.
//

import UIKit
import APNGKit

struct LoadingProxy{
    
    static var myActivityIndicator: UIActivityIndicatorView!
    static var bgView: UIView!
    static var loadingImage: APNGImageView!
    static var loadTextImgView: UIImageView!
    static var isShow : Bool = false
    
    static func set(v:UIView){
        bgView = UIView.init(frame: v.frame);
        bgView.backgroundColor = UIColor.white;
        v.addSubview(bgView);
        //let c_width = v.frame.width;
        let c_width = Config.SCREEN_WIDTH;
        let c_height = Config.SCREEN_HEIGHT;
        // Load an APNG image from file in main bundle
        if let filePath = Bundle.main.url(forResource: "loading", withExtension: "apng") {
            print(filePath.absoluteString)
            /// Do something with the filePath
            
        }
        
        let imgPath = Bundle.main.path(forResource: "loading", ofType: "apng")
        if let path = imgPath {
            let image = APNGImage(contentsOfFile: path)
            loadingImage = APNGImageView(image: image);
            guard let asize = image?.size else { return }
            let logoWidth: CGFloat = SCALE(value: asize.width) / 2
            let logoHeight: CGFloat = SCALE(value: asize.height) / 2
            
//            loadingImage.frame = CGRect(x: (c_width - logoWidth)/2,
//                                        y: (c_height - logoHeight)/2 - logoHeight,
//                                        width: logoWidth,
//                                        height: logoHeight)
            v.addSubview(loadingImage)
        }
        
        let logoTextImg = UIImage(named: "loadlogo")!
        loadTextImgView = UIImageView(image: logoTextImg)
//        loadTextImgView.frame = CGRect(x: (UIScreen.main.bounds.width - logoTextImg.size.width) / 2,
//                                       y: loadingImage.frame.origin.y + loadingImage.frame.height + 40,
//                                       width: logoTextImg.size.width,
//                                       height: logoTextImg.size.height)
        
        v.addSubview(loadTextImgView)
        self.off();
    }
    
    static func on(){
        isShow = true
        bgView.isHidden = false;
//        loadingImage.isHidden = false;
//        loadingImage.startAnimating();
        loadTextImgView.isHidden = false
    }
    static func off(){
        isShow = false
        bgView.isHidden = true;
//        loadingImage.isHidden = true;
//        loadingImage.stopAnimating();
        loadTextImgView.isHidden = true
    }
    
    static func show(v:UIView){
        if isShow {
            return
        }
        self.set(v: v)
        self.on()
    }
    
}

