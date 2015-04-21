//
//  GroupsViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 4/21/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import Foundation
import Spring
class GroupsViewController: UIViewController {
    @IBOutlet weak var addButton: SpringButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        var rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = M_PI/4.0
        rotation.duration = 1.0
        self.addButton.layer.addAnimation(rotation, forKey: "rotationAnimation")
    }
    


}
