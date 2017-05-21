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
import FirebaseAuth
import SkyFloatingLabelTextField
import FontAwesome_swift
import FBSDKLoginKit
import SCLAlertView
import Social
import NVActivityIndicatorView
import ImageSlideshow
import Alamofire_Synchronous
import PopupDialog
import QuartzCore
import KeychainSwift


class SearchPageController: UIViewController,CLLocationManagerDelegate, UITextFieldDelegate {
    var someLabel = UILabel()
    var timer = Timer()
    var lat:Double!
    var lon:Double!
    //var locationManager: CLLocationManager!
    var searchQuery:String!
    var foodArray = ["Pizza", "Chinese", "Soup", "Mexican", "Burger","Indian", "Italian","Tacos","Desert", "Pasta","Noodles"]
    var pics = [String]()
    
    var restaurants = [String]()
    @IBOutlet var searchBar: SkyFloatingLabelTextFieldWithIcon!
    @IBOutlet var searchImage: UIImageView!
    @IBOutlet var Miles: UILabel!
    @IBOutlet var someView: UIView!
    @IBOutlet var MilesSlider: UISlider!
    var meters:Int = 8045
    var ref: FIRDatabaseReference!
    var ref2: FIRDatabaseReference!
    var noRestBool:Bool! = false
    var ids = [String]()
    var finalIds = [String] ()
    var rowNum:Int! = 0
    var alreadyError:Bool = false
    var activeField: UITextField?
    var locationBool: Bool = false
    var userExistsBool: Bool = false
    var keyBoardHeight:CGRect!
    var checkImg:Bool = false
    var requestDone = false
    
    var onlineCheck = false
    
    var coupon = false
    
    
    var googleAPIKey = "AIzaSyASRZ7-pV8qiCohTZhbTdthrHwthtmGQ_I"
    var picCounter = 0
    
    
    var imgs = [UIImage]()
    var foodBools = [Bool]()
    let session = URLSession.shared
    
    var label:String! = ""
    var imageBOOL:Bool! = false
    
    
    var uid: String! = ""
    
    var couponRedeemed:Bool! = false
    
    @IBOutlet var logoutButton: UIButton!
    var dialogAppearance = PopupDialogDefaultView.appearance()

    
    var checkCoupon = false
    
    
    @IBAction func redeemButton(_ sender: Any)
    {
        
        self.checkCouponRedeemed()
        
        // Prepare the popup assets
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            print("coupona is \(self.coupon)")
            
        if(self.userExistsBool == true)
        {
        if(self.coupon == false)
        {
            let title = "Get $1 regular size boba"
            let message = "Show the cashier your post on facebook, like foodies app page and Boba Fiend Riverside page to redeem your coupon. Please do this when you are at the store."
            let image = UIImage(named: "boba_fiend")
        
            // Create the dialog
            let popup = PopupDialog(title: title, message: message, image: image)
        
            // Create buttons
        
            let buttonOne = DefaultButton(title:"Share Now to get Coupon!")
            {
                
//                let title = "Please sign in to redeem."
//                let message = "Only users who are signed in can get the coupon!"
//                
//                // Create the dialog
//                let popup = PopupDialog(title: title, message: message)
//                
                
                
                
                let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                //fbShare.add(_url:URL!)
                fbShare.setInitialText("Download Foodies today!")
                fbShare.add(URL(string: "http://foodiesapp.io"))
                self.present(fbShare, animated: true, completion: nil)
                
                fbShare.completionHandler = { (result:SLComposeViewControllerResult) -> Void in
                    switch result {
                    case SLComposeViewControllerResult.cancelled:
                        print("Cancelled")
                    case SLComposeViewControllerResult.done:
                        print("posted successfully")
                        self.couponRedeemed = true
                        let defaults = UserDefaults.standard
                        
                        //self.coupon = true
                        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
                            return
                        }
                        self.ref = FIRDatabase.database().reference()
                        
                        self.ref.child("BobaFiend").child(uid).setValue(["redeemed": true])
                        

                    }
                }
                
                
                
        
                
                
            }
            let buttonThree = DestructiveButton(title: "Redeem Later")
            {
                print("You canceled the car dialog.")
            }
            popup.addButtons([buttonOne, buttonThree])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
        }
        else
        {
            let title = "Already Redeemed!"
            let message = "Please wait till our next promotion!"
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message)
            
            let buttonThree = DestructiveButton(title: "Ok") {
                print("Ah, maybe next time :)")
            }
            
            
            self.present(popup, animated: true, completion: nil)
            
        }
        }
        else
        {
            let title = "Please sign in to redeem."
            let message = "Only users who are signed in can get the coupon!"
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message)
            
            let buttonThree = DestructiveButton(title: "Ok") {
            }
            popup.addButtons([buttonThree])
            
            self.present(popup, animated: true, completion: nil)
            
            
        }
        
        
        
        }
        
        
    }
    
    @IBAction func logOut(_ sender: Any)
    {
        if userExistsBool == true
        {
            let manager = FBSDKLoginManager()
            manager.logOut()
            let firebaseAuth = FIRAuth.auth()
            do
            {
                try firebaseAuth?.signOut()
            }
            catch let signOutError as NSError
            {
                print ("Error signing out: %@", signOutError)
            }
            performSegue(withIdentifier: "logout", sender: nil)
        }
        performSegue(withIdentifier: "logout", sender: nil)
        
    }
    
    
    var randomIds = [String]()
    var checkRef: FIRDatabaseReference!

    
    
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
        
        
        
        
        
        
        
        if self.coupon == true && self.couponRedeemed == true
        {
            let pop = PopupDialog(title: "Redeemed", message: "Enjoy!")
            self.present(pop, animated: true, completion:nil)
            self.couponRedeemed = false
        }
        
        //print("this is coupon \(self.coupon)")
        

        
        
        
        
        
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
    
    func getLocation()
    {
        UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)

    }
    
    var appearance = SCLAlertView.SCLAppearance(
        showCloseButton: false)
    
    
    
   
    @IBOutlet var searchRestaurantsButton: UIButton!
    
    @IBAction func searchRestaurantsButton(_ sender: Any)
    {
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false)
        
        
        let waitView:SCLAlertViewResponder = SCLAlertView(appearance:appearance).showWait("Please Wait...", subTitle: "Sorting Images... the wait may take upto 30 seconds")

        
        
        
        //self.view.bringSubview(toFront: indicator)
        self.searchRestaurantsButton.isEnabled = false
        
        //start animator
        //indicator.isHidden = false
        
        
        
        
        
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                locationBool = false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locationBool = true
            }
        }
        else
        {
            print("Location services are not enabled")
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "Avenir", size: 20)!,
                kTextFont: UIFont(name: "Avenir", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: false)
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("Go to Settings", target:self, selector:#selector(SearchPageController.getLocation))
            alert.addButton("Cancel") {
                alert.dismiss(animated: true, completion: nil)
            }
            alert.showError("Error", subTitle: "Please Enable Location in Settings")
            self.searchRestaurantsButton.isEnabled = true

        }
        
        
        if(locationBool == false)
        {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "Avenir", size: 20)!,
                kTextFont: UIFont(name: "Avenir", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: false)
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("Go to Settings", target:self, selector:#selector(SearchPageController.getLocation))
            alert.addButton("Cancel") {
                alert.dismiss(animated: true, completion: nil)
            }
            alert.showError("Error", subTitle: "Please Enable Location in Settings")
            waitView.close()
            
            self.searchRestaurantsButton.isEnabled = true
            
            
        }
        else
        {
            print("there is location")
            searchQuery = searchBar.text
            if searchBar.text?.isEmpty == true
            {
                searchBar.text = foodArray.randomItem()
                print(searchBar.text!)
                searchQuery = searchBar.text
            }
            let newString = searchQuery.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            
            
            let request:String! = "https://api.foursquare.com/v2/venues/search?client_id=FDVNPZWJ1QZ3EUMVAXHYTB2ISVV2UUD0A2H01PUGYGESXDAX&client_secret=JIHLRBPYRI2ZKHB4MBRCGL2HLDLHVTDPKDFOJFVVXIFC5BWR&v=20130815&ll=\(self.lat!),\(self.lon!)&query=\(newString)&limit=20&radius=\(meters)"
            
            makeRequest(request)
            
            requestDone = true
            
//            waitView.setTitle("Finding Restaurants")
//            waitView.setSubTitle("Sorting restaurants...")
//            
            //TimerWithTimeInterval()
            
            
            
            if userExistsBool == true
            {
                storeQueryInfo()
                
            }
            else
            {
                let totalValues = ["query": self.searchQuery!, "lat": self.lat!, "lon": self.lon!, "name":"N/A"] as [String : Any]
                let totalSearchReference = FIRDatabase.database().reference().child("total-searches")
                totalSearchReference.childByAutoId().setValue(totalValues)
                
                
            }
            
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "Avenir", size: 20)!,
                kTextFont: UIFont(name: "Avenir", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: true)
            
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0)
//            {
                if self.noRestBool == true
                {
                    print("error finding rests")
                    let alert = SCLAlertView(appearance: appearance)
                    alert.showError("Error", subTitle: "No Restaurants were found. Please check your internet connection.")
                    waitView.close()
                    
                    self.searchBar.text = ""
                    self.alreadyError = true
                    self.searchRestaurantsButton.isEnabled = true
                }
            //}
            
            if noRestBool == false
            {
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2)
                {
                    
                    waitView.close()
                    print("this goes third")
                    
                    
                    
                    
                    
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont(name: "Avenir", size: 20)!,
                        kTextFont: UIFont(name: "Avenir", size: 14)!,
                        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                        showCloseButton: true)
                    
                    
                    
                    if self.ids.count <= 5
                    {
                        
                        print("case 1")
                        self.rowNum = self.ids.count
                        print("here yo")
                        
                        print("this goes third")
                        
                        waitView.setSubTitle("Sorting images...")
                        
                        var p = 0
                        while p < self.ids.count
                        {
                            self.getPhotos(picsForIds: self.ids[p])
                            p += 1
                        }
                        
                        
                        
                        
                        
                        if self.pics.count > 0
                        {
                            print("success")
                            waitView.close()
                            
                            self.performSegue(withIdentifier: "swipe", sender: self.pics)
                        }
                        else if self.alreadyError == true
                        {
                            print("found no pics")
                            self.searchBar.text = ""
                            let alert = SCLAlertView(appearance: appearance)
                            alert.showError("Error", subTitle: "No Restaurants were found. Please widen your search")
                            
                            self.searchRestaurantsButton.isEnabled = true
                            waitView.close()
                            
                            
                        }
                        else
                        {
                            self.searchBar.text = ""
                            let alert = SCLAlertView(appearance: appearance)
                            alert.showError("Error", subTitle: "Please try again")
                            
                            self.searchRestaurantsButton.isEnabled = true
                            waitView.close()
                            
                            
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
                        print(randNum)
                        while(f < randNum.count)
                        {
                            print(randNum[f])
                            let getInt:Int! = randNum[f]
                            print(self.ids[getInt])
                            newIds.append(self.ids[getInt])
                            f += 1
                        }
                        
                        
                        print("case 2")
                        
                        print("this goes third")
                        waitView.setSubTitle("Sorting images...")
                        
                        
                        var p = 0
                        while p < newIds.count
                        {
                            self.getPhotos(picsForIds: newIds[p])
                           
                            p += 1
                            
                        }
                        
                        
                        
                        
                        if self.pics.count > 0
                        {
                            print("success")
                            waitView.close()
                            self.performSegue(withIdentifier: "swipe", sender: self.pics)
                            
                        }
                        else if self.alreadyError == true
                        {
                            print("found no pics")
                            self.searchBar.text = ""
                            self.searchRestaurantsButton.isEnabled = true
                            let alert = SCLAlertView(appearance: appearance)
                            alert.showError("Error", subTitle: "No Restaurants were found. Please widen your search")
                            waitView.close()
                            
                            
                        }
                        else
                        {
                            self.searchBar.text = ""
                            self.searchRestaurantsButton.isEnabled = true
                            let alert = SCLAlertView(appearance: appearance)
                            alert.showError("Error", subTitle: "Please try again")
                            waitView.close()
                            
                        }
                        
                    }
                }
            }
            
            
        }
        //                                    else if secondJSON["venue"]["response"]["venue"]["popular"]["isOpen"].boolValue == false
        //                                    {
        //                                        print("This restaurant is Closed")
        //                                        print(secondJSON["response"]["venue"]["popular"]["isOpen"])
        //
        //                                    }
        
        
    }
    func storeQueryInfo()
    {
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
        
    }
    
    
    func getPhotos(picsForIds:String)
    {
        
        let response = Alamofire.request("https://api.foursquare.com/v2/venues/\(picsForIds)/photos?client_id=FDVNPZWJ1QZ3EUMVAXHYTB2ISVV2UUD0A2H01PUGYGESXDAX&client_secret=JIHLRBPYRI2ZKHB4MBRCGL2HLDLHVTDPKDFOJFVVXIFC5BWR&v=20130815&limit=6", parameters:nil).responseJSON()
        if((response.result.value) != nil)
        {
            var secondJSON:JSON!
            secondJSON = JSON(response.result.value!)
            if self.picCounter < 3
            {
                
                for (_,subJson):(String, JSON) in secondJSON["response"]["photos"]["items"]
                {
                    var url: String = subJson["prefix"].stringValue
                    url += "300x300"
                    url += subJson["suffix"].stringValue
                
                    //do filtering
                    
                    
                
                    if url != "300x300"
                    {
                        let newurl = URL(string: url)
                        let data = try? Data(contentsOf: newurl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    
                        let binaryImageData = base64EncodeImage(UIImage(data: data!)!)
                        
                    
                        
                            print("this is pic counter")
                            print(picCounter)
                        if self.picCounter < 3
                        {
                            createRequest(with: binaryImageData)
                            
                        }
                        
                        
                    
                        if self.checkImg == true && self.picCounter < 3
                        {
                            print("got appended")
                            self.pics.append(url) // urls
                        }
                        
                    }

                }
            }
                self.pics.append(picsForIds)
                self.restaurants.append(picsForIds)
            
            
            picCounter = 0
          
        }
        
        
        
    }
    
    
    
    //                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0)
    //                {
    //                    var b = 0
    //                    while b < self.foodBools.count
    //                    {
    //                        print("sizes")
    //                        print(self.foodBools.count)
    //                        print(self.pics.count)
    //                        if self.foodBools[b] == false
    //                        {
    //                            self.pics[b] = "NULL"
    //                        }
    //                        b += 1
    //                    }
    //                    self.pics = self.pics.filter{$0 != "NULL"}
    //                }

    
    func makeRequest(_ url:String)
    {
        
        let response = Alamofire.request(url, parameters:nil).responseJSON()
        if response.result.value != nil
        {
            let json = JSON(response.result.value!)
            
            if json["response"]["venues"].count == 0
            {
                print("why here")
                self.noRestBool = true
                
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
                                    self.ids.append(id)
                                }
                            case .failure:
                                print("there is an error with internet")
                                
                            }
                    }
                }
            }
        }
        else
        {
            print("request error")
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
        else if segue.identifier == "logout"
        {
            if let destination = segue.destination as? ViewController
            {
                destination.User = nil
            }
        }
        else if segue.identifier == "toIntro"
        {
            print("in segue")
           
        }
        
    }
    
    func checkCouponRedeemed()
    {
        
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        FIRDatabase.database().reference().child("BobaFiend").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let couponBool = (value?["redeemed"] as? Bool)!
            if couponBool == true
            {
                self.coupon = true
            }
            print("coupon2 is \(self.coupon)")
            
            
        })
        { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //indicator.isHidden = true
    //    FIRApp.configure()
        
        
        
        self.hideKeyboardWhenTappedAround()
        ref = FIRDatabase.database().reference().child("total-searches")
        scheduledTimerWithTimeInterval()
        
        
        if (FIRAuth.auth()?.currentUser?.uid) != nil
        {
            userExistsBool = true
            
        }
        else
        {
            userExistsBool = false
            logoutButton.setTitle("Back", for: .normal)
        }
        
        
        if userExistsBool == true
        {
            uid = FIRAuth.auth()?.currentUser?.uid
            let keychain = KeychainSwift()
            
            
            
            
            let defaults = UserDefaults.standard
            
            
            print("bobafiend bool is \(keychain.getBool("BobaFiend"))")
            
            if((defaults.bool(forKey: "isRedeemed")) == false)
            {
                keychain.set(true, forKey: "BobaFiend")
                guard let uid = FIRAuth.auth()?.currentUser?.uid else {
                    return
                }
                self.ref = FIRDatabase.database().reference()
                self.ref.child("BobaFiend").child(uid).setValue(["redeemed": false])
            }
        }
        
        searchBar.delegate = self
        
        //goes to intro screens
        
        
        searchBar.iconFont = UIFont.fontAwesome(ofSize: 15)
        searchBar.iconText = String.fontAwesomeIcon(name: .cutlery)
        
        searchQuery = searchBar.text
        
        searchRestaurantsButton.setImage(UIImage(named:"SurpriseMeButton"), for: .normal)
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let blue = hexStringToUIColor(hex: "#40C4FF")
        
        dialogAppearance.titleFont            = UIFont.boldSystemFont(ofSize: 20)
        dialogAppearance.titleColor           = UIColor.black
        dialogAppearance.titleTextAlignment   = .center
        dialogAppearance.messageFont          = UIFont.systemFont(ofSize: 16)
        dialogAppearance.messageColor         = UIColor(white: 0.8, alpha: 1)
        dialogAppearance.messageTextAlignment = .center
        
        
        
        
        slideShow.setImageInputs([
            ImageSource(image: UIImage(named: "boba_fiend")!),
            ImageSource(image: UIImage(named: "pizza")!), ImageSource(image: UIImage(named: "coffee")!), ImageSource(image: UIImage(named: "noodles")!), ImageSource(image: UIImage(named: "burger")!)])
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
    
    //View moves up when keyboard is shown
    func keyboardWillShow(sender: NSNotification)
    {
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        keyBoardHeight = keyboardFrame.cgRectValue
        
        slideShow.isHidden = true
        self.view.frame.origin.y -= keyBoardHeight.height
    }
    
    //View moves down when keyboard is hiding
    func keyboardWillHide(sender: NSNotification) {
        slideShow.isHidden = false
        self.view.frame.origin.y += keyBoardHeight.height
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    func getMeters(miles: Int) -> Int
    {
        var meters:Int = 0
        meters = miles * 1609
        return meters
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        lat = locValue.latitude as Double!
        lon = locValue.longitude as Double!
    }
    
    
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data
    {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    func createRequest(with imageBase64: String) {
        // Build our API request
        let jsonRequest =
            [
                "requests":
                    [
                        "image":
                            [
                                "content": imageBase64
                        ],
                        "features":
                            [
                                [
                                    "type": "LABEL_DETECTION",
                                    "maxResults": 3
                                ]
                        ]
                ]
        ]
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        if let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)") {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = data
            
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
            
            let response = Alamofire.request(urlRequest)
                .responseJSON()
            if let j = response.result.value {
                
                var json = JSON(response.result.value)
                let responses: JSON = json["responses"][0]
                let labelAnnotations: JSON = responses["labelAnnotations"]
                let numLabels: Int = labelAnnotations.count
                var labels: Array<String> = []
                if numLabels > 0 {
                    var labelResultsText:String = "Labels found: "
                    for index in 0..<numLabels
                    {
                        let label = labelAnnotations[index]["description"].stringValue
                        labels.append(label)
                    }
                    for label in labels
                    {
                        // if it's not the last item add a comma
                        if labels[labels.count - 1] != label
                        {
                            labelResultsText += "\(label), "
                        }
                        else
                        {
                            labelResultsText += "\(label)"
                        }
                    }
                    self.label = labelResultsText
                }
                else
                {
                    self.label = "No labels found"
                }
                if labels.contains("food") || labels.contains("drink") || labels.contains("dish")
                {
                    self.checkImg = true
                    picCounter += 1
                    
                    //self.foodBools.append(true)
                }
                else
                {
                    self.checkImg = false
                    //self.foodBools.append(false)
                    
                }
                print(self.label)
            }
        }
        // Run the request on a background thread
        
    }
  
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        // Resize the image if it exceeds the 2MB API limit
        if ((imagedata?.count)! > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    
}
extension Array {
    func randomItem() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
