//
//  ShadeView.swift
//  Meemo
//
//  Created by Phillip Ou on 4/22/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Spring

class ShadeView: UIView {
    var blurEffectView: UIVisualEffectView = UIVisualEffectView()
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame:CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        let blurEffect = UIBlurEffect(style: .Dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.addSubview(blurEffectView)
        self.bringSubviewToFront(blurEffectView)
        blurEffectView.frame = self.frame
        
    }
}
