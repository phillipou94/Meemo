//
//  GroupMemberCell.swift
//  Meemo
//
//  Created by Phillip Ou on 5/24/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class GroupMemberCell: UITableViewCell {

    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var initialsLabel: UILabel!
    
    var user:User? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        if let user = self.user {
            self.nameLabel.text = user.name
            self.initialsLabel.hidden = true
            loadThumbnail(user)
        }
        
    }
    
    func loadThumbnail(user:User) {
        if let facebook_id = user.facebook_id {
            self.thumbnail.layer.cornerRadius = self.thumbnail.frame.size.width/2
            self.thumbnail.layer.masksToBounds = true
            if let url = NSURL(string: "https://graph.facebook.com/\(facebook_id)/picture") {
                self.thumbnail.setImageWithUrl(url, placeHolderImage: nil)
            }
            
        } else {
            self.initialsLabel.layer.cornerRadius = self.initialsLabel.frame.size.width/2
            self.initialsLabel.layer.masksToBounds = true
            self.initialsLabel.text = user.getInitials()
            self.initialsLabel.hidden = false
        }
    }
    
}
