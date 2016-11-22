//
//  NSIMapView.swift
//  NSIMap
//
//  Created by prabhjot singh on 6/2/16.
//  Copyright © 2016 Prabhjot Singh. All rights reserved.
//

import GoogleMaps
import CoreLocation


/**
 *  NSIMarker is model which is used to store the google marker type values
 */
struct NSIMarker {
    
    var markerLocation = CLLocationCoordinate2DMake(0, 0)
    var markerName: String?
    var markerIcon: UIImage?
    var markerColor: UIColor?
    var markerOtherInfo: AnyObject?
    
    init() {
    }
    
    init(location: (latitude: Double, longitude: Double)) {
        self.markerLocation = CLLocationCoordinate2DMake(location.latitude, location.longitude)
    }
    
    /**
     return the array of NSIMarker (markers)
    
     - parameter locations: latitude and longitude
     - returns: array of NSIMarker
     */
    static func markersOfLocation(_ locations: [CLLocationCoordinate2D]) -> [NSIMarker] {
        var markers = [NSIMarker]()
        for location in locations {
            var marker = NSIMarker()
            marker.markerLocation = location
            markers.append(marker)
        }
        return markers
    }
}



extension NSIMapViewProtocol where Self: NSIMapView {
    
// MARK: - CENTER MARKER CREATION FUNCTIONS
    
    /**
     it will show the marker on center of the map for fecthing the location at the center point
     
     - parameter viewSize: view size is the width and height of the image
     - parameter image:    image of the center marker
     */
    func showCenterMarker(_ viewSize: CGSize = CGSize(width: 18, height: 26), image: UIImage? = UIImage(named: "centerMarker")) {
        if self.centerMarker == nil {
            self.centerMarker = viewMarkerCenter(viewSize)
        }
        self.centerMarker!.image = image
        UIView.animate(withDuration: 1) {
            self.addSubview(self.centerMarker!)
        }
        
    }
    
    /**
     used to hide the center marker
     */
    func hideCenterMarker() {
        if self.centerMarker == nil {
            return
        }
        UIView.animate(withDuration: 1) {
            self.centerMarker?.removeFromSuperview()
        }
    }
    
    /**
     this private function which create the image of center marker and its frame
    
     - parameter viewSize: size of the center marker
     - returns: imageView of the center marker
     */
    fileprivate func viewMarkerCenter(_ viewSize: CGSize) -> UIImageView {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        let yOrigin = self.frame.height/2 - viewSize.height
        let xOrigin = self.frame.width/2 - viewSize.width/2
        
        let imageMarker = UIImageView(frame: CGRect(x: xOrigin, y: yOrigin, width: viewSize.width, height: viewSize.height))
        imageMarker.contentMode = UIViewContentMode.scaleToFill
        return imageMarker
    }

// MARK: - DROP MARKER FUNCTIONS
    
    /**
     used to create the google marker through NSIMarker
     
     - parameter nsiMarker: model which is used to store the google marker type values
     - parameter completed: closure which returns success
     */
    func createMarker(_ nsiMarker: NSIMarker, completed: SuccessHandler) {
        createMarker(nsiMarker)
        completed()
    }
    
    /**
     used to create the google marker through NSIMarker without handler
     
     - parameter nsiMarker: model which is used to store the google marker type values
     */
    func createMarker(_ nsiMarker: NSIMarker) {
        
        let marker = GMSMarker()
        marker.position = nsiMarker.markerLocation
        marker.snippet = nsiMarker.markerName
        
        if nsiMarker.markerIcon != nil {
            marker.icon = nsiMarker.markerIcon
        } else {
            if nsiMarker.markerColor != nil {
                marker.icon = GMSMarker.markerImage(with: nsiMarker.markerColor)
            }
        }
        marker.infoWindowAnchor = CGPoint(x: 0.44, y: 0.45)
        marker.userData = nsiMarker.markerOtherInfo
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = self
        
    }
    
    /**
     used to create the multiple google markers though array of NSIMarker
     
     - parameter nsiMarkers: model which is used to store the google marker type values
     - parameter completed:  closure which returns success
     */
    func createMultipleMarkers(_ nsiMarkers: [NSIMarker], completed: SuccessHandler) {
        createMultipleMarkers(nsiMarkers)
        completed()
    }
    
    /**
     used to create the multiple google markers though array of NSIMarker without success handler
     - parameter nsiMarkers: model of addres
     */
    func createMultipleMarkers(_ nsiMarkers: [NSIMarker]) {
        for marker in nsiMarkers {
            createMarker(marker, completed: {
            })
        }
    }
    
//MARK:- Touch Event methods
    
    /**
     this method is used when user wants to enable touch event on the marker and on marker info. user may also send the infoWindowview here
     
     - parameter infoWindowView:       view which invoke when user click on the marker
     - parameter markerTouchCompleted: handler which gives the marker, Map and touch event
     */
    func touchOnMarkerOrInfoWindow(_ infoWindowView: UIView?, markerTouchCompleted: @escaping MarkerTouchHandler) {
        self.infoWindowView = infoWindowView
        self.markerTouchHandler = markerTouchCompleted
    }
    
    /**
     this method is used when user wants to enable touch event on the map
     - parameter mapTouchCompleted: handler which gives the map, coordinates and the touch event
     */
    func touchOnMap(_ mapTouchCompleted: @escaping MapTouchHandler) {
        self.mapTouchHandler = mapTouchCompleted
    }
    
    
//MARK:- Route Draw Methods
    
    /**
     used to draw the route on map
     
     - parameter startLocationMarker: nsimarker object which should have lat and long of starting location
     - parameter endLocationMarker:   nsimarker object which should have lat and long of end location
     - parameter shouldShowMarker:    shouldShowMarker is bool variable. defaultly false that means user dont want to show the marker
     - parameter handler:             handler which send the MapRoute object
     */
    func drawRoute(_ startLocationMarker: NSIMarker, endLocationMarker: NSIMarker, shouldShowMarker: Bool = false, handler: @escaping (_ mapRoute: NSIMapRoute) -> Void) {
        let mapRoute = NSIMapRoute(serverKey: "AIzaSyAm0k6TP4RqQ9V8XnA68wZ-E-NnX2xWwYU")
 
        mapRoute.getDirections(startLocationMarker.markerLocation, destinationLocation:endLocationMarker.markerLocation, waypoints: nil, travelMode: TravelModes.driving) { (status, success) in
            self.drawPolyline(mapRoute)
            
            if shouldShowMarker == true {
                let markers = [startLocationMarker, endLocationMarker]
                self.createMultipleMarkers(markers)
            }
            
            handler(mapRoute)
        }
    }
    
    /**
     private method used to draw the polyline
     - parameter mapRoute: maproute object
     */
    fileprivate func drawPolyline(_ mapRoute: NSIMapRoute) {
        if let route = mapRoute.overviewPolyline["points"] as? String {
            let polyline = GMSPolyline()
            let path: GMSPath = GMSPath(fromEncodedPath: route)!
            polyline.path = path
            polyline.strokeWidth = 4.0
            polyline.geodesic = true
            polyline.map = self
        }
    }
    
//MARK:- Camera Settings
    
    /**
     used to set the camera on map
     
     - parameter location: lat and long of the map
     - parameter zoom:     zoom level
     */
    func setCameraOfMap(_ location: (latitude: Double, longitude: Double), zoom: Float) {
        CATransaction.begin()
        CATransaction.setValue(NSNumber(value: 1.0), forKey: kCATransactionAnimationDuration)
        self.animate(to: GMSCameraPosition.camera(withLatitude: location.latitude, longitude: location.longitude, zoom: zoom))
        CATransaction.commit()
    }

    
//MARK:- Location Methods
    
    /**
     used to fetch the address through lat long
     
     - parameter shouldFindLocationWhenDraggMap: false(if user wants to fetch the address only for one time) true(if user wants to fetch the address whenever map dragged)
     - parameter shouldShowCenterMarker:         bool to show the center marker
     - parameter location:                       double value of latitude, double value of longitude
     - parameter handler:                        handler returns the Address Model
     */
    func findLocationWhenDragging(_ shouldFindLocationWhenDraggMap: Bool = true, shouldShowCenterMarker: Bool = true, location: (latitude: Double, longitude: Double), handler: @escaping AddressHandler) {
        locationDragHandler = handler
        self.shouldFindLocationWhenDragging = shouldFindLocationWhenDraggMap
        
        if shouldShowCenterMarker == true {
            showCenterMarker()
        }
        
        if shouldFindLocationWhenDraggMap == false {
           reverseGeocodeCoordinate(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
        }
    }
    
    /**
     fetchthe full string address of the place

     - parameter gLocation: Google address
     - returns: address string
     */
    
    fileprivate func fetchLocationAddressFromGoogle(_ gLocation: GMSAddress) -> NSIAddress? {
        guard let lines = gLocation.lines as [String]? else { return nil }
        return NSIAddress(streetName: lines[0], city: gLocation.locality, state: gLocation.administrativeArea, zipCode: gLocation.postalCode, country: gLocation.country)
    }
    
    
    /**
     private method which initialize the GMSGeocoder and give the address of the location
     - parameter location: lat and long
     */
    fileprivate func reverseGeocodeCoordinate(_ location: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(location) { response, error in
            if let gLocation: GMSAddress = response?.firstResult() {
                self.locationDragHandler!(self.fetchLocationAddressFromGoogle(gLocation), true)
            }
        }
    }


}

// MARK: - GMSMapViewDelegate
extension NSIMapView: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if shouldFindLocationWhenDragging == true {
            self.reverseGeocodeCoordinate(position.target)
        }
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if self.markerTouchHandler != nil {
            self.markerTouchHandler!((marker, mapView), NSITouchType.singleTouchOnMarker)
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if self.markerTouchHandler != nil {
            self.markerTouchHandler!((marker, mapView), NSITouchType.singleTouchOnInfo)
        }
    
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        if self.markerTouchHandler != nil {
            self.markerTouchHandler!((marker, mapView), NSITouchType.longTouchOnInfo)
        }
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        if self.infoWindowView != nil {
            return self.infoWindowView
        }
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        if self.markerTouchHandler != nil {
            self.markerTouchHandler!((marker, mapView), NSITouchType.closeTouchOnInfo)
        }
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if mapTouchHandler != nil {
            self.mapTouchHandler!((coordinates: (coordinate.latitude, coordinate.longitude), map: mapView), NSITouchType.singleTouchOnMap)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if mapTouchHandler != nil {
            self.mapTouchHandler!((coordinates: (coordinate.latitude, coordinate.longitude), map: mapView), NSITouchType.longTouchOnMap)
        }
    }
}
