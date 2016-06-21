//
//  MapRoute.swift
//  LocalLift
//
//  Created by prabhjot singh on 12/7/15.
//  Copyright © 2015 prabhjot singh. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation




class NSIMapRoute {
    var serverKey = ""
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    var fetchedFormattedAddress: String!
    var fetchedAddressLongitude: Double!
    var fetchedAddressLatitude: Double!
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    var overviewPolyline: NSDictionary!
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    var originAddress: String!
    var destinationAddress: String!

    var totalDistanceInMeters: UInt = 0
    var totalDistance: String!
    var totalDurationInSeconds: UInt = 0
    var totalDurationInMinutes: UInt = 0
    var totalDuration: String!
    
    init(serverKey: String) {
        self.serverKey = serverKey
    }
    
}


protocol MapRouteProtocol {
     func geocodeAddress(address: String!, withCompletionHandler completionHandler: ((status: String, success: Bool) -> Void))
     func getDirections(originLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, waypoints: Array<String>?, travelMode: TravelModes, completionHandler: ((status: String, success: Bool) -> Void))
     func calculateTotalDistanceAndDuration()
}
    
extension NSIMapRoute: MapRouteProtocol {

/**
 used to fetch the near by addresses
 
 - parameter address:           any address
 - parameter completionHandler: closure which sends the status and bool
 */
internal func geocodeAddress(address: String!, withCompletionHandler completionHandler: ((status: String, success: Bool) -> Void)) {
    if let lookupAddress = address {
        
        var geocodeURLString = baseURLGeocode + "address=" + lookupAddress
        geocodeURLString = geocodeURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

        let geocodeURL = NSURL(string: geocodeURLString)

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let geocodingResultsData = NSData(contentsOfURL: geocodeURL!)

            do {
                guard let dictionary: Dictionary<String, AnyObject> = try NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] else {return}
                
                guard let status = dictionary["status"] as? String else {return}

                if status == "OK" {
                    
                    guard let allResults = dictionary["results"] as? Array<Dictionary<String, AnyObject>> else {return}
                    
                    self.lookupAddressResults = allResults[0]

                    // Keep the most important values.
                    if let fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as? String{
                        self.fetchedFormattedAddress = fetchedFormattedAddress
                    }
                    
                    if let geometry = self.lookupAddressResults["geometry"] as? Dictionary<NSObject, AnyObject>{
                        let fetchedAddressLongitude = ((geometry["location"] as? Dictionary<NSObject, AnyObject> ?? [:])["lng"] as? NSNumber ?? 0).doubleValue
                        self.fetchedAddressLongitude = fetchedAddressLongitude
                        
                        let fetchedAddressLatitude = ((geometry["location"] as? Dictionary<NSObject, AnyObject> ?? [:])["lat"] as? NSNumber ?? 0).doubleValue
                        self.fetchedAddressLatitude = fetchedAddressLatitude
                    }

                    completionHandler(status: status, success: true)
                    
                }
                else {
                    completionHandler(status: status, success: false)
                }

                // use anyObj here
            } catch let error as NSError {
                print("json error: \(error.localizedDescription)")
            }
        })
    }
    else {
        completionHandler(status: "No valid address.", success: false)
    }
}

/**
 used to fetch the origin coordinates and destination coordinates and helps us to make the route
 
 - parameter origin:            latitude in string
 - parameter destination:       longitude in string
 - parameter waypoints:         way points array have any
 - parameter travelMode:        mode will be biking , running and in car
 - parameter completionHandler: closure which sends the status and bool
 */
internal func getDirections(originLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, waypoints: Array<String>?, travelMode: TravelModes, completionHandler: ((status: String, success: Bool) -> Void)) {

    let origin = "\(originLocation.latitude)" + "," + "\(originLocation.longitude)"
    let destination = "\(destinationLocation.latitude)" + "," + "\(destinationLocation.longitude)"
    
    var directionsURLString = baseURLDirections + "origin=" + origin + "&destination=" + destination

// waypoint Initialization
    if let routeWaypoints = waypoints {
        directionsURLString += "&waypoints=optimize:true"
        for waypoint in routeWaypoints {
            directionsURLString += "|" + waypoint
        }
    }
    
// travel mode initialization
    var travelModeString = ""
    switch travelMode.rawValue {
    case TravelModes.Walking.rawValue:
        travelModeString = "walking"
    case TravelModes.Bicycling.rawValue:
        travelModeString = "bicycling"
    default:
        travelModeString = "driving"
    }
    
    directionsURLString += "&mode=" + travelModeString
    directionsURLString = directionsURLString + "/\(serverKey)"
    directionsURLString = directionsURLString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

    let directionsURL = NSURL(string: directionsURLString)

    dispatch_async(dispatch_get_main_queue(), { () -> Void in
        guard let directionsData: NSData? = NSData(contentsOfURL: directionsURL!) else {return}
        
        do {
            guard let dictionary: Dictionary<NSObject, AnyObject> = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as? [String: AnyObject] else {return}
            guard let status = dictionary["status"] as? String else {return}
            
            if status == "OK"{
                self.selectedRoute = (dictionary["routes"] as? Array<Dictionary<NSObject, AnyObject>> ?? [])[0] ?? [:]
                if let overviewPol = self.selectedRoute["overview_polyline"] as? NSDictionary {
                    self.overviewPolyline = overviewPol
                }
                
                guard let legs = self.selectedRoute["legs"] as? Array<Dictionary<NSObject, AnyObject>> else {return}
                let startLocationDictionary = legs[0]["start_location"] as? Dictionary<NSObject, AnyObject> ?? [:]
                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as? Double ?? 0, startLocationDictionary["lng"] as? Double ?? 0)
                let endLocationDictionary = legs[legs.count - 1]["end_location"] as? Dictionary<NSObject, AnyObject> ?? [:]
                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as? Double ?? 0, endLocationDictionary["lng"] as? Double ?? 0)
                
                self.calculateTotalDistanceAndDuration()
                completionHandler(status: status, success: true)
                return
            }
            
        } catch let error as NSError {
            print("json error: \(error.localizedDescription)")
        }
    })
}



/**
 Calculate the distance and duration
 */
 internal func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as? Array<Dictionary<NSObject, AnyObject>> ?? []

        totalDistanceInMeters = 0
        totalDurationInSeconds = 0

        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as? Dictionary<NSObject, AnyObject> ?? [:])["value"] as? UInt ?? 0
            totalDurationInSeconds += (leg["duration"] as? Dictionary<NSObject, AnyObject> ?? [:])["value"] as? UInt ?? 0
        }

        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        totalDistance = "\(distanceInKilometers)"

        let mins = totalDurationInSeconds / 60
        totalDurationInMinutes = mins
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60

        totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"

    }
    
}
