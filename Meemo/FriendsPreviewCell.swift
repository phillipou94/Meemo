//
//  FriendsPreviewCell.swift
//  Meemo
//
//  Created by Phillip Ou on 5/3/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class FriendsPreviewCell: UICollectionViewCell {

    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var initialsLabel: UILabel!
    var user:User? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell() {
        if let user = self.user {
            if let facebook_id = user.facebook_id {
                self.thumbnail.layer.cornerRadius = self.thumbnail.frame.size.width/2
                self.thumbnail.layer.masksToBounds = true
                if let url = NSURL(string: "https://graph.facebook.com/\(facebook_id)/picture") {
                    self.thumbnail.setImageWithUrl(url, placeHolderImage: nil)
                }
                
            } else {
                self.initialsLabel.layer.masksToBounds = true
                self.initialsLabel.layer.cornerRadius = self.initialsLabel.frame.size.width/2
                self.initialsLabel.text = user.getInitials()
                self.initialsLabel.backgroundColor = UIColor.whiteColor()
                self.initialsLabel.textColor = UIColor(red: 62/255.0, green: 61/255.0, blue: 83/255.0, alpha: 1.0)
                self.initialsLabel.hidden = false
            }

        }
        
    }


}
