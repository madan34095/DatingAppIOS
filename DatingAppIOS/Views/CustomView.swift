//
//  CustomView.swift
//  TinderSwipeView_Example
//
//  Created by Nick on 29/05/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SDWebImage

class CustomView: UIView {
        
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var aboutText: UILabel!
    @IBOutlet weak var imageViewBackground: UIImageView!
    @IBOutlet weak var buttonAction: UIButton!
    
    var user : User! {
        didSet{
            self.nameText.text = user.name
            self.aboutText.attributedText = self.attributeStringForModel(user: user)
            if user.imageUrl1 != "" {
                let url = NSURL(string: user.imageUrl1)
                self.imageViewBackground.sd_setImage(with: url as URL?) { (img, err, type, url) in
                }
            }else {
//                self.imageViewBackground.image = UIImage(named: "profile_image_placeholder")
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(CustomView.className, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    private func attributeStringForModel(user: User) -> NSAttributedString{
        
        let attributedText = NSMutableAttributedString(string: user.about, attributes: [.foregroundColor: UIColor.white,.font:self.aboutText.font])
        return attributedText
    }

}

extension UIView{
    
    func fixInView(_ container: UIView!) -> Void{
        
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}

extension NSObject {
    
    class var className: String {
        return String(describing: self)
    }
}
