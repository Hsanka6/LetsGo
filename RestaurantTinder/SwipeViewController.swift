//
//  SwipeViewController.swift
//  RestaurantTinder
//
//  Created by Haasith Sanka on 12/29/16.
//  Copyright © 2016 haasith. All rights reserved.
//
import UIKit
import Kingfisher
import QuartzCore
import SCLAlertView
import NVActivityIndicatorView

class SwipeViewController: UIViewController {
    
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var Picture: UIImageView!
    var imgs = [String]()
    var yesNoArray = [String]()
    var restaurant = [String]()
    var i = 0
    var store1:String! = ""
    var store2:String! = ""
    var store3:String! = ""
    var store4:String! = ""
    var store5:String! = ""
    var currentLat = 0.0
    var currentLon = 0.0
    var numRows:Int = 0
    var totalImgs = 0
    var timer = Timer()
    var currentImage = 0
    
    @IBOutlet var indicator: NVActivityIndicatorView!
    
    @IBOutlet var remainSwipes: UILabel!
    @IBAction func endButton(_ sender: Any)
    {
        
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
            //circleBackgroundColor: UIColor.black.cgColor
        )
        let alertView = SCLAlertView(appearance: appearance)
        //let alertViewIcon = UIImage(named: "finalLogo")
        alertView.addButton("Confirm",backgroundColor: hexStringToUIColor(hex: "#FF9800"), target:self,selector:#selector(SwipeViewController.End))
        alertView.addButton("Cancel",backgroundColor: hexStringToUIColor(hex: "#FF9800")) {
            alertView.dismiss(animated: true, completion: nil)
        }
        alertView.showWait("Warning", subTitle: "Are you sure you want to skip swiping? Results won't be personalized")
        
        
        
        
        
    }
    
    
    func End() {
        while(i < yesNoArray.count)
        {
            if self.verifyUrl(urlString: self.yesNoArray[i]) == true
            {
                self.yesNoArray[i] = "NO"
            }
            else
            {
                print("this is a restaurant")
            }
            i += 1
        }
        self.performSegue(withIdentifier: "SendTopData", sender: nil)
    }
    
    
    
    @IBAction func back(_ sender: Any) 
    {
        self.performSegue(withIdentifier: "clear", sender: self.imgs)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if segue.identifier == "clear"
        {
            if let destination = segue.destination as? SearchPageController
            {
                destination.pics = []
                destination.lat = currentLat
                destination.lon = currentLon
            }
        }
        
        if segue.identifier == "end"
        {
            if let destination = segue.destination as? TopRestaurantsController
            {
                destination.yesNo = yesNoArray
                print("got in there")
                print(destination.yesNo)
                
                
            }
            
        }
        if segue.identifier == "SendTopData"
        {
            if let destination = segue.destination as? TopRestaurantsController
            {
                destination.yesNo = yesNoArray
                destination.numRows = numRows
                
                
                if store1 != ""
                {
                    destination.storeId1 = store1
                }
                else
                {
                    store1 = "NULL"
                }
                if store2 != ""
                {
                    destination.storeId2 = store2
                }
                else
                {
                    store2 = "NULL"
                }
                if store3 != ""
                {
                    destination.storeId3 = store3
                }
                else
                {
                    store3 = "NULL"
                }
                if store4 != ""
                {
                    destination.storeId4 = store4
                }
                else
                {
                    store4 = "NULL"
                }
                if store5 != ""
                {
                    destination.storeId5 = store5
                }
                else
                {
                    store5 = "NULL"
                }
                
                if currentLat == 0
                {
                    destination.currentLat = 0.0
                    
                    
                }
                else
                {
                    destination.currentLat = currentLat
                    
                }
                
                
                if currentLon == 0
                {
                    destination.currentLon = 0.0
                    
                    
                }
                else
                {
                    destination.currentLon = currentLon
                    
                }
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        yesNoArray = imgs
        background.layer.masksToBounds = false
        background.layer.shadowColor = UIColor.black.cgColor
        //background.layer.shadowRadius = 5;
        background.layer.shadowOpacity = 1.5;
        background.layer.shadowOffset = CGSize.zero
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        Picture.addGestureRecognizer(gesture)
        Picture.isUserInteractionEnabled = true
        print("these are restaurant ids")
        print(restaurant)
        
        view.bringSubview(toFront: indicator)
        indicator.isHidden = true
        
        var height = 0
        var width = 0
        height = Int(Picture.frame.height)
        width = Int(Picture.frame.width)
        var p = 0
        while(p < imgs.count)
        {
            imgs[p] = imgs[p].replacingOccurrences(of: "300x300", with: "\(height)x\(width)", options: .literal, range: nil)
            p += 1
        }
        
        
        
        if restaurant.count >= 1
        {
            store1 = restaurant[0]
            
        }
        if restaurant.count >= 2
        {
            store2 = restaurant[1]
            
        }
        else
        {
            store2 = "NULL"
        }
        
        if restaurant.count >= 3
        {
            store3 = restaurant[2]
            
        }
        else
        {
            store3 = "NULL"
        }
        
        if restaurant.count >= 4
        {
            store4 = restaurant[3]
            
        }
        else
        {
            store4 = "NULL"
        }
        
        if restaurant.count >= 5
        {
            store5 = restaurant[4]
            
        }
        else
        {
            store5 = "NULL"
        }
        
        
        totalImgs = imgs.count - restaurant.count
        
        
        
        
        remainSwipes.text = "Current Picture: " + String(i) + "/\(totalImgs)"
        
        
        
        
        
       
            let ur = URL(string: imgs[0])
            self.Picture.kf.setImage(with: ur)
        
        
    
        
        
        
    }
    
//    func scheduledTimerWithTimeInterval(){
//        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
//        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.change), userInfo: nil, repeats: true)
//    }
//    func change()
//    {
//        print(i)
//        
//    }
//    
    
    
    func wasDragged(gesture: UIPanGestureRecognizer)
    {
        let translation = gesture.translation(in: self.view)
        let label = gesture.view!
        
        label.center = CGPoint(x: self.view.bounds.width/2 + translation.x , y: self.view.bounds.height/2 + translation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width/2
        
        let scale = min(100/abs(xFromCenter),1)
        
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter/200)
        
        var stretch = rotation.scaledBy(x: scale, y: scale)
        
        label.transform = stretch
        if gesture.state == UIGestureRecognizerState.ended
        {
            if self.i == 0
            {
                doFirstCondition(gesture: gesture, label: label as! UIImageView)
            }
            else
            {
                if i < imgs.count - 1
                {
              
                    if label.center.x < 100
                    {
                        self.yesNoArray[i] = "NO"
                        if verifyUrl(urlString: self.imgs[i+1]) == false
                        {
                            if i + 2 < imgs.count
                            {
                                let url = URL(string: self.imgs[i+2])! // i = 1
                                self.Picture.kf.setImage(with: url)
                                i = i + 1
                            }
                            else
                            {
                                indicator.isHidden = false
                                indicator.startAnimating()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                                {
                                  //  self.indicator.stopAnimating()
                                    self.performSegue(withIdentifier: "SendTopData", sender: nil)
                                }
                                
                            }
                            
                        }
                        else
                        {
                            let url = URL(string: self.imgs[i+1])! // i = 1
                            self.Picture.kf.setImage(with: url)
                        }
                        
                    }
                    else if label.center.x > self.view.bounds.width - 100
                    {
                        self.yesNoArray[i] = "YES"
                        if verifyUrl(urlString: self.imgs[i+1]) == false
                        {
                            if i + 2 < imgs.count
                            {
                                let url = URL(string: self.imgs[i+2])! // i = 1
                                self.Picture.kf.setImage(with: url)
                                i = i + 1
                            }
                            else
                            {
                                indicator.isHidden = false
                                indicator.startAnimating()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                                {
                                 //   self.indicator.stopAnimating()
                                    self.performSegue(withIdentifier: "SendTopData", sender: nil)
                                }
                                
                            }
                            
                        }
                        else
                        {
                            let url = URL(string: self.imgs[i+1])! // i = 1
                            self.Picture.kf.setImage(with: url)
                        }
                    }
                }
                else
                {
                    performSegue(withIdentifier: "SendTopData", sender: nil)
                }
                
                
            }
            rotation = CGAffineTransform(rotationAngle: 0)
            
            stretch = rotation.scaledBy(x: 1,y: 1)
            
            label.transform = stretch
            
            label.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
            
            currentImage += 1
            i = i + 1
            print(yesNoArray)
            if i < imgs.count - 1
            {
                Picture.image = UIImage(named:"Rectangle 5")
            }
            
            if currentImage > totalImgs
            {
                currentImage = currentImage - 1
            }
            
            remainSwipes.text = "Current Picture: " + String(currentImage) + "/\(totalImgs)"
            
            
        }
        
        
        
    }
    
    
    
    
    func doFirstCondition(gesture: UIPanGestureRecognizer, label: UIImageView)
    {
        if gesture.state == UIGestureRecognizerState.ended
        {
            if label.center.x < 100
            {
                self.yesNoArray[i] = "NO"
                if verifyUrl(urlString: self.imgs[i+1]) == false
                {
                    if i + 2 < imgs.count
                    {
                        let url = URL(string: self.imgs[i+2])! // i = 1
                        self.Picture.kf.setImage(with: url)
                        i = i + 1
                    }
                    else
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            self.performSegue(withIdentifier: "SendTopData", sender: nil)
                        }
                    }
                }
                else
                {
                    let url = URL(string: self.imgs[i+1])! // i = 1
                    self.Picture.kf.setImage(with: url)
                }
            }
            else if label.center.x > self.view.bounds.width - 100
            {
                self.yesNoArray[i] = "YES"
                if verifyUrl(urlString: self.imgs[i+1]) == false
                {
                    if i + 2 < imgs.count
                    {
                        let url = URL(string: self.imgs[i+2])! // i = 1
                        self.Picture.kf.setImage(with: url)
                        i = i + 1
                    }
                    else
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            self.performSegue(withIdentifier: "SendTopData", sender: nil)
                        }
                    }
                }
                else
                {
                    let url = URL(string: self.imgs[i + 1])!
                    self.Picture.kf.setImage(with: url)
                }
            }
        }
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    
    
}
