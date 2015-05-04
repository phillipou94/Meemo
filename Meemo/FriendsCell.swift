//
//  FriendsCell.swift
//  Meemo
//
//  Created by Phillip Ou on 5/2/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell {

    @IBOutlet var initialsLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var thumbnail: UIImageView!
    var user:User? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell() {
        if let user = self.user {
            self.nameLabel.text = user.name
            if user.facebook_id != nil {
                self.infoLabel.text = "Facebook Friend"
            } else if user.phoneNumber != nil {
                self.infoLabel.text = user.phoneNumber
            }
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
            self.initialsLabel.backgroundColor = UIColor(red: 62/255.0, green: 61/255.0, blue: 83/255.0, alpha: 1.0)
            self.initialsLabel.textColor = UIColor.whiteColor()
            self.initialsLabel.hidden = false
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
