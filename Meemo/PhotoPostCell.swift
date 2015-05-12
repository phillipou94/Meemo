//
//  PhotoPostCell.swift
//  Meemo
//
//  Created by Phillip Ou on 5/12/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class PhotoPostCell: UITableViewCell {
    var post:Post? = nil
    @IBOutlet weak var postImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        if let url = NSURL(string: post!.file_url!) {
            self.postImageView.setImageWithUrl(url, placeHolderImage: nil)
        }
    }
    
}
