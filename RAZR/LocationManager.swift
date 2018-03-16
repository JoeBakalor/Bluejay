//
//  LocationManager.swift
//  RAZR
//
//  Created by Joe Bakalor on 8/19/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate{
    var lastLocation: CLLocation? { get }
}


//MARK: BASE CLASS
class LocationManager: NSObject
{
    //VARIABLES
    var localLocationManager: CLLocationManager!
    var lastLocation: CLLocation?

    //INITIALIZE CLASS
    override init()
    {
        super.init()
        configureLocationManager()
    }
    
    //CONFIGURE LOCATION MANAGER
    func configureLocationManager()
    {
        localLocationManager = CLLocationManager()
        localLocationManager.delegate = self
        localLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.authorizationStatus() == .notDetermined{
            localLocationManager.requestWhenInUseAuthorization()//requestAlwaysAuthorization()
        }
        
        //attempt to get current location
        if CLLocationManager.locationServicesEnabled(){
            localLocationManager.requestLocation()
        }
        
        testTowerDataForBuggyLocation()
    }
}


//MARK: 
extension LocationManager: CLLocationManagerDelegate
{
    //REQUEST LOCATION UPDATE
    func updateLocation()
    {
        if CLLocationManager.locationServicesEnabled(){
            //Request current location
            localLocationManager.requestLocation()
        }
    }
}


//MARK:  LOCATION MANAGER DELEGATE METHODS
extension LocationManager
{

    //LOCATIONS WERE UPDATED
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        print("LOCATION UPDATE RECIEVEC")
        lastLocation = locations.first
        updateTowerDataForCurrentLocation()
    }
    
    //LOCATION AUTHORIZTION CHANGED
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        print("didChangeAuthorization")
    }
    
    //LOCATION MANAGER FAILED WITH ERROR
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("didFailWithError")
    }
    
    //HEADING WAS UPDATED
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading)
    {
        print("didUpdateHeading")
    }
    
    //LOCATION MANAGER DID RANGE BEACONS
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion)
    {
        print("didRangeBeacons")
    }
    
}

//MARK:
extension LocationManager
{
    func updateTowerDataForCurrentLocation()
    {
        var newRequest = WinegardServerDataManager.otaTowerInfoRequestParameters()
        
        if let location = lastLocation
        {
            print("Send OTA Tower Request")
            newRequest.requestType = .towersByLatLongFull
            newRequest.locationCoordinates.latitude = Float(location.coordinate.latitude)
            newRequest.locationCoordinates.longitude = Float(location.coordinate.longitude)
            newRequest.rangeInMiles = 125
            winegardServerDataManager.submitOTATowerInfoRequest(requestParameters: newRequest)
        }
        
    }
    
    func testTowerDataForBuggyLocation()
    {
        //{
            var newRequest = WinegardServerDataManager.otaTowerInfoRequestParameters()

                print("Send TEST TEST OTA Tower Request")
                newRequest.requestType = .towersByLatLongFull
                newRequest.locationCoordinates.latitude = 40.8205678//Float(location.coordinate.latitude)
                newRequest.locationCoordinates.longitude = -91.1407439//Float(location.coordinate.longitude)
                newRequest.rangeInMiles = 175
                winegardServerDataManager.submitOTATowerInfoRequest(requestParameters: newRequest)
            
    }
}


//http://www.winegard.com/apptest/towers.php?lon=-91.1407439&range=75&details=full&lat=40.8205678





















