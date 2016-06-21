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
typealias AddressHandler = (obj: NSIAddress?, success: Bool) -> Void
typealias SuccessHandler = () -> Void
typealias MarkerTouchHandler = (markerAndMap: (marker: GMSMarker, map: GMSMapView), touchType: NSITouchType) -> Void
typealias MapTouchHandler = (coordinateAndMap: (coordinates: (latitude: Double, longitude: Double), map: GMSMapView), touchType: NSITouchType) -> Void
typealias CompletionHandler = (obj: AnyObject, success: Bool) -> Void

//MARK:- ENUMS
enum NSIMapType: UInt32 {
    // types of the map
    case NormalMap = 1
    case SatteliteMap
    case TerrainMap
    case HybridMap
    case NoneMap
}

enum NSIMapSpeed: UInt32 {
    //speed of the map
    case Slow
    case Medium
    case Fast
}

enum TravelModes: Int {
    //modes of the map
    case Driving
    case Walking
    case Bicycling
}

// marker touch type
enum NSITouchType: Int {
    case SingleTouchOnMarker //when user touches the marker
    
    case LongTouchOnInfo //when user touches the info window if its set
    case SingleTouchOnInfo //when user long press on info window if its set
    case CloseTouchOnInfo //when user cancel the info window if its set
    
    case SingleTouchOnMap // when user single touch
    case LongTouchOnMap // when user long presses the map
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
    var nsiMapType: NSIMapType = .NormalMap {
        didSet {
            self.mapType.rawValue =  nsiMapType.rawValue
        }
    }
        /// speed of the map. defaultly its fast type.
    var nsiMapSpeed: NSIMapSpeed = .Fast {
        didSet {
            self.preferredFrameRate.rawValue =  nsiMapSpeed.rawValue
        }
    }
    
    var centerMarker: UIImageView?
    var infoWindowView: UIView?


    
// MARK:- View Life Cycel Methods
	override func awakeFromNib() {

		super.awakeFromNib()
        
		self.myLocationEnabled = true
		self.settings.myLocationButton = true
		self.delegate = self
	}
}


/**
 *  NSIMapViewProtocol:- Plenty of methods which is used to do google map tasks
 */

protocol NSIMapViewProtocol {
    
    /**
     it will show the marker on center of the map for fecthing the location at the center point
     
     - parameter viewSize: view size is the width and height of the image
     - parameter image:    image of the center marker
     */
    func showCenterMarker(viewSize: CGSize, image: UIImage?)
    
    
    /**
     used to hide the center marker
     */
    func hideCenterMarker()
    
    /**
     used to create the google marker through NSIMarker
     
     - parameter nsiMarker: model which is used to store the google marker type values
     - parameter completed: closure which returns success
     */
    func createMarker(nsiMarker: NSIMarker, completed: SuccessHandler)
    func createMarker(nsiMarker: NSIMarker)
    
    
    /**
     used to create the multiple google markers though array of NSIMarker
     
     - parameter nsiMarkers: model which is used to store the google marker type values
     - parameter completed:  closure which returns success
     */
    func createMultipleMarkers(nsiMarkers: [NSIMarker], completed: SuccessHandler)
    func createMultipleMarkers(nsiMarkers: [NSIMarker])
    
    /**
     this method is used when user wants to enable touch event on the marker and on marker info. user may also send the infoWindowview here
     
     - parameter infoWindowView:       view which invoke when user click on the marker
     - parameter markerTouchCompleted: handler which gives the marker, Map and touch event
     */
    
    func touchOnMarkerOrInfoWindow(infoWindowView: UIView?, markerTouchCompleted: MarkerTouchHandler)
    
    /**
     this method is used when user wants to enable touch event on the map
     - parameter mapTouchCompleted: handler which gives the map, coordinates and the touch event
     */
    func touchOnMap(mapTouchCompleted: MapTouchHandler)
    
    /**
     used to set the camera on map
     
     - parameter location: lat and long of the map
     - parameter zoom:     zoom level
     */
    func setCameraOfMap(location: (latitude: Double, longitude: Double), zoom: Float)
    
    /**
     used to draw the route on map
     
     - parameter startLocationMarker: nsimarker object which should have lat and long of starting location
     - parameter endLocationMarker:   nsimarker object which should have lat and long of end location
     - parameter shouldShowMarker:    shouldShowMarker is bool variable. defaultly false that means user dont want to show the marker
     - parameter handler:             handler which send the MapRoute object
     */
    func drawRoute(startLocationMarker: NSIMarker, endLocationMarker: NSIMarker, shouldShowMarker: Bool, handler: (mapRoute: NSIMapRoute) -> Void)
    
    
    /**
     *  used to fetch the address through lat long
     *
     *  @param shouldFindLocationWhenDraggMap false(if user wants to fetch the address only for one time) true(if user wants to fetch the address whenever map dragged)
     *  @param latitude    double value of latitude
     *  @param longitude    double value of longitude
     *
     *  @return NSIAddress (address in chuncks)
     */
    func findLocationWhenDragging(shouldFindLocationWhenDraggMap: Bool, shouldShowCenterMarker: Bool, location: (latitude: Double, longitude: Double), handler: AddressHandler)
    
}
