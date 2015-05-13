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
    
    func configureCell(completion:(image:UIImage) -> Void) {
        if post?.image != nil {
            self.postImageView.image = post?.image
        } else {
            if let url = NSURL(string: post!.file_url!) {
                let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                request.addValue("image/*", forHTTPHeaderField: "Accept")
                self.postImageView.image = nil
                self.postImageView.setImageWithUrlRequest(request, placeHolderImage: nil, success: { (request, response, image) -> Void in
                    self.postImageView.image = image
                    completion(image:image)
                    }, failure: nil)
            }
        }
        
    }
    
}
