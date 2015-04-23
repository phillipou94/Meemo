//
//  CreateGroupsViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 4/23/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import Foundation

class CreateGroupsViewController: UIViewController {
    @IBOutlet var headerView: UIView!
    @IBOutlet var groupTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
        
        let shadeView = ShadeView(frame: self.view.frame)
        self.view.insertSubview(shadeView, belowSubview: headerView)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
