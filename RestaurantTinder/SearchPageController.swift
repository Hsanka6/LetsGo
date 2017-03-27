//
//  SearchPageController.swift
//  RestaurantTinder
//
//  Created by Haasith sanka on 12/29/16.
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
import SCLAlertView
import NVActivityIndicatorView
import ImageSlideshow
import Alamofire_Synchronous


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
    @IBOutlet var searchImage: UIImageView!
    @IBOutlet var Miles: UILabel!
    @IBOutlet var someView: UIView!
    @IBOutlet var MilesSlider: UISlider!
    var meters:Int = 8045
    var ref: FIRDatabaseReference!
    var noRestBool:Bool! = false
    var ids = [String]()
    var finalIds = [String]()
    var rowNum:Int! = 0
    var alreadyError:Bool = false
    var activeField: UITextField?

    
    
    
    @IBOutlet var indicator: NVActivityIndicatorView!
    var randomIds = [String]()
    
    
    @IBOutlet var slideShow: ImageSlideshow!
    
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
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function **Countdown** with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkSearchBar), userInfo: nil, repeats: true)
    }
    
    @IBAction func ValueChanged(_ sender: Any)
    {
        let sliderValue = Int(MilesSlider.value)
        Miles.text = "\(sliderValue)" + " mi"
        meters = getMeters(miles: sliderValue)
    }
    
    

    @IBOutlet var searchRestaurantsButton: UIButton!
    
    @IBAction func searchRestaurantsButton(_ sender: Any)
    {
        self.view.bringSubview(toFront: indicator)
        self.searchRestaurantsButton.isEnabled = false
        
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
        
        
        
        //                                    else if secondJSON["venue"]["response"]["venue"]["popular"]["isOpen"].boolValue == false
        //                                    {
        //                                        print("This restaurant is Closed")
        //                                        print(secondJSON["response"]["venue"]["popular"]["isOpen"])
        //
        //                                    }
        
        let request:String! = "https://api.foursquare.com/v2/venues/search?client_id=FDVNPZWJ1QZ3EUMVAXHYTB2ISVV2UUD0A2H01PUGYGESXDAX&client_secret=JIHLRBPYRI2ZKHB4MBRCGL2HLDLHVTDPKDFOJFVVXIFC5BWR&v=20130815&ll=\(self.lat!),\(self.lon!)&query=\(newString)&limit=40&radius=\(meters)"
        
        
        
        makeRequest(request)
        
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "Avenir", size: 20)!,
                kTextFont: UIFont(name: "Avenir", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: true)
            
            if self.noRestBool == true
            {
                
                print("error")
                
                let alert = SCLAlertView(appearance: appearance)
                alert.showError("Error", subTitle: "No Restaurants were found.3")
                self.indicator.stopAnimating()
                self.searchBar.text = ""
                self.alreadyError = true
                self.searchRestaurantsButton.isEnabled = true
                
                
            }
        
        if noRestBool == false
        {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2)
        {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "Avenir", size: 20)!,
                kTextFont: UIFont(name: "Avenir", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: true)
            
            print("initially getting ids")
            print(self.ids)
            print(self.ids.count)
            if self.ids.count <= 5
            {
                self.rowNum = self.ids.count
                print("here yo")
                for id in self.ids
                {
                    print("getting pics")
                    self.getPhotos(picsForIds: id)
                }
                    print("checking")
                    print(self.pics)
                    if self.pics.count > 0
                    {
                        print("success")
                        print(self.restaurants.count)
                        self.indicator.stopAnimating()
                        self.performSegue(withIdentifier: "swipe", sender: self.pics)
                    }
                    else if self.alreadyError == true
                    {
                        print("found no pics")
                        self.searchBar.text = ""
                        let alert = SCLAlertView(appearance: appearance)
                        alert.showError("Error", subTitle: "No Restaurants were found. Please widen your search")
                        self.indicator.stopAnimating()
                        self.searchRestaurantsButton.isEnabled = true
                        
                    }
                    else
                    {
                        self.searchBar.text = ""
                        let alert = SCLAlertView(appearance: appearance)
                        alert.showError("Error", subTitle: "Please try again")
                        self.indicator.stopAnimating()
                        self.searchRestaurantsButton.isEnabled = true
                        
                    }
                
            }
            else
            {
                self.rowNum = 5
                
                var newIds = [String]()
                var randNum = [Int]()
                print("making random nums")
                
                randNum = self.getRandomNums(int: self.ids.count)
                var f = 0
                while(f < randNum.count)
                {
                    print(randNum[f])
                    let getInt:Int! = randNum[f]
                    
                    newIds.append(self.ids[getInt])
                    print("f is ")
                    print(f)
                    f += 1
                }
                print("getting photos")
                for id in newIds
                {
                    self.getPhotos(picsForIds: id)
                }
                
                print("checking")
                print(self.pics)
                if self.pics.count > 0
                {
                    print("success")
                    self.indicator.stopAnimating()
                    self.performSegue(withIdentifier: "swipe", sender: self.pics)
                    
                }
                else if self.alreadyError == true
                {
                    print("found no pics")
                    self.searchBar.text = ""
                    self.searchRestaurantsButton.isEnabled = true
                    let alert = SCLAlertView(appearance: appearance)
                    alert.showError("Error", subTitle: "No Restaurants were found. Please widen your search")
                    self.indicator.stopAnimating()
                }
                else
                {
                    self.searchBar.text = ""
                    self.searchRestaurantsButton.isEnabled = true
                    let alert = SCLAlertView(appearance: appearance)
                    alert.showError("Error", subTitle: "Please try again")
                    self.indicator.stopAnimating()
                }
                
            }
        }
        }
    
    }
    var locationManager: CLLocationManager!
    
    
    func getPhotos(picsForIds:String)
    {
        let response = Alamofire.request("https://api.foursquare.com/v2/venues/\(picsForIds)/photos?client_id=FDVNPZWJ1QZ3EUMVAXHYTB2ISVV2UUD0A2H01PUGYGESXDAX&client_secret=JIHLRBPYRI2ZKHB4MBRCGL2HLDLHVTDPKDFOJFVVXIFC5BWR&v=20130815&limit=3", parameters:nil).responseJSON()
                if((response.result.value) != nil)
                {
                    var secondJSON:JSON!
                    secondJSON = JSON(response.result.value!)
                    for (_,subJson):(String, JSON) in secondJSON["response"]["photos"]["items"]
                    {
                        var url: String = subJson["prefix"].stringValue
                        url += "300x300"
                        url += subJson["suffix"].stringValue
                        self.pics.append(url)
                        print("adding urls")
                    }
                    self.pics.append(picsForIds)
                    self.restaurants.append(picsForIds)
                    print("done adding urls")
                }
                else
                {
                    
                }
    }
    
    
    
    
    
    func makeRequest(_ url:String)
    {
        
        let response = Alamofire.request(url, parameters:nil).responseJSON()
            if response.result.value != nil
            {
                let json = JSON(response.result.value!)
                if json["response"]["venues"].isEmpty
                {
                    self.noRestBool = true
                    print("why here")
                }
                else
                {
                    for(_,venueJSON):(String,JSON) in json["response"]["venues"]
                    {
                        let id: String = venueJSON["id"].stringValue
                        
                        Alamofire.request("https://api.foursquare.com/v2/venues/\(id)?client_id=FDVNPZWJ1QZ3EUMVAXHYTB2ISVV2UUD0A2H01PUGYGESXDAX&client_secret=JIHLRBPYRI2ZKHB4MBRCGL2HLDLHVTDPKDFOJFVVXIFC5BWR&v=20130815").responseJSON
                        { responseJSON in
                            switch responseJSON.result
                            {
                            case .success:
                                var checker:JSON!
                                checker = JSON(responseJSON.result.value!)
                                if checker["response"]["venue"]["photos"]["count"].intValue >= 3
                                {
                                    print("this will be added")
                                    self.ids.append(id)
                                }
                            case .failure:
                                print("there is an error with internet")
                                
                            }
                        }
                    }
                }
        }
    }

    

    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "swipe"
        {
            if let destination = segue.destination as? SwipeViewController
            {
                destination.imgs = pics
                destination.restaurant = restaurants
                destination.currentLat = lat
                destination.currentLon = lon
                destination.numRows = rowNum
                
            }
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        
        self.hideKeyboardWhenTappedAround()
        ref = FIRDatabase.database().reference().child("total-searches")
        scheduledTimerWithTimeInterval()

        
        
        
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
        
        searchRestaurantsButton.setImage(UIImage(named:"SurpriseMeButton"), for: .normal)
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        
        slideShow.setImageInputs([
            ImageSource(image: UIImage(named: "burger")!),
            ImageSource(image: UIImage(named: "pizza")!), ImageSource(image: UIImage(named: "coffee")!), ImageSource(image: UIImage(named: "noodles")!), ImageSource(image: UIImage(named: "chickenWings")!)])
        slideShow.pageControl.currentPageIndicatorTintColor = UIColor.white
        slideShow.pageControl.pageIndicatorTintColor = UIColor.black
        slideShow.contentScaleMode = UIViewContentMode.scaleAspectFill
        
        
        
        

    }
    var randomized = [Int]()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func getRandomNums(int:Int) -> [Int]
    {
        
        var intArray = [Int]()
        var z = 0
        while(z < int)
        {
            intArray.append(z)
            z += 1
        }
        
        let some = intArray
        //var c = 0
        
        while (randomized.count < 5 )
        {
            let someInt = some.randomItem()
            print(someInt)
            if randomized.count == 5
            {
                print("yay done")
            }
            else if checker(int: someInt) == 1
            {
                print("got false")
            }
            else if checker(int: someInt) == 2
            {
                self.randomized.append(someInt)

            }
        }
        print("done with getting randomized array")
        print(randomized)
        return randomized
    }
    
    func checker(int: Int) -> Int
    {
        var g = 0
        while g <= 5
        {
            if randomized.contains(int)
            {
                randomized.remove(at: g)
                g += 1
                return 1
            }
            else
            {
                g += 1
                return 2
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        lat = locValue.latitude as Double!
        lon = locValue.longitude as Double!
        
        
    }
    
    //View moves up when keyboard is shown
    func keyboardWillShow(sender: NSNotification)
    {
        slideShow.isHidden = true
        self.view.frame.origin.y -= 100
    }
    
    //View moves down when keyboard is hiding
    func keyboardWillHide(sender: NSNotification) {
        slideShow.isHidden = false
        self.view.frame.origin.y += 100
        
    }
    
    func getMeters(miles: Int) -> Int
    {
        var meters:Int = 0
        meters = miles * 1609
        return meters
    }
//    
//    func registerForKeyboardNotifications(){
//        //Adding notifies on keyboard appearing
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//    }
//    
//    func deregisterFromKeyboardNotifications(){
//        //Removing notifies on keyboard appearing
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//    }
//    
//    func keyboardWasShown(notification: NSNotification){
//        //Need to calculate keyboard exact size due to Apple suggestions
//        var info = notification.userInfo!
//        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
//        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
//        
//        
//        var aRect : CGRect = self.view.frame
//        aRect.size.height -= keyboardSize!.height
//        if let activeField = self.activeField {
//            if (!aRect.contains(activeField.frame.origin)){
//            }
//        }
//    }
//    
//    func keyboardWillBeHidden(notification: NSNotification){
//        //Once keyboard disappears, restore original positions
//        var info = notification.userInfo!
//        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
//        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
//        self.view.endEditing(true)
//        
//    }
//    
//    func textFieldDidBeginEditing(_ textField: UITextField){
//        activeField = textField
//    }
//    
//    func textFieldDidEndEditing(_ textField: UITextField){
//        activeField = nil
//    }
    
    
   
}
extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
