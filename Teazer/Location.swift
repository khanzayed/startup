//
//  Location.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Location:NSObject, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager?
    var currentLocationStr:String?
    var currentLocArr = [CLLocation]()
    var lastLocation:CLLocation?
    
    typealias LocationEnabledBlock = (CLAuthorizationStatus) -> Void
    var locationEnabledBlock:LocationEnabledBlock?
    
    typealias LocationReceivedBlock = (CLLocation?, Error?) -> Void
    var locationReceivedBlock:LocationReceivedBlock?
    
    func initialiseLocationManager() {
        if locationManager == nil {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self
            self.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager!.requestWhenInUseAuthorization()
        } else {
            locationManager?.startUpdatingLocation()
        }
        
    }
    
    func deallocLocationManager() {
        self.locationManager = nil
    }
    
    func startUpdatingLocation() {
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.locationManager?.stopUpdatingLocation()
    }
    
    func isAuthorised() -> Bool {
        return (CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            self.locationManager!.requestWhenInUseAuthorization()
            stopUpdatingLocation()
            break
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation()
            break
        case .denied, .restricted:
            break
        }
        if let block = locationEnabledBlock {
            block(status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationReceivedBlock?(nil, error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocArr.append(location)
            
            if currentLocArr.count == 5 {
                self.stopUpdatingLocation()
                self.lastLocation = location
                locationReceivedBlock?(location, nil)
//                self.getAddressFromLocation(lastLocation: currentLocArr.last!)
                currentLocArr = [CLLocation]()
            }
        }
    }
    
    func isLocationEnabled() -> Bool {
        return (CLLocationManager.locationServicesEnabled()) ? true : false
    }
    
    func isLocationAccessDenied() -> Bool {
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
            return true
        }
        return false
    }
    
    func getAddressFromLocation(lastLocation:CLLocation) {
        self.currentLocationStr = nil
        self.lastLocation = lastLocation
        CLGeocoder().reverseGeocodeLocation(lastLocation, completionHandler: { [weak self] (placemarks, error) -> Void in
            
            if (placemarks?[0].addressDictionary as? [String:Any]) != nil {
//                let addressModal = AddressModal()
//                
//                addressModal.street = placemark["Street"] as? String
//                addressModal.zipCode = placemark["ZIP"] as? String
//                addressModal.country = placemark["Country"] as? String
//                addressModal.city = placemark["City"] as? String
//                addressModal.state = placemark["State"] as? String
//                addressModal.countryCode = placemark["CountryCode"] as? String
//                addressModal.latitute = "\(lastLocation.coordinate.latitude)"
//                addressModal.longitude = "\(lastLocation.coordinate.longitude)"
//                
//                if let addressArr = placemark["FormattedAddressLines"] as? [String] {
//                    var address = ""
//                    
//                    for line in addressArr {
//                        address += line + ", "
//                    }
//                    
//                    if address.characters.count > 0 {
//                        let endIndex = address.index(address.endIndex, offsetBy: -2)
//                        address = address.substring(to: endIndex)
//                        addressModal.mapAddress = address
//                        self?.currentLocationStr = address
//                        if let block = self?.locationReceivedBlock {
//                            block(addressModal)
//                            return
//                        }
//                    }
//                    
//                }
//            }
            }
            self?.locationReceivedBlock?(lastLocation, nil)
        })
    }
}
