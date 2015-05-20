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
    var user_id:NSNumber? = nil
    @IBOutlet weak var postImageView: UIImageView!

    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shadeView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    func configureCell(completion:(image:UIImage) -> Void) {
        if let post = self.post {
            if let title = post.title {
                self.titleLabel.text = title
                self.titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
            } else {
                self.titleLabel.hidden = true
            }
            
            if user_id == post.user_id {
                nameLabel.text = "Me"
            } else {
                nameLabel.text = post.user_name
            }
            
            if post.image != nil {
                self.postImageView.image = post.image
            } else {
                loadImage({ (image) -> Void in
                    completion(image:image)
                })
            }

        }
        
    }
    
    func loadImage(completion:(image:UIImage) -> Void) {
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
