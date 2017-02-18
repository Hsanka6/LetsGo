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
        
        
        var color1 = hexStringToUIColor(hex: "#03A9F4")

        
        rating.layer.cornerRadius = 20
        rating.layer.borderWidth = 3.0
        rating.layer.backgroundColor = color1.cgColor
        rating.layer.borderColor = color1.cgColor
        
        
        
        name.text = restaurantName
        rating.text = String(Rating)
        checkIns.text = "Visits: " + String(CheckIns)
        milesAway.text = String(format: "%.2f", MilesAway) + " mi"
        
        
        let url = URL(string: ImageUrl)
        print(url)
        restaurantIcon.kf.setImage(with: url)
        
        
        
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    

}


