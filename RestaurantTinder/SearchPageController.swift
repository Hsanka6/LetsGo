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


class SearchPageController: UIViewController,CLLocationManagerDelegate {
    var someLabel = UILabel()
    var timer = Timer()
    var lat:Double!
    var lon:Double!
    var searchQuery:String!
    var foodArray = ["Pizza", "Chinese food", "Soup", "Mexican", "Burger","indian", "Italian","tacos"]
    var pics = [String]()
    var restaurants = [String]()
    @IBOutlet var searchBar: SkyFloatingLabelTextField!
    @IBOutlet var indicator: UIActivityIndicatorView!
    func checkSearchBar()
    {
        
        if searchBar.text?.isEmpty == true
        {
            searchRestaurantsButton.setTitle("Surprise Me!", for: .normal)
            
        }
        else
        {
            searchRestaurantsButton.setTitle("GO!", for: .normal)
        }
        
    }
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkSearchBar), userInfo: nil, repeats: true)
    }
    @IBOutlet var searchRestaurantsButton: UIButton!
    
    @IBAction func searchRestaurantsButton(_ sender: Any) {
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
            
            var userSearchReference = FIRDatabase.database().reference().child("users").child(uid).child("searches").childByAutoId()
            
            
            userSearchReference.setValue(values)
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
            Alamofire.request("https://api.foursquare.com/v2/venues/search?client_id=FDVNPZWJ1QZ3EUMVAXHYTB2ISVV2UUD0A2H01PUGYGESXDAX&client_secret=JIHLRBPYRI2ZKHB4MBRCGL2HLDLHVTDPKDFOJFVVXIFC5BWR&v=20130815&ll=\(self.lat!),\(self.lon!)&query=\(newString)&limit=5&radius=10000").responseJSON { response in
                if((response.result.value) != nil)
                {
                    let json = JSON(response.result.value!)
                    for (_,subJson):(String, JSON) in json["response"]["venues"]
                    {
                        var storeNum:Int = 0
                        let id: String = subJson["id"].stringValue
                        print(id)
                        print(subJson["name"].stringValue)
                        Alamofire.request("https://api.foursquare.com/v2/venues/\(id)/photos?client_id=FDVNPZWJ1QZ3EUMVAXHYTB2ISVV2UUD0A2H01PUGYGESXDAX&client_secret=JIHLRBPYRI2ZKHB4MBRCGL2HLDLHVTDPKDFOJFVVXIFC5BWR&v=20130815&limit=4").responseJSON { response in
                            
                            var secondJSON:JSON!
                            if((response.result.value) != nil) {
                                secondJSON = JSON(response.result.value!)
                            }
                            for (_,subJson):(String, JSON) in secondJSON["response"]["photos"]["items"]
                            {
                                var url: String = subJson["prefix"].stringValue
                                
                                url += "250x250"
                                url += subJson["suffix"].stringValue
                                self.pics.append(url)
                                
                            }
                            self.pics.append(id)
                            self.restaurants.append(id)
                        }
                    }
                }
        }
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 2)
            {
                self.indicator.stopAnimating()
                self.performSegue(withIdentifier: "swipe", sender: self.pics)
                
            
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
        scheduledTimerWithTimeInterval()
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
        searchQuery = searchBar.text
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        lat = locValue.latitude as Double!
        lon = locValue.longitude as Double!
        
        
    }
   
}
extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
