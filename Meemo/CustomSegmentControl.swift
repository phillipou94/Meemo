//
//  CustomSegmentControl.swift
//  Meemo
//
//  Created by Phillip Ou on 4/23/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

@IBDesignable class CustomSegmentControl: UIControl {
    
    private var labels = [UILabel]()
    var thumbView = UIView()
    
    var selectedIndex : Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    
    var items:[String] = ["Groups", "Memories"] {
        didSet {
            setUpLabels()
        }
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        setUpView()
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var selectedFrame = self.bounds
        let newWidth = CGRectGetWidth(selectedFrame) / CGFloat(items.count)
        selectedFrame.size.width = newWidth
        
       displayNewSelectedIndex()
       self.thumbView.backgroundColor = UIColor(red: 48/255.0, green: 45/255.0, blue: 64/255.0, alpha: 1.0)
        let labelHeight = self.bounds.height
        let labelWidth = self.bounds.width / CGFloat(labels.count)
        for index in 0..<labels.count {
            var label = labels[index]
            let xPosition = CGFloat(index)*labelWidth
            label.frame = CGRectMake(xPosition,0,labelWidth,labelHeight)
        }
        
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let location = touch.locationInView(self)
        
        var calculatedIndex: Int?
        for (index,item) in enumerate(labels) {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActionsForControlEvents(.ValueChanged)
        }
        
        return false
    }
    
    
    func setUpView() {
        backgroundColor = UIColor.whiteColor()
        setUpLabels()
        insertSubview(thumbView, atIndex:0)
    }
    
    func setUpLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        
        labels.removeAll(keepCapacity: true)
        
        for index in 0..<items.count {
            let label = UILabel(frame:CGRectZero)
            label.text = items[index]
            label.textAlignment = .Center
            label.textColor = UIColor(red: 48/255.0, green: 45/255.0, blue: 64/255.0, alpha: 1.0)
            self.addSubview(label)
            labels.append(label)
        }
    }
    
    func displayNewSelectedIndex() {
        var label = labels[selectedIndex]
        let thumbViewHeight = CGFloat(3)
        self.thumbView.frame = CGRectMake(label.frame.origin.x, label.frame.size.height - thumbViewHeight,label.frame.size.width,thumbViewHeight)
    }
    
}