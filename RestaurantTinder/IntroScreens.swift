//
//  IntroScreens.swift
//  RestaurantTinder
//
//  Created by Haasith Sanka on 4/1/17.
//  Copyright © 2017 haasith. All rights reserved.
//

import UIKit
import ImageSlideshow

class IntroScreens:UIViewController
{
    @IBOutlet var imageScreens: ImageSlideshow!
    var lat: Double = 0.0
    var lon: Double = 0.0
    
    @IBAction func skipToApp(_ sender: Any)
    {
        
        performSegue(withIdentifier: "Orig", sender: self)
    }
    override func viewDidLoad() {
        imageScreens.pageControl.currentPageIndicatorTintColor = UIColor.white
        imageScreens.pageControl.pageIndicatorTintColor = UIColor.black
        imageScreens.contentScaleMode = UIViewContentMode.scaleAspectFill
        imageScreens.setImageInputs([
            ImageSource(image: UIImage(named: "onboarding_screen01")!),ImageSource(image: UIImage(named: "onboarding_screen02")!),ImageSource(image: UIImage(named: "onboarding_screen03")!),ImageSource(image: UIImage(named: "onboarding_screen04")!),ImageSource(image: UIImage(named: "onboarding_screen05")!),ImageSource(image: UIImage(named: "onboarding_screen06")!)])
        
        
        
        
        
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Orig"
        {
            if let destination = segue.destination as? ViewController
            {
                destination.lat = lat
                destination.lon = lon
            }
            
        }

    }
    
    
    
    
    
    
    
    
}
