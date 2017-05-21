//
//  RestaurantViewController.swift
//  RestaurantTinder
//
//  Created by Haasith sanka on 1/7/17.
//  Copyright © 2017 haasith. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps
import CoreLocation
import MessageUI
import QuartzCore
import Social
import FBSDKShareKit
import QuartzCore
import SCLAlertView
import Alamofire_Synchronous

class RestaurantViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,MFMessageComposeViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var restId:String! = ""
    var storeLat:Double! = 0.0
    var storeLon:Double! = 0.0
    var topRestaurants = [Restaurant]()
    
    
    var store1:String! = ""
    var store2:String! = ""
    var store3:String! = ""
    var store4:String! = ""
    var store5:String! = ""
    var numPics:Int! = 0
    var numRows:Int! = 0
    var storePhone:String! = ""
    var commentNum:Int = 0
    @IBOutlet var reviewLabel: UIButton!
    
    @IBOutlet var cardView: UIView!
    
    @IBOutlet var transparentView: UIView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    @IBAction func sendText(_ sender: Any)
    {
        let messageVC = MFMessageComposeViewController()
        let link = "http://foodiesapp.io"
        
        messageVC.body = "Meet me at " + restName! + "\n" + "Address:" + restAddress! + "\n" + "Try Foodies today!" + "\nDownload on " + link
        messageVC.recipients = [""]
        messageVC.messageComposeDelegate = self;
        
        self.present(messageVC, animated: false, completion: nil)
        
    }
    
    @IBAction func callButton(_ sender: Any)
    {
        if self.storePhone != ""
        {
            self.callNumber(phoneNumber: self.storePhone)
        }
        else
        {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "Avenir", size: 20)!,
                kTextFont: UIFont(name: "Avenir", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: true)
            
            let alert = SCLAlertView(appearance: appearance)
            alert.showError("Error", subTitle: "Calling Restaurant failed. Please Try Again")
            
        }
        
    }
    
    @IBAction func shareButton(_ sender: Any)
    {
        //        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)
        //        {
        //            let fbshare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        //            fbshare.setInitialText("share on facebook")
        //            self.present(fbshare,animated:true, completion:nil)
        //
        //        }
        //        else
        //        {
        //            print("faield")
        //        }
        let message = "Download Lets Go on the App store now!\n"
        let image = UIImage(named: "finalLogo")
        let link = "https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=1219918851&mt=8"
        let activityVC = UIActivityViewController(activityItems: [image as Any!,message,link], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBOutlet var Button: UIButton!
    
    var currentLat:Double! = 0.0
    var currentLon:Double! = 0.0
    @IBOutlet var restaurantIcon: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    var nameArray = [String]()
    var commentArray = [String]()
    
    @IBOutlet var milesAway: UILabel!
    
    var miles:Double! = 0.0
    var pics = [String]()
    var imageString:String = ""
    var restName:String! = ""
    var restAddress:String! = ""
    
    
    @IBAction func goButton(_ sender: Any)
    {
        
        let googleMapsInstalled = UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
        
        
        if googleMapsInstalled
        {
            UIApplication.shared.openURL(NSURL(string:"comgooglemapsurl://?saddr=&daddr=\(storeLat!),\(storeLon!)&directionsmode=driving")! as URL)
            
            
        }
        else
        {
            UIApplication.shared.openURL(NSURL(string:"http://maps.apple.com/?saddr=&daddr=\(storeLat!),\(storeLon!)")! as URL)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        reviewLabel.isEnabled = false
        reviewLabel.updateLayerProperties()
        
        ratingLabel.layer.masksToBounds = true
        ratingLabel.layer.cornerRadius = 5
        
        restaurantIcon.layer.masksToBounds = true
        restaurantIcon.layer.cornerRadius = 5
        
        Button.updateLayerProperties()
        Button.isEnabled = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        cardView.layer.masksToBounds = true
        cardView.layer.cornerRadius = 5
        
        print("location current")
        print(currentLat)
        print(currentLon)
        
        print("store location")
        print(storeLat)
        print(storeLon)
        
        print("milesss")
        print(miles)
        milesAway.text = String(format: "%.1f", miles) + " MI"
        doShit()
        
        let transparent = UIColor(colorLiteralRed: 0/255, green: 0/255, blue: 0/255, alpha: 0.2)
        
        let gradient = CAGradientLayer()
        gradient.frame = transparentView.bounds
        gradient.colors = [transparent, UIColor.white.cgColor]
        
        transparentView.layer.addSublayer(gradient)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    private func callNumber(phoneNumber:String)
    {
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)")
        {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL))
            {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    
    
    func doShit()
    {
        var a = 0
        print("id")
        print(restId)
        Alamofire.request("https://api.foursquare.com/v2/venues/\(restId!)?client_id=FDVNPZWJ1QZ3EUMVAXHYTB2ISVV2UUD0A2H01PUGYGESXDAX&client_secret=JIHLRBPYRI2ZKHB4MBRCGL2HLDLHVTDPKDFOJFVVXIFC5BWR&v=20130815").responseJSON { response in
            if((response.result.value) != nil)
            {
                let json = JSON(response.result.value!)
                
                self.nameLabel.text = json["response"]["venue"]["name"].stringValue
                self.storePhone = json["response"]["venue"]["contact"]["phone"].stringValue
                
                self.restName = json["response"]["venue"]["name"].stringValue
                
                var url:String = json["response"]["venue"]["bestPhoto"]["prefix"].stringValue
                
                
                url += "150x150"
                url += json["response"]["venue"]["bestPhoto"]["suffix"].stringValue
                
                let imgUrl = URL(string: url)
                
                print("this is adreess")
                print(json["response"]["venue"]["location"]["formattedAddress"][0].stringValue)
                self.restAddress = json["response"]["venue"]["location"]["formattedAddress"][0].stringValue
                
                self.restaurantIcon.kf.setImage(with: imgUrl)
                
                
                self.priceLabel.text = json["response"]["venue"]["price"]["currency"].stringValue
                
                self.ratingLabel.text = String(json["response"]["venue"]["rating"].doubleValue)
                
                let blue1 = self.hexStringToUIColor(hex: "#1982FF")
                let yellow = self.hexStringToUIColor(hex: "#FF8A00")
                let red = self.hexStringToUIColor(hex: "#FF165E")
                
                if json["response"]["venue"]["rating"].doubleValue >= 0 && json["response"]["venue"]["rating"].doubleValue < 4
                {
                    self.ratingLabel.backgroundColor = red
                }
                else if json["response"]["venue"]["rating"].doubleValue >= 4 && json["response"]["venue"]["rating"].doubleValue < 7
                {
                    self.ratingLabel.backgroundColor = yellow
                }
                else
                {
                    self.ratingLabel.backgroundColor = blue1
                }
                
                
                
                
                
                
                //                if json["response"]["venue"]["popular"]["isOpen"].boolValue == true
                //                {
                //                    self.storeOpenClosedLabel.text = "Open"
                //                }
                //                else
                //                {
                //                    self.storeOpenClosedLabel.text = "Closed"
                //                }
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
                        if url.isEmpty
                        {
                            self.pics.append("NULL")
                            
                        }
                        else
                        {
                            self.pics.append(url)
                            
                        }
                        self.collectionView.reloadData()
                        
                        
                        b += 1
                        
                    }
                    self.numPics = self.pics.count
                    self.collectionView.reloadData()
                    
                    
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5)
        {
            if indexPath.row < self.nameArray.count && self.nameArray.count > 0
            {
                cell.nameLabel.text = self.nameArray[indexPath.row]
                
                cell.comment.text = self.commentArray[indexPath.row]
            }
            else
            {
                cell.nameLabel.text = ""
                
                cell.comment.text = ""
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
                destination.topRestaurants = topRestaurants
                destination.storeId1 = store1
                destination.storeId2 = store2
                destination.storeId3 = store3
                destination.storeId4 = store4
                destination.storeId5 = store5
                destination.numRows = numRows
                destination.currentLat = currentLat
                destination.currentLon = currentLon
                
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
                    destination.numRows = numRows
                    destination.topRestaurants = topRestaurants
                    
                    
                }
                
            }
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return numPics
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
        
        
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
        
    }
    
    
    
    
    
}

extension UIButton
{
    func updateLayerProperties() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 10.0
        self.layer.masksToBounds = false
    }
}


