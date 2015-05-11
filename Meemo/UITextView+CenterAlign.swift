//
//  UITextView+CenterAlign.swift
//  Meemo
//
//  Created by Phillip Ou on 5/11/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import Foundation

extension UITextView {
    func alignToCenter() {
        self.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil)
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        let textView = object as! UITextView
        var topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale)/2.0
        topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect)
        textView.contentOffset = CGPointMake(0, -topCorrect)
        
    }
    
    func disableAlignment() {
        self.removeObserver(self, forKeyPath: "contentSize")
    }
    
    
}
