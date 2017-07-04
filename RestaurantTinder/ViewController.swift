//
//  ViewController.swift
//  RestaurantTinder
//
//  Created by Haasith Sanka on 12/28/16.
//  Copyright © 2016 haasith. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import CoreLocation
import FirebaseAuth
import RevealingSplashView
import NVActivityIndicatorView
import SystemConfiguration
import SCLAlertView
import KeychainSwift

class ViewController: UIViewController, CLLocationManagerDelegate
{

    var lat:Double!
    var lon:Double!
    var locationManager: CLLocationManager!
    
    var loginButton = FBSDKLoginButton()
    var fbcredential:String = ""
    
    @IBOutlet var indicator: NVActivityIndicatorView!
    
    var successBool:Bool! = false
    
    var firstBool:Bool! = true
    var User:User!
    
    func isAppAlreadyLaunchedOnce()->Bool
    {
        let defaults = UserDefaults.standard
        
        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce")
        {
            print("App already launched : \(isAppAlreadyLaunchedOnce)")
            return true
        }
        else
        {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            return false
        }
    }
    
    @IBAction func skipLogin(_ sender: Any)
    {
        performSegue(withIdentifier: "skipLogin", sender: self)
    }
  
    @IBAction func fbButton(_ sender: Any)
    {
        indicator.isHidden = false
        indicator.startAnimating()
        
        let facebook = FBSDKLoginManager()
        
        
        facebook.logIn(withReadPermissions: ["email", "public_profile", "user_friends"], from: self) { (result,error) in
            if error != nil{
                print("fail")
            }
            else if result?.isCancelled == true{
                print("cancelled")
            }
            else
            {
                
                print("logged in")
                
                self.fbcredential = FBSDKAccessToken.current().tokenString
                
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
                self.indicator.stopAnimating()
                self.performSegue(withIdentifier: "ToSearch", sender: self)
            }
            
            
        }
        

    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        
        
        let revealingSplashView = RevealingSplashView(iconImage: UIImage(named: "finalLogo")!,iconInitialSize: CGSize(width: 120, height: 170), backgroundColor: UIColor.white)
        
        //revealingSplashView.animationType = SplashAnimationType.rotateOut

        //Adds the revealing splash view as a sub view
        self.view.addSubview(revealingSplashView)
        
        
        firstBool = isAppAlreadyLaunchedOnce()
        
        
        let keychain = KeychainSwift()
        let defaults = UserDefaults.standard
        
        print("bobafiend bool is \(keychain.getBool("BobaFiend"))")
        if(keychain.getBool("BobaFiend") == true)
        {
            
            defaults.set(true, forKey: "isRedeemed")
            
            
        }
        else
        {
            defaults.set(false, forKey: "isRedeemed")
            
        }
        
        
        //Starts animation
        revealingSplashView.startAnimation(){
            
            if self.firstBool == false
            {
                print("first")
                self.performSegue(withIdentifier: "Screens", sender: nil)
                
            }
            else
            {
                Auth.auth().addStateDidChangeListener { auth, user in
                    if let user = user {
                        if(self.User != user){
                            self.User = user
                            print("-> LOGGED IN AS \(user.email)")
                            self.successBool = true
                        }
                        if self.successBool == true
                        {
                            self.performSegue(withIdentifier: "ToSearch", sender: self)
                        }
                        
                        print(user.email!)
                    } else {
                        // No user is signed in.
                        print("no user")
                        
                    }
                }

            }
            
           
            
        }
        
        if (currentReachabilityStatus == .notReachable)
        {
                    print("error")
            
        }
        
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
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        lat = locValue.latitude as Double!
        lon = locValue.longitude as Double!
    }
    
    
    
    
    
    func firebaseAuth(_ credential: AuthCredential)
    {
        Auth.auth().signIn(with: credential, completion:{ (user, error) in
            if error != nil
            {
                print("fail")
                print(error.debugDescription)
            }
            else
            {
                
                print("success")
                
                let email = user?.email as String!
                let name = user?.displayName as String!
                let url = user?.photoURL?.absoluteString
                
                guard let uid = Auth.auth().currentUser?.uid else {
                    return
                }
                
                
                let values = ["email": email!, "name": name!, "profileImageUrl": url!] as [String : Any]
                
                let userReference = Database.database().reference().child("users").child(uid)
                
                
                userReference.setValue(values)
                

            }
         })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
//        if segue.identifier == "Screens"
//        {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
//            {
//                if let destination = segue.destination as? IntroScreens
//                {
//                    destination.lat = self.lat
//                    destination.lon = self.lon
//                }
//            }
//        }
        if segue.identifier == "skipLogin" || segue.identifier == "ToSearch"
        {
            if let destination = segue.destination as? SearchPageController
            {
                destination.lat = lat
                destination.lon = lon
            }
        }

        
        
    }
    
    
    
    
    
    
}

extension UIViewController{
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}
protocol Utilities {
}
extension NSObject:Utilities{
    
    
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
    
}



