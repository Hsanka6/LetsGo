//
//  TopRestaurantsController.swift
//  RestaurantTinder
//
//  Created by ganga sanka on 1/3/17.
//  Copyright © 2017 haasith. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON
import CoreLocation
import Alamofire_Synchronous

class TopRestaurantsController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    var timer = Timer()

    var restaurantArray = [String]()
    var yesNo = [String]()
    var intArray = [Int]()
    var topRestaurants = [Restaurant]()
    
    var selectedId:String = ""
    
    var store1 = [String]()
    var storeId1 = ""
    var index1:Int! = 0
    var score1:Int! = 0
    
    var store2 = [String]()
    var storeId2 = ""
    var index2:Int! = 0
    var score2:Int! = 0
    
    var store3 = [String]()
    var storeId3 = ""
    var index3:Int! = 0
    var score3:Int! = 0
    
    var store4 = [String]()
    var storeId4 = ""
    var index4:Int! = 0
    var score4:Int! = 0
    
    var store5 = [String]()
    var storeId5 = ""
    var index5:Int! = 0
    var score5:Int! = 0
    
    var storess = [String]()
    var orderedRestaurant = [String:Int]()
    
    var currentLat:Double! = 0.0
    var currentLon:Double! = 0.0
    
    var storeLat:Double!
    var storeLon:Double!
    
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        var i = 0
        while i < yesNo.count
        {
            if yesNo[i] == storeId1
            {
                print("index 1 is")
                index1 = i
            }
            
            if yesNo[i] == storeId2
            {
                print("index 2 is")
                index2 = i
            }
            
            if yesNo[i] == storeId3
            {
                print("index 3 is")
                index3 = i
            }
            
            if yesNo[i] == storeId4
            {
                print("index 4 is")
                index4 = i
            }
            
            if yesNo[i] == storeId5
            {
                print("index 5 is")
                index5 = i
            }
            
            i = i + 1
        }
        
        
        if storeId1 != "NULL" && index1 != 0
        {
            store1.append(contentsOf: yesNo[0...index1-1])
            score1 = getScore(store: store1)
            orderedRestaurant[storeId1] = score1
        }
        else
        {
            score1 = 0
            orderedRestaurant[storeId1] = score1
            
            
        }
        
        
        if storeId2 != "NULL" && index2 != 0 && index2 - index1 > 1
        {
            store2.append(contentsOf: yesNo[index1+1...index2-1])
            score2 = getScore(store: store2)
            orderedRestaurant[storeId2] = score2
        }
        else
        {
            score2 = 0
            orderedRestaurant[storeId2] = score2
            
            
        }
        
        if storeId3 != "NULL" && index3 != 0 && index3 - index2 > 1
        {
            
            store3.append(contentsOf: yesNo[index2+1...index3-1])
            score3 = getScore(store: store3)
            
            orderedRestaurant[storeId3] = score3
        }
        else
        {
            score3 = 0
            orderedRestaurant[storeId3] = score3
            
            
        }
        
        
        if storeId4 != "NULL" && index4 != 0 && index4 - index3 > 1
        {
            
            store4.append(contentsOf: yesNo[index3+1...index4-1])
            score4 = getScore(store: store4)
            
            orderedRestaurant[storeId4] = score4
        }
        else
        {
            score4 = 0
            orderedRestaurant[storeId4] = score4
            
            
        }
        
        if storeId5 != "NULL" && index5 != 0 && index5 - index4 > 1
        {
                    
            store5.append(contentsOf: yesNo[index4+1...index5-1])
            score5 = getScore(store: store5)
            orderedRestaurant[storeId5] = score5
            
        }
        else
        {
            score5 = 0
            orderedRestaurant[storeId5] = score5
            
            
        }
        
        var orderRestaurant = [String]()
        
        orderRestaurant = putRestaurantsInOrder(dictionary: orderedRestaurant)
        print(orderRestaurant)
        
        
        var o = 0
        
        
            while o < orderRestaurant.count
            {
                self.getRestaurants(id: orderRestaurant[o])
                o = o + 1
            }
        
                
    }
    
    
    func putRestaurantsInOrder(dictionary:[String:Int]) -> [String]
    {
        var orderRestaurant = [String]()
        
        
        for (k,v) in (Array(orderedRestaurant).sorted {$0.1 > $1.1}) {
            
            print("\(k):\(v)")
            orderRestaurant.append(k)
        }
        
        return orderRestaurant
    }
    
    func getRestaurants(id: String)
    {
        var name:String!
        var check:Int!
        var ratings:Double!
        var r:Restaurant!
        
        
        
        if id != ""
        {
            
            let response = Alamofire.request("https://api.foursquare.com/v2/venues/\(id)?client_id=FDVNPZWJ1QZ3EUMVAXHYTB2ISVV2UUD0A2H01PUGYGESXDAX&client_secret=JIHLRBPYRI2ZKHB4MBRCGL2HLDLHVTDPKDFOJFVVXIFC5BWR&v=20130815", parameters:nil).responseJSON()
            if let j = response.result.value
            {
                print("sync")
                let json = JSON(response.result.value!)
                
                name = json["response"]["venue"]["name"].stringValue
                check = json["response"]["venue"]["stats"]["checkinsCount"].intValue
                ratings = json["response"]["venue"]["rating"].doubleValue
                var url:String = json["response"]["venue"]["bestPhoto"]["prefix"].stringValue
                let restId:String = id
                
                url += "100x100"
                url += json["response"]["venue"]["bestPhoto"]["suffix"].stringValue
                
                
                
                let lat = json["response"]["venue"]["location"]["lat"].doubleValue
                let long = json["response"]["venue"]["location"]["lng"].doubleValue
                
                
                
                
                var distanceAway = 0.0
                
                distanceAway = self.getMilesAway(lat: lat, lon: long)
                
                
                print("name")
                print(name)
                
                r = Restaurant(name: name,checkIns: check,rating: ratings,milesAway: distanceAway, imageUrl: url, id:restId, lat: lat, lon: long)
                
                self.topRestaurants.append(r)
                
                

            }

        }
        
    }
    
    
    func getScore(store: [String]) -> Int
    {
        
        var Store = [String]()
        Store = store
        var StoreInts = [Int]()
        var j = 0
                while j < store.count
                {
                    if store[j] == "NO"
                    {
                        Store[j] = "0"
                    }
                    else
                    {
                        Store[j] = "1"
                    }
                    j = j + 1
                }
        
        var a = 0
        var score:Int = 0
        
                while a < store.count {
        
                    StoreInts.append(Int(Store[a])!)
        
                    if a < 5
                    {
                        score += StoreInts[a]
        
                    }
                    
                    a = a + 1
                    
                    
                }
        
        
        return score
    }
    
    
    func getMilesAway(lat:Double, lon:Double) -> Double
    {
        let coordinate₀ = CLLocation(latitude: currentLat, longitude: currentLon)
        let coordinate₁ = CLLocation(latitude: lat, longitude: lon)
        print("longitude")
        print(currentLon)
        print("coordinates")
        print(coordinate₁)
        print(coordinate₀)
        
        let distanceInMeters = coordinate₀.distance(from: coordinate₁) // result is in meters
        
        print(distanceInMeters)
        
        
        let milesAway:Double = distanceInMeters/1609.0
        
      return milesAway
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (storeId1 != "NULL" && storeId2 == "NULL" && storeId3 == "NULL" && storeId4 == "NULL"  && storeId5 == "NULL")
        {
            return 1
            
        }
        
        else if (storeId1 != "NULL" && storeId2 != "NULL" && storeId3 == "NULL" && storeId4 == "NULL"  && storeId5 == "NULL")
        {
            return 2
            
        }
        
        else if (storeId1 != "NULL" && storeId2 != "NULL" && storeId3 != "NULL" && storeId4 == "NULL"  && storeId5 == "NULL")
        {
            return 3
            
        }
        
        else if (storeId1 != "NULL" && storeId2 != "NULL" && storeId3 != "NULL" && storeId4 != "NULL"  && storeId5 == "NULL")
        {
            return 4
            
        }
            
        else if (storeId1 != "NULL" && storeId2 != "NULL" && storeId3 != "NULL" && storeId4 != "NULL"  && storeId5 != "NULL")
        {
            return 5
            
        }
        else
        { return 0}
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TopRestaurantTableViewCell
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
            
            cell.setUp(restaurantName: self.topRestaurants[indexPath.row].getName, Rating: self.topRestaurants[indexPath.row].getRating, MilesAway: self.topRestaurants[indexPath.row].getMilesAway, CheckIns: self.topRestaurants[indexPath.row].getCheckIns, ImageUrl: self.topRestaurants[indexPath.row].getImageUrl/*, lat: self.topRestaurants[indexPath.row].getLat, lon: self.topRestaurants[indexPath.row]*/ )
            
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath)
    {
        let indexPath = tableView.indexPathForSelectedRow //optional, to get from any UIButton for example

        
        selectedId = topRestaurants[(indexPath?.row)!].getId
        storeLat = topRestaurants[(indexPath?.row)!].getLat
        storeLon = topRestaurants[(indexPath?.row)!].getLon
        
        performSegue(withIdentifier: "send", sender: self)

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
        if segue.identifier == "send"
        {
            if let destination = segue.destination as? RestaurantViewController
            {
                destination.restId = selectedId
                destination.storeLat = storeLat
                destination.storeLon = storeLon
                destination.currentLat = currentLat
                destination.currentLon = currentLon
                destination.top = topRestaurants
                print("sender \(sender)")
            }
        }
    }
    
   
        
        
        
   
 
}


