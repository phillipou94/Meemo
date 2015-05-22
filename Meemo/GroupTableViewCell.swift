//
//  GroupTableViewCell.swift
//  Meemo
//
//  Created by Phillip Ou on 5/6/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    //@IBOutlet weak var colorBar: UIView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var memoryCountTextField: UITextField!
    
    
    var group: Group? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(completion:(image:UIImage) -> Void) {
        if let group = self.group {
            var username = "Somebody"
            if let name = group.last_posted_name {
                username = name
            }
            
            if group.lastPostType == "text" {
                self.statusLabel.text = "\(username) posted a memory"
                //self.colorBar.backgroundColor = UIColor(hex: "3CB79E")
            } else if group.lastPostType == "photo" {
                self.statusLabel.text = "\(username) posted a photo"
                //self.colorBar.backgroundColor = UIColor(hex:"1E73B0")
            } else {
                self.statusLabel.text = "\(username) created this group"
                //self.colorBar.backgroundColor = UIColor(hex:"D14A5C")
            }
            
            loadImage({ (image) -> Void in
                completion(image:image)
            })

            self.nameLabel.text = group.name
            if group.has_seen {
                
            } else {
                self.memoryCountTextField.text = "New Memory"
            }
        }
        
    }
    
    func loadImage(completion:(image:UIImage) -> Void) {
        if let urlString = group?.imageURL {
            if let url = NSURL(string: urlString) {
                let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
                request.addValue("image/*", forHTTPHeaderField: "Accept")
                self.thumbnail.image = nil
                self.thumbnail.setImageWithUrlRequest(request, placeHolderImage: nil, success: { (request, response, image) -> Void in
                    self.thumbnail.image = image
                    completion(image:image)
                }, failure: nil)
            }
        }
        
        
    }

    
}
