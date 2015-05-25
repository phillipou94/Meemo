//
//  GroupPreviewCell.swift
//  Meemo
//
//  Created by Phillip Ou on 5/12/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class GroupPreviewCell: UITableViewCell {
    var group:Group? = nil
    @IBOutlet weak var thumbnail: UIImageView!
    
    @IBOutlet var shadeView: UIView!
    @IBOutlet weak var groupNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        self.groupNameLabel.text = group?.name
        if let imageURL = self.group!.imageURL {
            if let url = NSURL(string: imageURL){
                self.thumbnail.setImageWithUrl(url, placeHolderImage: nil)
                
            } else {
                self.thumbnail.image = UIImage(named: "Default")
            }
        }
        
    }
    
}
