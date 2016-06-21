//
//  ViewController.swift
//  NSIMap
//
//  Created by prabhjot singh on 6/2/16.
//  Copyright © 2016 Prabhjot Singh. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

// Simpe View with label
class CustomView: UIView {
    var myLabel: UILabel?
    override init(frame: CGRect) {
        super.init(frame:frame)
        myLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 180, height: 80))
        myLabel?.font = UIFont.systemFontOfSize(10)
        myLabel?.numberOfLines = 8
        myLabel?.textColor = UIColor.blueColor()
        addSubview(myLabel!)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}



class ViewController: UIViewController {

    @IBOutlet weak var mapViewHome: NSIMapView!
    let locations = [CLLocationCoordinate2D(latitude: 21, longitude: 12), CLLocationCoordinate2D(latitude: 12, longitude: 12), CLLocationCoordinate2D(latitude: 32, longitude: 543), CLLocationCoordinate2D(latitude: 45, longitude: 45), CLLocationCoordinate2D(latitude: 24, longitude: 53), CLLocationCoordinate2D(latitude: 78, longitude: 53), CLLocationCoordinate2D(latitude: 75, longitude: 24)]
    let zoomDefault: Float = 13
    override func viewDidLoad() {
        super.viewDidLoad()
    //used to fetch the address through lat long
        mapViewHome.findLocationWhenDragging(true, shouldShowCenterMarker:true, location: (latitude: 30, longitude: 40)) { (obj, success) in
            guard let nsiAddress: NSIAddress  = obj else { return }
            print(nsiAddress.fullAddress)
        }
        
        
        
    //used to draw the route on map
        let startlocationPin = NSIMarker(location: (latitude: 12.271171, longitude: 78.249427))
        let endlocationPin = NSIMarker(location: (latitude: 30.423257, longitude: 76.876900))
        mapViewHome.drawRoute(startlocationPin, endLocationMarker:endlocationPin, shouldShowMarker: true) { (mapRoute: NSIMapRoute) in
        }
        
        
        
    //this method is used when user wants to enable touch event on the marker and on marker info. user may also send the infoWindowview here
        let customeView = CustomView(frame: CGRectMake(0, 0, 200, 200))
        mapViewHome.touchOnMarkerOrInfoWindow(customeView) { (markerAndMap, touchType) in
            if touchType == .SingleTouchOnMarker {
                customeView.myLabel?.text = "coordinates - \(markerAndMap.marker.position)"
            }
        }
        
        
        
    //this method is used when user wants to enable touch event on the map
        mapViewHome.touchOnMap { (coordinateAndMap, touchType) in
            if touchType == .LongTouchOnMap {
                self.singleMarkerCreation(coordinateAndMap.coordinates)
            }
        }
    }
    @IBAction func toChangeMapType(sender: AnyObject) {
    //used change the style of the map
        mapViewHome.nsiMapType = .SatteliteMap
    }
    @IBAction func toCreateMultipleMarkers(sender: AnyObject) {
        
    // multiple marker creation
        let nsiMarkers = NSIMarker.markersOfLocation(locations)
        mapViewHome.createMultipleMarkers(nsiMarkers) {
        }
    }

    @IBAction func toCreateMarker(sender: AnyObject) {
    //For more customization use following code
        var marker: NSIMarker {
            var marker = NSIMarker(location: (latitude: 23, longitude: 452))
            marker.markerColor = UIColor.blueColor()
            marker.markerIcon = UIImage(named: "centerMarker")
            marker.markerOtherInfo = NSArray(objects: "Hello")
            return marker
        }
        mapViewHome.createMarker(marker) {
            self.mapViewHome.setCameraOfMap((latitude: marker.markerLocation.latitude, longitude: marker.markerLocation.longitude), zoom: self.zoomDefault)
        }
    }
    func singleMarkerCreation(location:(latitude: Double, longitude: Double)) {
// simple marker creation
        mapViewHome.createMarker(NSIMarker(location: location), completed: {
//            self.mapViewHome.setCameraHOLHOLOfMap(location, zoom: self.zoomDefault)
        })
    }
    @IBAction func toChangeSpeed(sender: AnyObject) {
    //used to change the speed of the map
        mapViewHome.nsiMapSpeed = .Slow
    }
//used to show/hide the center marker
    @IBAction func toRemoveORCreateCMarker(sender: UIButton) {
        if sender.tag == 1 {
            sender.tag = 2
            mapViewHome.hideCenterMarker()
        } else {
            sender.tag = 1
            mapViewHome.showCenterMarker()
        }
    }
//used to present the GMSPlacesAutocompleteTypeFilter which show the table with searchbar
    @IBAction func toShowNSIAutoCompletePlaces(sender: UIButton) {
        let autoCompletePlaces = NSIAutoCompletePlaces()
        
        let colorSettings = AutoCompleteTableUIColorsSetting(tableBGColor:UIColor.redColor(), tableCellSeparatorColor: UIColor.yellowColor(), primaryTextColor: UIColor.greenColor(), primaryHighlightColor: UIColor.orangeColor(), secondaryTextColor: UIColor.grayColor(), tintColor: UIColor.blueColor())
        autoCompletePlaces.openAutoCompletePlacesController(colorSettings, controller: self) { (obj, success) in
            if success == true {
                print("--- coordinates = \(obj.coordinate)")
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
