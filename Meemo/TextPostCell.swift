//
//  TextPostCell.swift
//  Meemo
//
//  Created by Phillip Ou on 5/12/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Spring 
class TextPostCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var optionButton: SpringButton!
    @IBOutlet weak var contentLabel: UILabel!
    var user_id:NSNumber? = nil
    var post:Post? = nil
    var row: Int? = nil
    
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        if let post = self.post {
            contentLabel.text = post.content
            if user_id == post.user_id {
                nameLabel.text = "Me"
            } else {
                nameLabel.text = post.user_name
            }
        }
    }
    @IBAction func optionPressed(sender: AnyObject) {
        if let post = self.post {
            NSNotificationCenter.defaultCenter().postNotificationName("ShowActionSheetMain", object: nil, userInfo: ["postToDelete":post])
        }
        
    }
    
}
