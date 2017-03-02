//
//  FullScreenViewController.swift
//  RestaurantTinder
//
//  Created by Haasith Sanka on 3/1/17.
//  Copyright © 2017 haasith. All rights reserved.
//

import UIKit
import Kingfisher
import QuartzCore

class FullScreenViewController: UIViewController
{

    var imgUrl:String = ""
    var currentLat:Double!
    var currentLon:Double!
    var storeLat:Double!
    var storeLon:Double!
    
    
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func backButton(_ sender: Any)
    {
        performSegue(withIdentifier: "toRest", sender: currentLat)
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()


        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        let aString = "350x350"
        let newString = imgUrl.replacingOccurrences(of: "250x250", with: aString, options: .literal, range: nil)
        let imgString = URL(string: newString)
        imageView.kf.setImage(with: imgString)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRest"
        {
            if let destination = segue.destination as? RestaurantViewController
            {
                if let lat = sender as? Double
                {
                    destination.currentLat =  currentLat
                    destination.currentLon = currentLon
                }
                
            }
        }
    }

}
