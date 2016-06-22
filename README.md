# NSIMap
NSIMap is view class which is inherited from GMSMapView (Google Map). It is a helper class in which user can implement google map and there functions very easily.
## Usage
List of functionalities are:-
## Location
user can search location while dragging the map and also can see the list of location with searching on search bar

**findLocationWhenDragging**

***documentation***

     used to fetch the address through lat long
     
     - parameter shouldFindLocationWhenDraggMap: false(if user wants to fetch the address only for one time) true(if user wants to fetch the address whenever map dragged)
     - parameter shouldShowCenterMarker:         bool to show the center marker
     - parameter location:                       double value of latitude, double value of longitude
     - parameter handler:                        handler returns the Address Model

***Implementation***

```

mapViewHome.findLocationWhenDragging(true, shouldShowCenterMarker:true, location: (latitude: 30, longitude: 40)) { (obj, success) in
 guard let nsiAddress: NSIAddress  = obj else { return }
 print(nsiAddress.fullAddress)
}

```

**GMSPlacesAutocompleteTypeFilter**

***Documentation***

     used to present the GMSPlacesAutocompleteTypeFilter which show the table with searchbar
     
     - parameter colors:              model of color table settings
     - parameter controller:          view controller object
     - parameter autoCompleteHandler: handle the completion AnyObject and Bool

***Implementation***

```
    @IBAction func toShowNSIAutoCompletePlaces(sender: UIButton) {
        let autoCompletePlaces = NSIAutoCompletePlaces()
        
        let colorSettings = AutoCompleteTableUIColorsSetting(tableBGColor:UIColor.redColor(), tableCellSeparatorColor: UIColor.yellowColor(), primaryTextColor: UIColor.greenColor(), primaryHighlightColor: UIColor.orangeColor(), secondaryTextColor: UIColor.grayColor(), tintColor: UIColor.blueColor())
        autoCompletePlaces.openAutoCompletePlacesController(colorSettings, controller: self) { (obj, success) in
            if success == true {
                print("--- coordinates = \(obj.coordinate)")
            }
        }
    }
    
```

##Marker and Map

Markers can be easily created with one line and can be customize according to the requirement. Markers and Map related events are given bellow.
  
  **Marker Creation**
  
  ***Documentation***
  
     used to create the google marker through NSIMarker
     
     - parameter nsiMarker: model which is used to store the google marker type values
     - parameter completed: closure which returns success
  
  ***Implementation***
  
```
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
        })
    }
    
    @IBAction func toCreateMultipleMarkers(sender: AnyObject) {
    // multiple marker creation
        let nsiMarkers = NSIMarker.markersOfLocation(locations)
        mapViewHome.createMultipleMarkers(nsiMarkers) {
         //Completion Block
        }
    }
```

**Marker and Map Events**

All the touch events on map and marker will be implemented in one line of code
    
***Documentation***
    
****touchOnMarkerOrInfoWindow****
     this method is used when user wants to enable touch event on the marker and on marker info. user may also send the infoWindowview here
     
     - parameter infoWindowView:       view which invoke when user click on the marker
     - parameter markerTouchCompleted: handler which gives the marker, Map and touch event
    
****touchOnMap****
    this method is used when user wants to enable touch event on the map
    
     - parameter mapTouchCompleted: handler which gives the map, coordinates and the touch event
     
***Implementation***
    

```
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
```
## Author
Prabhjot Singh
## License
NSIMap is available under the MIT license. See the LICENSE file for more info
