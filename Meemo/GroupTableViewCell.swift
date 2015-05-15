//
//  GroupTableViewCell.swift
//  Meemo
//
//  Created by Phillip Ou on 5/6/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var colorBar: UIView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var statusLabel: UILabel!
    var group: Group? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        if let group = self.group {
            if group.has_seen {
                self.colorBar.hidden = true
            } else {
                self.colorBar.hidden = false
            }
            
            self.nameLabel.text = group.name
        }
        
    }
    
}
