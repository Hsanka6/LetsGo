//
//  SearchPageController.swift
//  RestaurantTinder
//
//  Created by ganga sanka on 12/29/16.
//  Copyright © 2016 haasith. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import FirebaseDatabase
import Firebase
import SkyFloatingLabelTextField
import FontAwesome_swift
import FBSDKLoginKit


class SearchPageController: UIViewController,CLLocationManagerDelegate {
    var someLabel = UILabel()
    var timer = Timer()
    var lat:Double!
    var lon:Double!
    var searchQuery:String!
    var foodArray = ["Pizza", "Chinese food", "Soup", "Mexican", "Burger","indian", "Italian","tacos"]
    var pics = [String]()
    var restaurants = [String]()
    @IBOutlet var searchBar: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var searchImage: UIImageView!
    @IBOutlet var Miles: UILabel!
    @IBOutlet var someView: UIView!
    @IBOutlet var MilesSlider: UISlider!
    var meters:Int = 8045
    var token:String = ""
    
    
    func checkSearchBar()
    {
        let image = UIImage(named: "goButton") as UIImage?
        let image1 = UIImage(named: "SurpriseMeButton") as UIImage?
        
        //Changes pic for button depending on the search text field
        if searchBar.text?.isEmpty == true
        {
            searchRestaurantsButton.setImage(image1, for: .normal)
            
        }
        else
        {
            searchRestaurantsButton.setImage(image, for: .normal)
        }
        
    }
    
    @IBAction func ValueChanged(_ sender: Any)
    {
        let sliderValue = Int(MilesSlider.value)
        Miles.text = "\(sliderValue)" + " mi"
        meters = getMeters(miles: sliderValue)
    }
    
    

    @IBOutlet var searchRestaurantsButton: UIButton!
    
    @IBAction func searchRestaurantsButton(_ sender: Any) {
        //start animator
        indicator.isHidden = false
        indicator.startAnimating()
        
        searchQuery = searchBar.text
        if searchBar.text?.isEmpty == true
        {
            searchBar.text = foodArray.randomItem()
            print(searchBar.text!)
            searchQuery = searchBar.text
        }
        let newString = searchQuery.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        
        
        //Upload each search to database
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
            print("uid coming up")
            print(uid)
            let values = ["query": searchQuery!, "lat": lat!, "lon": lon!] as [String : Any]
        
        let userSearchReference = FIRDatabase.database().reference().child("users").child(uid).child("searches")
        userSearchReference.childByAutoId().setValue(values)
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                let name = (value?["name"] as? String)!
                print("name",(name))
                
                let totalValues = ["query": self.searchQuery!, "lat": self.lat!, "lon": self.lon!, "name":name] as [String : Any]
                let totalSearchReference = FIRDatabase.database().reference().child("total-searches")
                totalSearchReference.childByAutoId().setValue(totalValues)
                
            })
        { (error) in
                print(error.localizedDescription)
        }
        
        
        
        Alamofire.request("https://api.foursquare.com/v2/venues/search?client_id=FDVNPZWJ1QZ3EUMVAXHYTB2ISVV2UUD0A2H01PUGYGESXDAX&client_secret=JIHLRBPYRI2ZKHB4MBRCGL2HLDLHVTDPKDFOJFVVXIFC5BWR&v=20130815&ll=\(self.lat!),\(self.lon!)&query=\(newString)&limit=5&radius=\(meters)").responseJSON { response in
                if((response.result.value) != nil)
                {
                    let json = JSON(response.result.value!)
                    
                    if json["response"]["venues"].isEmpty
                    {
                        let a = UIAlertView()
                        a.message = "No Restaurants found"
                        a.title = "Alert"
                        a.addButton(withTitle: "ok")
                        a.show()
                    }
                    else
                    {
                        for (_,subJson):(String, JSON) in json["response"]["venues"]
                        {
                            let id: String = subJson["id"].stringValue
                            print(id)
                            print(subJson["name"].stringValue)
                            Alamofire.request("https://api.foursquare.com/v2/venues/\(id)/photos?client_id=FDVNPZWJ1QZ3EUMVAXHYTB2ISVV2UUD0A2H01PUGYGESXDAX&client_secret=JIHLRBPYRI2ZKHB4MBRCGL2HLDLHVTDPKDFOJFVVXIFC5BWR&v=20130815&limit=3").responseJSON { response in
                                var secondJSON:JSON!
                                if((response.result.value) != nil)
                                {
                                    secondJSON = JSON(response.result.value!)
                                    if secondJSON["response"]["photos"]["items"].isEmpty
                                    {
                                        print("No images found for this restaurant")
                                    }
                                    else
                                    {
                                        for (_,subJson):(String, JSON) in secondJSON["response"]["photos"]["items"]
                                        {
                                            var url: String = subJson["prefix"].stringValue
                                            url += "250x250"
                                            url += subJson["suffix"].stringValue
                                            self.pics.append(url)
                                         }
                                        self.pics.append(id)
                                        self.restaurants.append(id)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2)
                                        {
                                            self.indicator.stopAnimating()
                                            self.performSegue(withIdentifier: "swipe", sender: self.pics)
                                        }
                                    }
                                }
                                else
                                {
                                    let a = UIAlertView()
                                    a.message = "Failed"
                                    a.title = "Alert"
                                    a.addButton(withTitle: "ok")
                                    a.show()
                                    self.indicator.stopAnimating()
                                }
                            }
                        }
                    }
                }
            else
            {
                print("failed")
            }
        }
    }
    var locationManager: CLLocationManager!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "swipe"
        {
            if let destination = segue.destination as? SwipeViewController
            {
                destination.imgs = pics
                destination.restaurant = restaurants
                destination.currentLat = lat
                destination.currentLon = lon
                
                print("sender \(sender)")
            }
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        
        
        let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:300, position:searchImage.center)
        view.layer.insertSublayer(pulseEffect, below: searchImage.layer)
        pulseEffect.animationDuration = 5
        pulseEffect.pulseInterval = 0.5
        
        let pulse = LFTPulseAnimation(repeatCount: Float.infinity, radius:50, position:Miles.center)
        pulse.animationDuration = 5
        pulse.pulseInterval = 0.5
        
        
        indicator.isHidden = true
        
      
        
        
        
        
        //LOCATION CRAP
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        searchBar.iconFont = UIFont.fontAwesome(ofSize: 15)
        searchBar.iconText = String.fontAwesomeIcon(name: .cutlery)

        searchQuery = searchBar.text
        
      
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        lat = locValue.latitude as Double!
        lon = locValue.longitude as Double!
        
        
    }
    
    func getMeters(miles: Int) -> Int
    {
        var meters:Int = 0
        meters = miles * 1609
        return meters
    }
  
  
   
}
extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
