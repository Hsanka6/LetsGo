//
//  TopRestaurantTableViewCell.swift
//  RestaurantTinder
//
//  Created by Haasith Sanka on 1/4/17.
//  Copyright © 2017 haasith. All rights reserved.
//

import UIKit
import Kingfisher
import QuartzCore
class TopRestaurantTableViewCell: UITableViewCell {

   
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var milesAway: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var checkIns: UILabel!
    @IBOutlet var bestOutput: UILabel!
    
    @IBOutlet var backView: UIView!
    
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
        
        
        
        
        rating.layer.masksToBounds = true
        rating.layer.cornerRadius = 5
        
        restaurantIcon.layer.masksToBounds = true
        restaurantIcon.layer.cornerRadius = 8

        //FF8A00 orange
        //FF165E red
        //1982FF blue
        
        name.text = restaurantName
        let blue1 = hexStringToUIColor(hex: "#1982FF")
        let yellow = hexStringToUIColor(hex: "#FF8A00")
        let red = hexStringToUIColor(hex: "#FF165E")
        
        if Rating >= 0 && Rating < 4
        {
            rating.backgroundColor = red
        }
        else if Rating >= 4 && Rating < 7
        {
            rating.backgroundColor = yellow
        }
        else
        {
            rating.backgroundColor = blue1
        }
        rating.text = String(Rating)
        
        checkIns.text = "Visits: " + String(CheckIns)
        milesAway.text = String(format: "%.1f", MilesAway) + " mi"
        
        
        let url = URL(string: ImageUrl)
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


extension UIViewController
{
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



