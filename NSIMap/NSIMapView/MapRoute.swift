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
    var lookupAddressResults: Dictionary<String, AnyObject>!
    var fetchedFormattedAddress: String!
    var fetchedAddressLongitude: Double!
    var fetchedAddressLatitude: Double!
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    var selectedRoute: Dictionary<String, AnyObject>!
    var overviewPolyline: Dictionary<String, AnyObject>!
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
}
    
extension NSIMapRoute: MapRouteProtocol {

/**
 used to fetch the near by addresses
 
 - parameter address:           any address
 - parameter completionHandler: closure which sends the status and bool
 */
internal func geocodeAddress(_ address: String!, withCompletionHandler completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {
    if let lookupAddress = address {
        
        var geocodeURLString = baseURLGeocode + "address=" + lookupAddress
        geocodeURLString = geocodeURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        let geocodeURL = URL(string: geocodeURLString)

        DispatchQueue.main.async(execute: { () -> Void in
            let geocodingResultsData = try? Data(contentsOf: geocodeURL!)

            do {
                guard let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: geocodingResultsData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject] else {return}
                
                guard let status = dictionary["status"] as? String else {return}

                if status == "OK" {
                    
                    guard let allResults = dictionary["results"] as? Array<Dictionary<String, AnyObject>> else {return}
                    
                    self.lookupAddressResults = allResults[0] as Dictionary<String, AnyObject>!

                    // Keep the most important values.
                    if let fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as? String{
                        self.fetchedFormattedAddress = fetchedFormattedAddress
                    }
                    
                    if let geometry = self.lookupAddressResults["geometry"] as? Dictionary<String, AnyObject>{
                        let fetchedAddressLongitude = ((geometry["location"] as? Dictionary<String, AnyObject> ?? [:])["lng"] as? NSNumber ?? 0).doubleValue
                        self.fetchedAddressLongitude = fetchedAddressLongitude
                        
                        let fetchedAddressLatitude = ((geometry["location"] as? Dictionary<String, AnyObject> ?? [:])["lat"] as? NSNumber ?? 0).doubleValue
                        self.fetchedAddressLatitude = fetchedAddressLatitude
                    }

                    completionHandler(status, true)
                    
                }
                else {
                    completionHandler(status, false)
                }

                // use anyObj here
            } catch let error as NSError {
                print("json error: \(error.localizedDescription)")
            }
        })
    }
    else {
        completionHandler("No valid address.", false)
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
internal func getDirections(_ originLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, waypoints: Array<String>?, travelMode: TravelModes, completionHandler: @escaping ((_ status: String, _ success: Bool) -> Void)) {

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
    case TravelModes.walking.rawValue:
        travelModeString = "walking"
    case TravelModes.bicycling.rawValue:
        travelModeString = "bicycling"
    default:
        travelModeString = "driving"
    }
    
    directionsURLString += "&mode=" + travelModeString
    directionsURLString = directionsURLString + "/\(serverKey)"
    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

    let directionsURL = URL(string: directionsURLString)

    DispatchQueue.main.async(execute: { () -> Void in
        guard let directionsData: Data? = try? Data(contentsOf: directionsURL!) else {return}
        
        do {
            guard let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject] as Dictionary<String, AnyObject>? else {return}
            guard let status = dictionary["status"] as? String else {return}
            
            if status == "OK"{
                self.selectedRoute = (dictionary["routes"] as? Array<Dictionary<String, AnyObject>> ?? [])[0] 
                if let overviewPol = self.selectedRoute["overview_polyline"] as? Dictionary<String, AnyObject> {
                    self.overviewPolyline = overviewPol
                }
                
                guard let legs = self.selectedRoute["legs"] as? Array<Dictionary<String, AnyObject>> else {return}
                let startLocationDictionary = legs[0]["start_location"] as? Dictionary<String, AnyObject> ?? [:]
                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as? Double ?? 0, startLocationDictionary["lng"] as? Double ?? 0)
                let endLocationDictionary = legs[legs.count - 1]["end_location"] as? Dictionary<String, AnyObject> ?? [:]
                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as? Double ?? 0, endLocationDictionary["lng"] as? Double ?? 0)
                
                self.calculateTotalDistanceAndDuration()
                completionHandler(status, true)
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
        let legs = self.selectedRoute["legs"] as? Array<Dictionary<String, AnyObject>> ?? []

        totalDistanceInMeters = 0
        totalDurationInSeconds = 0

        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as? Dictionary<String, AnyObject> ?? [:])["value"] as? UInt ?? 0
            totalDurationInSeconds += (leg["duration"] as? Dictionary<String, AnyObject> ?? [:])["value"] as? UInt ?? 0
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
