//
//  NSIAutoCompletePlaces.swift
//  NSIMap
//
//  Created by prabhjot singh on 6/15/16.
//  Copyright © 2016 Prabhjot Singh. All rights reserved.
//

import UIKit
import GoogleMaps

/**
 *  model of color table settings
 */
struct AutoCompleteTableUIColorsSetting {
    var  tableBGColor: UIColor
    var  tableCellSeparatorColor: UIColor
    var  primaryTextColor: UIColor
    var  primaryHighlightColor: UIColor
    var  secondaryTextColor: UIColor
    var  tintColor: UIColor
}


class NSIAutoCompletePlaces: GMSAutocompleteViewController {
    var autoCompletePlaceHandler: CompletionHandler?
    
    /**
     used to present the GMSPlacesAutocompleteTypeFilter which show the table with searchbar
     
     - parameter colors:              model of color table settings
     - parameter controller:          view controller object
     - parameter autoCompleteHandler: handle the completion AnyObject and Bool
     */
    func openAutoCompletePlacesController(colors: AutoCompleteTableUIColorsSetting?, controller: UIViewController, autoCompleteHandler: CompletionHandler ) {
        self.autoCompletePlaceHandler = autoCompleteHandler
        if colors != nil {
            self.initializationUI(colors!)
        }
        self.autocompleteFilter?.type = GMSPlacesAutocompleteTypeFilter.NoFilter
        self.delegate = self
        controller.presentViewController(self, animated: true, completion: nil)
    }
    
    /**
     this is the private method which is used to initialize UI of table
     
     - parameter colors: model of color table settings
     */
    private func initializationUI(colors: AutoCompleteTableUIColorsSetting) {
        self.tableCellBackgroundColor = colors.tableBGColor
        self.tableCellSeparatorColor = colors.tableCellSeparatorColor
        self.primaryTextColor = colors.primaryTextColor
        self.primaryTextHighlightColor = colors.primaryHighlightColor
        self.secondaryTextColor = colors.secondaryTextColor
        self.tintColor = colors.tintColor
    }
}

// MARK: - GMSAutocompleteView Controller Delegates
extension NSIAutoCompletePlaces: GMSAutocompleteViewControllerDelegate {
    
// method invoke when click on the row if its success
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        if self.autoCompletePlaceHandler != nil {
            self.autoCompletePlaceHandler!(obj: place, success: true)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
// method invoke when click on the row if its not success
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        if self.autoCompletePlaceHandler != nil {
            self.autoCompletePlaceHandler!(obj: error, success: false)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
// User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
