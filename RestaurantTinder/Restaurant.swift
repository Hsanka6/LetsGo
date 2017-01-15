//
//  Restaurant.swift
//  RestaurantTinder
//
//  Created by ganga sanka on 12/29/16.
//  Copyright © 2016 haasith. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Restaurant
{
    
    var name = String()
    var address = String()
    var checkIns = Int()
    var lat = Double()
    var lon = Double()
    var phoneNumber = String()
    var rating = Double()
    var milesAway = Double()
    var imageUrl = String()
    var id = String()
    
    init(name:String, phoneNumber:String, checkIns:Int,lat:Double, lon:Double, address:String)
    {
        self.name = name
        self.phoneNumber = phoneNumber
        self.address = address
        self.checkIns = checkIns
        self.lat = lat
        self.lon = lon
        
        
    }
    
    init(name:String, checkIns:Int, rating: Double,milesAway:Double, imageUrl:String, id: String, lat:Double, lon: Double)
    {
        self.name = name
        self.checkIns = checkIns
        self.rating = rating
        self.milesAway = milesAway
        self.imageUrl = imageUrl
        self.id = id
        self.lon = lon
        self.lat = lat
    }
    
    
    
    var getId:String
    {
        if id.characters.count == 0
        {
            id = ""
        }
        return id
    }

    
    
    
    var getName:String
    {
        if name.characters.count == 0
        {
            name = ""
        }
        return name
    }

    var getImageUrl:String
    {
        if imageUrl.characters.count == 0
        {
            imageUrl = ""
        }
        return imageUrl
    }

    
    
    var getAddress:String
    {
        if address.characters.count == 0
        {
            address = ""
        }
        return address
    }
    
    var getCheckIns:Int
    {
        
        return checkIns
    }
    
    var getLat:Double
    {
        
        return lat
    }
    
    
    var getLon:Double
    {
        
        return lon
    }
    
    var getMilesAway:Double
    {
        
        return milesAway
    }
    
    
    var getRating:Double
    {
        
        return rating
    }
    
    var getPhoneNumber:String
    {
        if phoneNumber.characters.count == 0
        {
            phoneNumber = "Not available"
        }
        return phoneNumber
    }
    
    
//    func downloadPokemonDetails(completed:DownloadComplete)
//    {
//                
//        
//    }
//    
//    
    
    
    
    
    
    
}
