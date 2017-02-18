//
//  RestaurantViewController.swift
//  RestaurantTinder
//
//  Created by ganga sanka on 1/7/17.
//  Copyright © 2017 haasith. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps
import CoreLocation
import MessageUI


class RestaurantViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,MFMessageComposeViewControllerDelegate {
    
    var restId:String!
    var storeLat:Double!
    var storeLon:Double!
    
    var top = [Restaurant]()
    
    @IBAction func sendMessage(_ sender: Any)
    {
        
        var messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Enter a message";
        messageVC.recipients = ["Enter tel-nr"]
        messageVC.messageComposeDelegate = self;
        
        self.present(messageVC, animated: false, completion: nil)
        
    }
    
    
    
    
    
    
    
    
    
    
    var currentLat:Double!
    var currentLon:Double!
    @IBOutlet var restaurantIcon: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var storeOpenClosedLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    var nameArray = [String]()
    var commentArray = [String]()
    
    
    @IBAction func goButton(_ sender: Any) {
        
                if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemapsurl://")! as URL))
                {
                    UIApplication.shared.openURL(NSURL(string:
                        "comgooglemapsurl://?saddr=&daddr=\(storeLat!),\(storeLon!)&directionsmode=driving")! as URL)
        
                } else {
                    NSLog("Can't use comgooglemaps://");
                }
                
                }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        

        tableView.delegate = self
        tableView.dataSource = self
        print("shit")
        print(restId)
        
        
        print("me")
        print(currentLat)
        print(currentLon)
        
        print("store")
        print(storeLat)
        print(storeLon)
      
        
        doShit()
        
        
        
       // Do any additional setup after loading the view.
    }

    func doShit()
    {
        var a = 0
        
        
        Alamofire.request("https://api.foursquare.com/v2/venues/\(restId!)?client_id=FDVNPZWJ1QZ3EUMVAXHYTB2ISVV2UUD0A2H01PUGYGESXDAX&client_secret=JIHLRBPYRI2ZKHB4MBRCGL2HLDLHVTDPKDFOJFVVXIFC5BWR&v=20130815").responseJSON { response in
            if((response.result.value) != nil)
            {
                let json = JSON(response.result.value!)
                
                self.nameLabel.text = json["response"]["venue"]["name"].stringValue
                self.phoneNumberLabel.text = json["response"]["venue"]["contact"]["formattedPhone"].stringValue
                
                
                var url:String = json["response"]["venue"]["bestPhoto"]["prefix"].stringValue
                
                
                url += "150x150"
                url += json["response"]["venue"]["bestPhoto"]["suffix"].stringValue
                
                let imgUrl = URL(string: url)
                
                self.restaurantIcon.kf.setImage(with: imgUrl)
                
                
                self.priceLabel.text = json["response"]["venue"]["price"]["currency"].stringValue
                
                self.ratingLabel.text = String(json["response"]["venue"]["rating"].doubleValue)
                
                if json["response"]["venue"]["popular"]["isOpen"].boolValue == true
                {
                    self.storeOpenClosedLabel.text = "Open"
                }
                else
                {
                    self.storeOpenClosedLabel.text = "Closed"
                }
                
                
                
                while a < 6
                {
                    var name: String = json["response"]["venue"]["tips"]["groups"][0]["items"][a]["user"]["firstName"].stringValue
                    name += " "
                    name += json["response"]["venue"]["tips"]["groups"][0]["items"][a]["user"]["lastName"].stringValue
                    print("name")
                    print(name)
                    
                    self.nameArray.append(name)
                    
                    
                    print("comment")
                    var comment: String = json["response"]["venue"]["tips"]["groups"][0]["items"][a]["text"].stringValue
                    print(comment)
                    
                    self.commentArray.append(comment)
                    
                    
                    
                    
                    a = a + 1
                }
                
                
                
                
                
                
                
                
            }
            else
            {
                print("fail")
                print(response.result)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tip", for: indexPath)  as!  TipTableViewCell
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            
            
            
        cell.nameLabel.text = self.nameArray[indexPath.row]
        cell.comment.text = self.commentArray[indexPath.row]
        }
        
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if segue.identifier == "back"
        {
            if let destination = segue.destination as? TopRestaurantsController
            {
                destination.topRestaurants = top
                print("sender \(sender)")
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult)
    {
        print(result)
    }



}
