//
//  TipTableViewCell.swift
//  RestaurantTinder
//
//  Created by Haasith Sanka on 1/14/17.
//  Copyright © 2017 haasith. All rights reserved.
//

import UIKit

class TipTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var comment: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
