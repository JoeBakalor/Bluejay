//
//  MapViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 7/18/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit
import MapKit

// =======================  Base Class =========================
class MapViewController: UIViewController, MKMapViewDelegate
{
    //  IBOUTLETS
    @IBOutlet weak var mapView: MKMapView!
    //  VARIABLES
    var collectionView: UICollectionView!
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var detailView: CustomMapDetailView!
    var detailViewSetupComplete = false
    var circlesAdded = false
    var locationSet = false
    var towerLocation: [(location: CLLocationCoordinate2D, callSign: String)] = []
    var mapViewFinishedLoading = false
    var selectedView: MKAnnotationView?
    //  CONSTANTS
    let initialLocation = CLLocation(latitude: 40.8205638, longitude: -91.1407439)
    let regionRadius: CLLocationDistance = 25000
    let BASE_URL = "http://www.winegard.com/apptest/"
    let TOWER_TEST = "towers.php?address=3000%20kirk wood%20street,%20burlington,%20ia&range=50"
    var towerEntryInDB: Tower?
    let coreDataController = CoreDataController()
}

//MARK: VIEW SETUP
extension MapViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.isZoomEnabled = true
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        centerMapOnLocation(location: initialLocation)
        // Do any additional setup after loading the view.
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        //addCircles()
        mapView.delegate = self //as! MKMapViewDelegate
        
        if CLLocationManager.authorizationStatus() == .notDetermined{
            locationManager.requestWhenInUseAuthorization()//requestAlwaysAuthorization()
        }
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        
        //unafe usage --> need to move
        for item in networkDataByChannel{
            print("\(item)")
            print("Latitude: \(item.value.lat) Longitude: \(item.value.lon)")
            let neLoc = CLLocationCoordinate2D(latitude: Double(item.value.lat)!, longitude: Double(item.value.lon)!)
            towerLocation.append((neLoc, item.value.callsign))
        }
    }
    
    /***************************************************************************/
    //
    /***************************************************************************/
    override func viewDidLayoutSubviews()
    {
        print("")
        if detailViewSetupComplete == false{
            setupDetailView()
        }
        
    }
    
    //SETUP MAP DETAIL VIEW
    func setupDetailView()
    {
        //- customSize.height - 10
        let customSize = CGSize(width: self.view.frame.width - 20, height: 200)// (self.view.frame.height/4))
        let customPoint = CGPoint(x: self.view.frame.origin.x + 10, y: self.view.frame.height)
        detailView = CustomMapDetailView(frame: CGRect(origin: customPoint, size: customSize))
        detailView.backgroundColor = UIColor.winegardBlue
        detailView.layer.opacity = 0.9
        detailViewSetupComplete = true
        detailView.layer.masksToBounds = true
        detailView.layer.cornerRadius = 6
        
        self.view.addSubview(detailView)
        
    }
    
    //SHOW MAP DETAIL VIEW
    func showDetailView()
    {
        if !detailView.isShown{
            UIView.animate(withDuration: 0.5, animations: {
                self.detailView.frame.origin.y -= (self.detailView.frame.size.height + 10)
            })
            detailView.isShown = true
        }
    }
    
    //HIDE MAP DETAIL VIEW
    func hideDetailView()
    {
        if detailView.isShown{
            UIView.animate(withDuration: 0.5, animations: {
                self.detailView.frame.origin.y += (self.detailView.frame.size.height + 10)
            })
            detailView.isShown = false
        }

    }
}

//MARK: LOCATION RELATED
extension MapViewController: CLLocationManagerDelegate
{
    //LOCATION MANAGER UPDATED LOCATIONS
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if !locationSet{
            locationSet = true
            currentLocation = locationManager.location
            centerMapOnLocation(location: currentLocation!)
            mapView.showsUserLocation = true

            for item in towerLocation{
                
                //let customPoint = MKMarkerAnnotationView()
                let annotation = MKPointAnnotation()

                annotation.coordinate = item.location
                let newDistance = currentLocation?.distance(from: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
                let formattedDistance = Int(newDistance! * 0.00062)
                annotation.title = item.callSign
                annotation.subtitle = "\(formattedDistance) mi"
                //var test = MKMapItem()
                
                
                mapView.addAnnotation(annotation)
                //mapView.selectAnnotation(annotation, animated: true)
                print("Add location")
            }
        }
  
    }
    
    //OVERLAY RENDERER
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("is rendererForOverlay being called???")
        if overlay.isKind(of: MKCircle.self){
            
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            
            switch overlay.title!!{
            case "primaryCircle": print("was able to identify primary circle")
                circleRenderer.fillColor = UIColor.winegardGreen.withAlphaComponent(0.75)
                
            case "secondaryCircle":
                circleRenderer.fillColor = UIColor.winegardYellow.withAlphaComponent(0.125)
                
            case "tertiaryCircle":
                 circleRenderer.fillColor = UIColor.winegardRed.withAlphaComponent(0.125)
                
            default:print("Probs wont work")
            }
            print("Added circle overlay")
            
            //.blueColor().colorWithAlphaComponent(0.1)
            
            circleRenderer.lineWidth = 1
            return circleRenderer
            
        } else {
            return MKOverlayRenderer(overlay: overlay)
        }
    }
    
    //ADD COLORED CIRCLES AROUND USER LOCTATION TO INDICATE WHICH TOWERS ARE IN RANGE
    func addCircles()
    {
        let primaryCircle =  MKCircle(center: mapView.userLocation.coordinate, radius: 20000)
        primaryCircle.title = "primaryCircle"
        
        let secondaryCircle =  MKCircle(center: mapView.userLocation.coordinate, radius: 30000)
        secondaryCircle.title = "secondaryCircle"
        
        let tertiaryCircle =  MKCircle(center: mapView.userLocation.coordinate, radius: 40000)
        tertiaryCircle.title = "tertiaryCircle"
        
        mapView.addOverlays([tertiaryCircle, secondaryCircle, primaryCircle ])
        //mapView.renderer(for: userCenterCircle)
    }
}

//MARK: MAP VIEW SETUP
extension MapViewController
{

    //FORCE CENTER MAP ON SPECIFIED LOCATION
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    /***************************************************************************/
    //
    /***************************************************************************/
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
                    //addCircles()
                    //return nil so map view draws "blue dot" for standard user location
                    return nil
        }
        print("Is this even called")
        
        
        let reuseId = "pin"
        let newDistance = currentLocation?.distance(from: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
        //annotation.title!! = annotation.title + "\(newDistance)"
        let  pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        var image = UIImage(named: "RadioTower")!
        let rr = CGRect(x: 0, y: 0, width: 55, height: 55)
        let size = CGSize(width: 55, height: 55)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        pinView.image = newImage!
        
        pinView.canShowCallout = true
        return pinView
        
    }
    
    /***************************************************************************/
    //
    /***************************************************************************/
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView)
    {
        mapViewFinishedLoading = true
        if !circlesAdded{
            circlesAdded = true
            addCircles()
        }
        
    }

    /***************************************************************************/
    //
    /***************************************************************************/
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView)
    {
        guard let testView = selectedView else { return }
        if testView == view{
            
            hideDetailView()
            detailView.isShown = false
            print("hide detail view")
        }
        
    }

    /***************************************************************************/
    //
    /***************************************************************************/
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        //print("View selected")
        var showImages: [UIImage] = []
        if view is MKUserLocation {print("User location")}
        
        if mapViewFinishedLoading{
            
            selectedView = view
            showDetailView()
            var callSign = view.annotation?.title
            let coordinate = view.annotation!.coordinate
            let location = "\(coordinate.latitude) \(coordinate.longitude)"
            //let towerDataFromDB = coreDataController.retrieveTowerEntryUsing(retrieveByOption: .location, optionValue: location)
            let towerDataFromDB = coreDataController.retrieveTowerEntryUsing(retrieveByOption: .callSign, optionValue: "\(callSign!!)")
            if let towerData = towerDataFromDB
            {
                towerEntryInDB = towerData
                print("Found data for tower in DB")

                detailView.callSign = towerData.callSign!
                print("Update labels")
                detailView.channel = "CH: \(towerData.virtualChannel!)-1 (\(towerData.physicalChannel!))"
                detailView.towerDistance = "\(towerData.distance!) mi"
                detailView.setNeedsDisplay()
                
                if towerData.networkImage != nil{
                    detailView.imageIcon = UIImage(data: towerData.networkImage! as Data)!//towerData.networkImage
                    print("NEW IMAGE")
                    //detailView.draw(detailView.frame)
                    detailView.setNeedsDisplay()
                    //detailView.setNeedsLayout()
                    
                    if let shows = towerData.shows{
                        for show in shows{
                            
                            let data = show as! Show
                            //var data = image as! Data
                            showImages.append(UIImage(data: data.image! as Data)!)
                            print("Retrieved show image from CoreData Successfully")
                        }
                        detailView.showImages = showImages//widgetImages = imagesFromServer
                        detailView.reloadCollectionData()
                    } else {
                        detailView.showImages = detailView.defaultImages
                    }
                    
                }

            }
            //38.52972 -90.299446
            detailView.isShown = true
            print("show detail view")
        }
    }
    
    
}











