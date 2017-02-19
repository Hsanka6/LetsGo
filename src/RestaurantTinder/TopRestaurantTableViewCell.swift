//
//  TopRestaurantTableViewCell.swift
//  RestaurantTinder
//
//  Created by ganga sanka on 1/4/17.
//  Copyright © 2017 haasith. All rights reserved.
//

import UIKit
import Kingfisher
class TopRestaurantTableViewCell: UITableViewCell {

   
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var milesAway: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var checkIns: UILabel!
    
    
    @IBOutlet weak var restaurantIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUp(restaurantName: String, Rating: Double, MilesAway: Double, CheckIns: Int, ImageUrl:String) {
        name.text = restaurantName
        rating.text = String(Rating)
        checkIns.text = "Visits: " + String(CheckIns)
        milesAway.text = String(format: "%.2f", MilesAway) + " mi"
        
        
        let url = URL(string: ImageUrl)
        print(url)
        restaurantIcon.kf.setImage(with: url)
        
        
        
    }
    
    
    

}
