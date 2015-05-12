//
//  TextPostCell.swift
//  Meemo
//
//  Created by Phillip Ou on 5/12/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class TextPostCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    var post:Post? = nil
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
            let user_id = CoreDataRequest.sharedManager.getUserCredentials()?.object_id
            if user_id == post.user_id {
                nameLabel.text = "Me"
            } else {
                nameLabel.text = post.user_name
            }
        }
    }
    
}