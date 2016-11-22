//
//  MapViewHome.swift
//  LocalLift
//
//  Created by prabhjot singh on 12/7/15.
//  Copyright © 2015 prabhjot singh. All rights reserved.
//

import UIKit
import GoogleMaps

//MARK:- Completion Closure
typealias AddressHandler = (_ obj: NSIAddress?, _ success: Bool) -> Void
typealias SuccessHandler = () -> Void
typealias MarkerTouchHandler = (_ markerAndMap: (marker: GMSMarker, map: GMSMapView), _ touchType: NSITouchType) -> Void
typealias MapTouchHandler = (_ coordinateAndMap: (coordinates: (latitude: Double, longitude: Double), map: GMSMapView), _ touchType: NSITouchType) -> Void
typealias CompletionHandler = (_ obj: AnyObject, _ success: Bool) -> Void

//MARK:- ENUMS
enum NSIMapType: UInt32 {
    // types of the map
    case normalMap = 1
    case satteliteMap
    case terrainMap
    case hybridMap
    case noneMap
}

enum NSIMapSpeed: UInt32 {
    //speed of the map
    case slow
    case medium
    case fast
}

enum TravelModes: Int {
    //modes of the map
    case driving
    case walking
    case bicycling
}

// marker touch type
enum NSITouchType: Int {
    case singleTouchOnMarker //when user touches the marker
    
    case longTouchOnInfo //when user touches the info window if its set
    case singleTouchOnInfo //when user long press on info window if its set
    case closeTouchOnInfo //when user cancel the info window if its set
    
    case singleTouchOnMap // when user single touch
    case longTouchOnMap // when user long presses the map
}

// MARK:- Model of Address
struct NSIAddress {
    var streetName: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var country: String?
    
    var fullAddress: String {
        return (((self.streetName == nil) ? "" : "\(self.streetName!) ") + ((self.city == nil) ? "" : "\(self.city!) ") + ((self.state == nil) ? "" : "\(self.state!) ") + ((self.zipCode == nil) ? "" : "\(self.zipCode!) ") + ((self.country == nil) ? "" : "\(self.country!)"))
    }
    
    init(streetName: String?, city: String?, state: String?, zipCode: String?, country: String?) {
        self.streetName = streetName
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
    }
}



//MARK:-  NSIMapView Class
 /// NSIMapView is view type class which conforms NSIMapViewProtocol

class NSIMapView: GMSMapView, NSIMapViewProtocol {

//	var mapView = GMSMapView()
    var shouldFindLocationWhenDragging = false
    var locationDragHandler: AddressHandler?
    var markerTouchHandler: MarkerTouchHandler?
    var mapTouchHandler: MapTouchHandler?
    
        /// type of the map. defaultly its normal type.
    var nsiMapType: NSIMapType = .normalMap {
        didSet {
            self.mapType.rawValue =  nsiMapType.rawValue
        }
    }
        /// speed of the map. defaultly its fast type.
    var nsiMapSpeed: NSIMapSpeed = .fast {
        didSet {
            self.preferredFrameRate.rawValue =  nsiMapSpeed.rawValue
        }
    }
    
    var centerMarker: UIImageView?
    var infoWindowView: UIView?


    
// MARK:- View Life Cycel Methods
	override func awakeFromNib() {

		super.awakeFromNib()
        
		self.isMyLocationEnabled = true
		self.settings.myLocationButton = true
		self.delegate = self
	}
}


/**
 *  NSIMapViewProtocol:- Plenty of methods which is used to do google map tasks
 */

protocol NSIMapViewProtocol {

}
