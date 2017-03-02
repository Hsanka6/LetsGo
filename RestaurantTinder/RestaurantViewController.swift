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
import QuartzCore


class RestaurantViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,MFMessageComposeViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var restId:String! = ""
    var storeLat:Double! = 0.0
    var storeLon:Double! = 0.0
    
    @IBOutlet var collectionView: UICollectionView!
    var top = [Restaurant]()
    
    @IBAction func sendMessage(_ sender: Any)
    {
        
        var messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Enter a message";
        messageVC.recipients = ["Enter tel-nr"]
        messageVC.messageComposeDelegate = self;
        
        self.present(messageVC, animated: false, completion: nil)
        
    }
    var currentLat:Double! = 0.0
    var currentLon:Double! = 0.0
    @IBOutlet var restaurantIcon: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var storeOpenClosedLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    var nameArray = [String]()
    var commentArray = [String]()
    
    @IBOutlet var milesAway: UILabel!
    
    var miles:Double! = 0.0
    var pics = [String]()
    var imageString:String = ""
    
    
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
        
        restaurantIcon.layer.masksToBounds = true
        restaurantIcon.layer.cornerRadius = 5
        
        

        tableView.delegate = self
        tableView.dataSource = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
//        print("location current")
//        print(currentLat)
//        print(currentLon)
//        
        print("store location")
        print(storeLat)
        print(storeLon)
      
        
        milesAway.text = String(miles)
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
//                self.phoneNumberLabel.text = json["response"]["venue"]["contact"]["formattedPhone"].stringValue
//                
                
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
                while a < 5
                {
                    var name: String = json["response"]["venue"]["tips"]["groups"][0]["items"][a]["user"]["firstName"].stringValue
                    name += " "
                    name += json["response"]["venue"]["tips"]["groups"][0]["items"][a]["user"]["lastName"].stringValue
                    
                    self.nameArray.append(name)
                    
                    
                    let comment: String = json["response"]["venue"]["tips"]["groups"][0]["items"][a]["text"].stringValue
                    print(comment)
                    print("a is 1")
                    print(a)
                    
                    self.commentArray.append(comment)
                    a = a + 1
                }
                
                
                
                if json["response"]["venue"]["photos"]["groups"][0]["items"].isEmpty
                {
                    print("No images found for this restaurant")
                }
                else
                {
                    var b = 0
                    while b <= 10
                    {
                        var url: String = json["response"]["venue"]["photos"]["groups"][0]["items"][b]["prefix"].stringValue
                        url += "105x105"
                        url += json["response"]["venue"]["photos"]["groups"][0]["items"][b]["suffix"].stringValue
                        b += 1
                        self.pics.append(url)
                    }
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
        
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tip", for: indexPath)  as!  TipTableViewCell
        
        
        if  indexPath.row == 5 {
            cell.nameLabel.text = ""
            cell.comment.text = ""
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if indexPath.row < 5
            {
                cell.nameLabel.text = self.nameArray[indexPath.row]
                cell.comment.text = self.commentArray[indexPath.row]
            }
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
        
        if segue.identifier == "full"
        {
            if let destination = segue.destination as? FullScreenViewController
            {
                if let imageString = sender as? String
                {
                    destination.imgUrl = imageString
                    destination.currentLat = currentLat
                    destination.currentLon = currentLon
                    destination.storeLon = storeLon
                    destination.storeLat = storeLat
                    destination.imgs = pics
                    destination.restaurantId = restId
                    destination.miles = miles
                }
                
            }
        }

    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pic", for: indexPath) as! PhotoCollectionViewCell
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            
            let imgUrl = URL(string: self.pics[indexPath.row])
            
            cell.imageView.layer.masksToBounds = true
            cell.imageView.layer.cornerRadius = 5
            
            cell.imageView.kf.setImage(with: imgUrl)
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //var imgUrl:String = ""
        imageString = pics[indexPath.row]
        performSegue(withIdentifier: "full", sender: imageString)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult)
    {
        print(result)
    }



}