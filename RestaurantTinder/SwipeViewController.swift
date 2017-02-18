//
//  SwipeViewController.swift
//  RestaurantTinder
//
//  Created by ganga sanka on 12/29/16.
//  Copyright © 2016 haasith. All rights reserved.
//
import UIKit
import Kingfisher
import QuartzCore

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
    
    
    
    
    @IBAction func Back(_ sender: Any)
    {
        
        
        self.performSegue(withIdentifier: "clear", sender: self.imgs)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "clear"
        {
            if let destination = segue.destination as? SearchPageController
            {
                destination.pics = []
                print("sender \(sender)")
            }
        }
        else if segue.identifier == "SendTopData"
        {
            if let destination = segue.destination as? TopRestaurantsController
            {
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
                destination.yesNo = yesNoArray
                
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
        //text.text = "Swipe Right to like food and left to reject"
        
        
        
        background.layer.masksToBounds = false
        
        background.layer.shadowColor = UIColor.black.cgColor
        //background.layer.shadowRadius = 5;
        background.layer.shadowOpacity = 1.5;
        background.layer.shadowOffset = CGSize.zero
        
        
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
        Picture.addGestureRecognizer(gesture)
        
        Picture.isUserInteractionEnabled = true
        
        
        
        
        if restaurant[0] != "" && restaurant.count > 0
        {
            print("rest")
            print(restaurant[0])
            store1 = restaurant[0]
        }
        else
        {
            store1 = "NULL"
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
        
        
        print(store1 + "  " + store2 + "  " + store3 + "  " + store4 + "  " + store5 + "  ")
        
        print("imgs")
        print(imgs)
        
        if(imgs.count == 0)
        {
            let alert = UIAlertView()
            alert.message = "Failed to find restaurants for your search"
            alert.title = "Search Error"
            alert.addButton(withTitle: "OK")
            alert.show()
        }
        else
        {
            let ur = URL(string: imgs[0])
            self.Picture.kf.setImage(with: ur)
            
        }
        
        
        
    }
    
    
    func wasDragged(gesture: UIPanGestureRecognizer)
    {
        
        let translation = gesture.translation(in: self.view)
        let label = gesture.view!
        
        label.center = CGPoint(x: self.view.bounds.width/2 + translation.x , y: self.view.bounds.height/2 + translation.y)
        
        let xFromCenter = label.center.x - self.view.bounds.width/2
        
        let scale = min(100/abs(xFromCenter),1)
        
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter/200)
        
        var stretch = rotation.scaledBy(x: scale,y: scale)
        
        label.transform = stretch
        if gesture.state == UIGestureRecognizerState.ended
        {
            if self.i == 0
            {
                print("first condition")
                
                
                if gesture.state == UIGestureRecognizerState.ended
                {
                    if label.center.x < 100
                    {
                        print("sec condition")
                        
                        self.yesNoArray[i] = "NO"
                        let url = URL(string: self.imgs[i + 1])!
                        self.Picture.kf.setImage(with: url)
                        
                        i = i + 1
                        
                        
                        
                        
                    }
                    else if label.center.x > self.view.bounds.width - 100
                    {
                        print("third condition")
                        
                        self.yesNoArray[i] = "YES"
                        
                        if  verifyUrl(urlString:self.imgs[i + 1] ) == true
                        {
                            let url = URL(string: self.imgs[i + 1])!
                            self.Picture.kf.setImage(with: url)
                            i = i + 1
                        }
                        else
                        {
                            let url = URL(string: self.imgs[i + 2])!
                            self.Picture.kf.setImage(with: url)
                            i = i + 2
                            
                        }
                        
                    }
                }
                
                
                
            }
            else if label.center.x < 100
            {
                print("not chosen")
                if i < imgs.count
                {
                    
                    let url = URL(string: self.imgs[i + 1])!
                    self.Picture.kf.setImage(with: url)
                    yesNoArray[i] = "NO"
                    
                    i = i + 1
                    if self.imgs[i] == store1 || self.imgs[i] == store2  || self.imgs[i] == store3  || self.imgs[i] == store4  || self.imgs[i] == store5
                    {
                        if i+1 < imgs.count && self.imgs[i+1] != store1 && self.imgs[i+1] != store2  && self.imgs[i+1] != store3  && self.imgs[i+1] != store4  && self.imgs[i+1] != store5
                        {
                            let url = URL(string: self.imgs[i+1])!
                            self.Picture.kf.setImage(with: url)
                            i = i + 1
                            print("ik")
                            
                        }
                        else if i + 1 < imgs.count  && (self.imgs[i+1] != store1 || self.imgs[i+1] != store2  || self.imgs[i+1] != store3  || self.imgs[i+1] != store4  || self.imgs[i+1] != store5)
                        {
                            
                            print("jk")
                            let url = URL(string: self.imgs[i+2])!
                            self.Picture.kf.setImage(with: url)
                            i = i + 2
                        }
                        else
                        {
                            
                            print("IM")
                            let a = UIAlertView()
                            a.message = "Done Swiping Images!"
                            a.title = "Alert"
                            a.addButton(withTitle: "ok")
                            
                            a.show()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                
                                self.performSegue(withIdentifier: "SendTopData", sender: self)
                            }
                        }
                        
                        
                        
                        
                    }
                    
                    
                }
                else
                {
                    print("IAMM")
                    let a = UIAlertView()
                    a.message = "No Images found"
                    a.title = "Alert"
                    a.addButton(withTitle: "ok")
                    a.show()
                    self.performSegue(withIdentifier: "SendTopData", sender: self)
                    
                    
                }
                
                
                
            }
            else if label.center.x > self.view.bounds.width - 100
            {
                print("chosen")
                if i < imgs.count
                {
                    let url = URL(string: self.imgs[i + 1])!
                    self.Picture.kf.setImage(with: url)
                    yesNoArray[i] = "YES"
                    
                    i = i + 1
                    if self.imgs[i] == store1 || self.imgs[i] == store2  || self.imgs[i] == store3  || self.imgs[i] == store4  || self.imgs[i] == store5
                    {
                        
                        if i+1 < imgs.count && self.imgs[i+1] != store1 && self.imgs[i+1] != store2  && self.imgs[i+1] != store3  && self.imgs[i+1] != store4  && self.imgs[i+1] != store5
                        {
                            let url = URL(string: self.imgs[i+1])!
                            self.Picture.kf.setImage(with: url)
                            i = i + 1
                            print("ik")
                            
                        }
                        else if i + 1 < imgs.count  && (self.imgs[i+1] != store1 || self.imgs[i+1] != store2  || self.imgs[i+1] != store3  || self.imgs[i+1] != store4  || self.imgs[i+1] != store5) && i + 2 < imgs.count
                        {
                            
                            print("jk")
                            
                            if verifyUrl(urlString: self.imgs[i+2])  == true
                            {
                                let url = URL(string: self.imgs[i+2])!
                                self.Picture.kf.setImage(with: url)
                                i = i + 2
                            }
                            else
                            {
                                let url = URL(string: self.imgs[i+3])!
                                self.Picture.kf.setImage(with: url)
                                i = i + 3
                                
                                
                            }
                        }
                        else
                        {
                            
                            let a = UIAlertView()
                            a.message = "Done Swiping Images!"
                            a.title = "Alert"
                            a.addButton(withTitle: "ok")
                            a.show()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                
                                self.performSegue(withIdentifier: "SendTopData", sender: self)
                            }
                            
                        }
                        
                        
                        //i = i + 1
                        
                        
                    }
                    
                    
                }
                else
                {
                    let a = UIAlertView()
                    a.message = "No Images found"
                    a.title = "Alert"
                    a.addButton(withTitle: "ok")
                    
                    a.show()
                    self.performSegue(withIdentifier: "SendTopData", sender: self)
                    
                    
                }
                
            }
            
            
            
            
            
            rotation = CGAffineTransform(rotationAngle: 0)
            
            stretch = rotation.scaledBy(x: 1,y: 1)
            
            label.transform = stretch
            
            label.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
            
            print("SO FAR")
            print(yesNoArray)
            
            
            
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
