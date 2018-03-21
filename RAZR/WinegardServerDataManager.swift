//
//  WinegardServerDataManager.swift
//  RAZR
//
//  Created by Joe Bakalor on 7/27/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//
//
//
//
//


import Foundation
import CoreLocation
import UIKit
import CoreData


var imageArray: [Int: [String: UIImage]] = [:]
var networkImageCallsigns: [Int: (image: UIImage?, callsign: String, distance: String, lat: String, lon: String)] = [:]

//moving to this variable nameing --> previous doesnt make sense
var networkDataByChannel: [Int: (image: UIImage?, callsign: String, distance: String, lat: String, lon: String, vchannel: String?)] = [:]
//var channelShowImages: [Int: [UIImage]] = [:]

//  ================================ BASE CLASS =================================
class WinegardServerDataManager: NSObject
{
    override init()
    {
        super.init()
    }
    /******************************************************************************/
    //  Constants
    /******************************************************************************/
    //let appServer                 = "http://www.winegard.com/apptest"
    let baseURL                     = URL(string: "http://www.winegard.com/apptest")!
    let appInfoBaseUrl              = "/appinfo.php"
    let customerInfoBaseUrl         = "/customers.php"
    let otaTowerInfoBaseUrl         = "/towers.php"
    let otaTowerBaseUrl             = URL(string: "http://www.winegard.com/apptest/towers.php")!
    let satelliteInfoBaseUrl        = "/satellites.php"
    
    struct TVShow{
        var name: String?
        var showImage: Data?
    }
    
    //var tvShow: Show?
    
    struct StationTower{
        var callsign: String?
        var location: String?
        var physicalChannel: String?
        var distance: String?
        var virtualChannel: String?
        var dateRetrieved: Date?
        var networkImage: Data?
        var shows: [TVShow] = []
        //var tvShows: [Show] = []
    }
    var towerDataByPhyChannel: [String : StationTower] = [:]
}





//  ===================== TOWER REQUEST/RESPONSE PROCESSES ========================
extension WinegardServerDataManager
{
    //  DATA STRUCTURES SPECIFIC TO TOWER REQUESTS/RESPONSES
    struct otaTowerInfoRequestParameters
    {
        enum RequestType{
            case towersByAddress
            case towersByAddressFull
            case towersByLatLong
            case towersByLatLongFull
            case towerDetail
        }
        
        struct LocationAddress{
            var streetName   = ""
            var streetNumber = ""
            var city         = ""
            var stateAbbrev  = ""
        }
        
        struct NotificationIDs{
            let towersByAddress     = "towersByAddress"
            let towersByAddressFull = "towersByAddressFull"
            let towersByLatLong     = "towersByLatLong"
            let towersByLatLongFull = "towersByLatLongFull"
            let towerDetail         = "towerDetail"
        }
        
        fileprivate var notificationID          = NotificationIDs.init()
        var requestType                         = RequestType.towerDetail
        var locationAddress                     = LocationAddress()
        var rangeInMiles: Int                   = 0
        var towerID: Int                        = 0
        var locationCoordinates: (latitude: Float, longitude: Float) = (0, 0)
        
        //PropertyKey definitions
        struct PropertyKey{
            static let band        = "band"
            static let callSign    = "callsign"
            static let channel     = "channel"
            static let city        = "city"
            static let distance    = "distance"
            static let id          = "id"
            static let latitude    = "latitude"
            static let longitude   = "longitude"
            static let network     = "network"
            static let vchannel    = "vchannel"
            //need to complete
        }
        
    }
    
    //==================== OTA DATA RESPONSE STRUCTURE ===========================
    struct responseDataEntry
    {
        struct show{
            var title: String
            var url: String
        }
        
        var band        : String
        var callSign    : String
        var channel     : String
        var city        : String
        var distance    : String
        var id          : String
        var latitude    : String
        var longitude   : String
        var network     : String
        var shows       : [[String: String]]?
        var url         : String?
        var vchannel    : String?
        
        init?(json: [String: Any])
        {
            guard let band      = json[otaTowerInfoRequestParameters.PropertyKey.band],
                let callSign    = json[otaTowerInfoRequestParameters.PropertyKey.callSign],
                let channel     = json[otaTowerInfoRequestParameters.PropertyKey.channel],
                let city        = json[otaTowerInfoRequestParameters.PropertyKey.city],
                let distance    = json[otaTowerInfoRequestParameters.PropertyKey.distance],
                let id          = json[otaTowerInfoRequestParameters.PropertyKey.id],
                let latitude    = json[otaTowerInfoRequestParameters.PropertyKey.latitude],
                let longitude   = json[otaTowerInfoRequestParameters.PropertyKey.longitude],
                let network     = json[otaTowerInfoRequestParameters.PropertyKey.network],
                let vchannel    = json[otaTowerInfoRequestParameters.PropertyKey.vchannel]
                else {return nil}
            
            self.band       = band as! String
            self.callSign   = callSign as! String
            self.channel    = channel as! String
            self.city       = city as! String
            self.distance   = distance as! String
            self.id         = id as! String
            self.latitude   = latitude as! String
            self.longitude  = longitude as! String
            self.network    = network as! String
            self.shows      = json["shows"] as? [[String: String]]
            self.url        = json["url"] as? String
            self.vchannel   = vchannel as? String
        }
        
    }

    //
    func submitOTATowerInfoRequest(requestParameters: otaTowerInfoRequestParameters)
    {
        var request      = "www.google.com"
        var url          = URL(string: request)
        var notification = ""
        //var task         = session.dataTask(with: url!)
        
        switch requestParameters.requestType{
        //====================================
        case .towerDetail: print("")
        
            let query: [String: String] = [
                "id" : "\(requestParameters.towerID)"]
        
            url          = otaTowerBaseUrl.withQueries(query)!
            notification = requestParameters.notificationID.towerDetail
        //print("URL: \(String(describing: url))")
            
        //====================================
        case .towersByAddress: print("")
        
            let query: [String: String] = [
                "address" : "\(requestParameters.locationAddress.streetNumber) \(requestParameters.locationAddress.streetName), \(requestParameters.locationAddress.city), \(requestParameters.locationAddress.stateAbbrev)",
                "range" : "\(requestParameters.rangeInMiles)"]
        
            url          = otaTowerBaseUrl.withQueries(query)!
            notification = requestParameters.notificationID.towersByAddress
        //print("URL: \(String(describing: url))")
            
        //====================================
        case .towersByAddressFull: print("")
        
            let query: [String: String] = [
                "address" : "\(requestParameters.locationAddress.streetNumber) \(requestParameters.locationAddress.streetName), \(requestParameters.locationAddress.city), \(requestParameters.locationAddress.stateAbbrev)",
                "range" : "\(requestParameters.rangeInMiles)",
                "details" : "full"]
        
            url          = otaTowerBaseUrl.withQueries(query)!
            notification = requestParameters.notificationID.towersByAddressFull
        
        //print("URL: \(String(describing: url))")
            
        //====================================
        case .towersByLatLong: print("")
        
            let query: [String: String] = [
                "lat" : "\(requestParameters.locationCoordinates.latitude)",
                "lon" : "\(requestParameters.locationCoordinates.longitude)",
                "range" : "\(requestParameters.rangeInMiles)"]
        
            url          = otaTowerBaseUrl.withQueries(query)!
            notification = requestParameters.notificationID.towersByLatLong
        
        //print("URL: \(String(describing: url))")
            
        //====================================
        case .towersByLatLongFull: print("")
        
            let query: [String: String] = [
                "lat" : "\(requestParameters.locationCoordinates.latitude)",
                "lon" : "\(requestParameters.locationCoordinates.longitude)",
                "range" : "\(requestParameters.rangeInMiles)",
                "details" : "full"]
        
            url          = otaTowerBaseUrl.withQueries(query)!
            notification = requestParameters.notificationID.towersByLatLongFull
        //print("URL: \(String(describing: url))")
        }
        
        sendRequest(forURL: url, notification: notification)

    }
}

//MARK: WINEGARD SERVER REQUEST
extension WinegardServerDataManager
{
    func sendRequest(forURL url: URL?, notification: String)
    {
        let session      = URLSession.shared
        var request      = "www.google.com"
        var mockurl      = URL(string: request)
        var task         = session.dataTask(with: mockurl!)
        
        task = session.dataTask(with: url!) { (data, response, error) -> Void in
            if error == nil {
                //print("REST_API Sending OTA Tower Information Request")
                var responseData: [responseDataEntry] = []
                //print("Response = \(String(describing: data?.hexEncodedString()))")
                
                if let data     = data,
                    let rawJSON     = try? JSONSerialization.jsonObject(with: data),
                    let json        = rawJSON as? [String: Any],
                    let fullData    = json["data"] as? [Any]{
                    
                    for item in fullData{
                        let newObject = responseDataEntry(json: item as! [String : Any])
                        responseData.append(newObject!)
                        //print("Unprocessed Object: \(String(describing: newObject))\r\r")
                    }
                }
                
                // Process JSON Data and retrieve images
                // This has all of our data
                self.processOtaTowerResponseDataForUse(data: responseData, completion: {
                    (argument, channel, title, image) in
                    imageArray[channel]![title] =  image
                })
                
                var notificationInfo: [String: AnyObject]?  = [:]
                notificationInfo!["notificationType"]       = notification as AnyObject
                
                //POST NOTIFICATION
                NotificationCenter.default.post(name: Notification.Name(rawValue: "otaTowerInfoRequestResponse"), object: self, userInfo: notificationInfo)
            } else {
                //print("ERROR = \(String(describing: error))")
            }
        }
        task.resume()
        //print("COMPLETED REQUEST = \(request)")
    }
}

//MARK: DOWNLOAD NETWORK AND SHOW IMAGES
extension WinegardServerDataManager
{
    /******************************************************************************/
    // download show images
    /******************************************************************************/
    func processOtaTowerResponseDataForUse(data: [responseDataEntry], completion: @escaping ([String: UIImage], Int, String, UIImage) -> Void){
        
        var networkImageUrls: [Int: (url: String?, callsign: String, distance: String, lat: String, lon: String)] = [:]
        var networkDataItems: [Int: (url: String?, callsign: String, distance: String, lat: String, lon: String, vchannel: String?)] = [:]
        let session = URLSession.shared
        var showImages: [String: UIImage] = [:]
        
        
        //each item represents a tower
        for item in data{
            
            //create new tower struct for each tower to add
            var newTower = StationTower()
            //populate information we have now
            newTower.callsign = item.callSign
            newTower.location = "\(item.latitude) \(item.longitude)"
            newTower.physicalChannel = item.channel
            newTower.virtualChannel = item.vchannel
            newTower.distance = item.distance
            newTower.dateRetrieved = Date()
            //we don't have network image yet
            //we don't have show images yet
            
            //now add tower to our tower dictionary
            towerDataByPhyChannel[item.channel] = newTower
            
            //  Check for valid network image url
            if let networkUrl = item.url{
                networkImageUrls[Int(item.channel)!] = (networkUrl, item.callSign, item.distance, item.latitude, item.longitude)
                networkDataItems[Int(item.channel)!] = (networkUrl, item.callSign, item.distance, item.latitude, item.longitude, item.vchannel)
            } else {
                networkImageUrls[Int(item.channel)!]  = (nil, item.callSign, item.distance, item.latitude,item.longitude)
                networkDataItems[Int(item.channel)!] = (nil, item.callSign, item.distance, item.latitude, item.longitude, item.vchannel)
            }
            
            //check if shows data available
            if let shows = item.shows{
                for show in shows{
                    //  Add http:// to string otherwise request will fail
                    let showURL  = "\(show["url"]!)"
                    //print("SHOW URL \(showURL)")
                    //  Convert to formatted url
                    let imageURL = URL(string: showURL)!
                
                    //  Create new network task to download show images
                    let downloadPicTask = session.dataTask(with: imageURL) { (data, response, error) in
                        
                        if let e = error{
                            //print("Error downloading show image \(e)")
                        } else {
                            
                            if let res = response as? HTTPURLResponse{
                                //print("Download image with response code: \(res.statusCode)")
                                if let imageData = data{
                                    
                                    let image                       = UIImage(data: imageData)
                                    
                                    //FIXED 10-20-17
                                    //Looks like we are getting bad data from the server
                                    if let notBroken = image{
                                        showImages["\(show["title"]!)"] = notBroken
                                    }
                                    //showImages["\(show["title"]!)"] = image!
                                    
                                    var newShow = TVShow()
                                    newShow.name = show["title"]!
                                    newShow.showImage = imageData
                                    
                                    //add each show for the current tower struct
                                    self.towerDataByPhyChannel[item.channel]?.shows.append(newShow)
                                    
                                } else {
                                    //print("Couldn't get image file, image is nil")
                                }
                            } else {
                                //print("Couldnt get response code for some reason")
                            }
                        }
                        
                        completion(showImages, Int(item.channel)!, show["title"]!, showImages["\(show["title"]!)"]!)//  Run completion handler
                    }
                    downloadPicTask.resume()//  Start task
                }
                
            }
            imageArray[Int(item.channel)!] = showImages;
            
        }
        getNetworkImages(networkData: networkDataItems, completion: {
            (channel, callsign, image, distance, lat, lon, vchannel, data) in
            networkImageCallsigns[channel] = (image, callsign, distance, lat, lon)
            networkDataByChannel[channel] = (image, callsign, distance, lat, lon, vchannel)
            
            //print("Processed Newtork Image")
        })
    }
    
    
    //  download network images
    func getNetworkImages(networkData: [Int: (url: String?, callsign: String, distance: String, lat: String, lon: String, vchannel: String?)], completion: @escaping (Int, String, UIImage, String, String, String, String?, Data) -> Void)
    {
        let session = URLSession.shared
        for item in networkData{
            
            if let validUrl = item.value.url{
                
                let url = URL(string: validUrl)!
                //print("NETWORK IMAGE URL = \(url)")
                
                let downloadNetworkImageTask = session.dataTask(with: url) { (data, response, error) in
                    
                    if let e = error{
                        
                        //print("\(e)Error downloading newtwork image")
                        
                    } else {
                        
                        if let res = response as? HTTPURLResponse{
                            
                            //print("Downloaded network image with response \(res.statusCode)")
                            
                            if let imageData = data{
                                let image = UIImage(data: imageData)
                                
                                //save network image for tower
                                self.towerDataByPhyChannel["\(item.key)"]?.networkImage = imageData
                                
                                self.saveTowerDataOnMainThread(towerData: self.towerDataByPhyChannel["\(item.key)"]!)
                                //save tower data to coredata here if there was a valid network image
                                //print("Stored Tower Data Response \(self.towerDataByPhyChannel)\r\r")
                                
                                completion(item.key,
                                           item.value.callsign,
                                           image!,
                                           item.value.distance,
                                           item.value.lat,
                                           item.value.lon,
                                           item.value.vchannel,
                                           imageData)
                            }
                            
                        } else {
                            //print("Couldn't get response code for some reason")
                        }
                    }
                }
                downloadNetworkImageTask.resume()
                
            } else {
                saveTowerDataOnMainThread(towerData: towerDataByPhyChannel["\(item.key)"]!)
                //save tower data to coredata here if ther isnt a valid network image
                networkImageCallsigns[item.key] =  (nil, item.value.callsign, item.value.distance, item.value.lat, item.value.lon)
                networkDataByChannel[item.key] =  (nil, item.value.callsign, item.value.distance, item.value.lat, item.value.lon, item.value.vchannel)
            }
        }
    }
    
    
}

//MARK:  CORE DATA SAVING
extension WinegardServerDataManager
{
    //SAVE TOWER DATA RECIEVED FROM WINEGARD SERVER TO COREDATA, NEEDS TO BE SAVED ON MAIN THREAD
    func saveTowerDataOnMainThread(towerData: StationTower)
    {
        //print("SAVE TOWER DATA ENTRY ON MAIN THREAD")
        DispatchQueue.main.async {
            
            let context = AppDelegate.viewContext
            
            //CHECK IF TOWER EXISTS
            let request: NSFetchRequest<Tower> = Tower.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "location", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
            let predicate = NSPredicate(format: "location = %@", towerData.location!)
            request.predicate = predicate
            request.sortDescriptors = [sortDescriptor]
            
            //if we alread have data for that tower, don't save the data
            // should probably have a date check and if the data is older than a certain date, refresh the data
            guard let towerEntry = try? context.fetch(request) else {print("Invalid access error)"); return}
            
            if towerEntry.count != 0{
                
                //print("We already have data for that tower, but check if the new data is closer??")
                
                //towerEntry is the data we have from a previous server request, lets check the date
                //if the data we have is more than 30 minutes old and we have a new entry, replace data
                //with new
                
                var deleteAndReplace = false
                //need to add additional checks here to make sure we dont unwrap nil data
                //if its older than 30 minutes, replace, otherwise if it's closer, replace
                if ((towerEntry.first?.dateRetrieved?.timeIntervalSinceNow)!/60) > 30{
                    //so we know the data we had was older than 30 minutes
                    //delete the old data and save the new data
                    //print("THE TOWER DATA WE HAVE RIGHT NOW IS OLDER THAN 30 MINUTES, SO REPLACE")
                    deleteAndReplace = true
                //check if distance from the existing data is greater than the new data.
                //if it is, than delete existing and replace with new data
                } else if (Float((towerEntry.first?.distance)!)! > Float(towerData.distance!)!) {
                    //print("THE DISTANCE FOR THE TOWER DATA WE HAVE IS FARTHER THAN THE NEW DATA SO REPLACE WITH THE NEW DATA")
                    deleteAndReplace = true
                }
                
                
                guard deleteAndReplace == true else { return }
                
                //delete the existing data
                for object in towerEntry{
                    context.delete(object)
                }
                
                //print("DELETE OLD TOWER DATA AND REPLACE WITH NEW DATA")
                
                let tower = Tower(context: context)
                
                tower.callSign = towerData.callsign
                tower.dateRetrieved = towerData.dateRetrieved
                tower.location = towerData.location
                tower.distance = towerData.distance
                tower.physicalChannel = towerData.physicalChannel
                tower.virtualChannel = towerData.virtualChannel
                //print("Store Network Image in CoreData")
                
                if let ntwrkImage = towerData.networkImage{
                    tower.networkImage = ntwrkImage//NSData(data: ntwrkImage)
                }
                
                for show in towerData.shows{
                    let newShow = Show(context: context)
                    newShow.image = show.showImage!//NSData(data: show.showImage!)
                    newShow.name = show.name
                    //print("Add show to shows")
                    tower.addToShows(newShow)
                }
                
                do {
                    try context.save()
                } catch {
                    //print("Error)")
                }

                
            } else {
                
                //print("This is a new tower so save the data")
                
                let tower = Tower(context: context)
                
                tower.callSign = towerData.callsign
                tower.dateRetrieved = towerData.dateRetrieved
                tower.location = towerData.location
                tower.distance = towerData.distance
                tower.physicalChannel = towerData.physicalChannel
                tower.virtualChannel = towerData.virtualChannel
                //print("Store Network Image in CoreData")
                
                if let ntwrkImage = towerData.networkImage{
                    tower.networkImage = ntwrkImage//NSData(data: ntwrkImage)
                }
                
                for show in towerData.shows{
                    let newShow = Show(context: context)
                    newShow.image = show.showImage!//NSData(data: show.showImage!)
                    newShow.name = show.name
                    //print("Add show to shows")
                    tower.addToShows(newShow)
                }
                
                do {
                    try context.save()
                } catch {
                    //print("Error)")
                }
                
                //print("TOWER ENTRY: \(tower)")
            }
        }
    }

}


//MARK: REST API DATA STRUCTURES
extension WinegardServerDataManager
{
    /******************************************************************************/
    //  Application Information
    /******************************************************************************/
    struct appInfoRequestParameters
    {
        enum RequestType{
            case version
            case revisions
            case termsAndConditions
            case termsAndConditionsVersion
            case supportLink
        }
        
        enum mobileOS{
            case iOS
            case android
            case notSet
        }
        
        var requestType = RequestType.version
        var osType: mobileOS = .iOS//can't imagine we will ever using anything else here;)
        var osVersion: String = ""
    }
    
    /******************************************************************************/
    //  Customer Information
    /******************************************************************************/
    struct customerInfoRequestParameters
    {
        var customerEmail: String = ""
    }
    
    /******************************************************************************/
    //  Satellite Information
    /******************************************************************************/
    struct satelliteInfoRequestParameters
    {
        enum RequestType{
            case providers
            case satellites
            case satellitesFull
        }
        
        var requestType = RequestType.providers
        var locationCoordinates: (latitude: Float, longitude: Float) = (0, 0)
    }
    
    
}
//  ===================== ADD/REMOVE OBSERVERS ===========================
extension WinegardServerDataManager
{
    func addObservers()
    {
        //NotificationCenter.default.addObserver(self, selector: #selector(self.processServerResponse), name: NSNotification.Name(rawValue: "foundPeripheralID"), object: nil)
    }
    
    func removeObervers()
    {
        
    }
    
}

extension URL {
    func withQueries(_ queries: [String: String]) -> URL?{
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.flatMap({
            URLQueryItem(name: $0.0, value: $0.1)
        })
        return components?.url
    }
    
}



//  Create Request Task
//        task = session.dataTask(with: url!) { (data, response, error) -> Void in
//            if error == nil {
//                print("REST_API Sending OTA Tower Information Request")
//                var responseData: [responseDataEntry] = []
//                //print("Response = \(String(describing: data?.hexEncodedString()))")
//
//                if let data     = data,
//                let rawJSON     = try? JSONSerialization.jsonObject(with: data),
//                let json        = rawJSON as? [String: Any],
//                let fullData    = json["data"] as? [Any]{
//
//                    for item in fullData{
//                        let newObject = responseDataEntry(json: item as! [String : Any])
//                        responseData.append(newObject!)
//                        print("Unprocessed Object: \(String(describing: newObject))\r\r")
//                    }
//                }
//
//                // Process JSON Data and retrieve images
//                // This has all of our data
//                self.processOtaTowerResponseDataForUse(data: responseData, completion: {
//                    (argument, channel, title, image) in
//                    imageArray[channel]![title] =  image
//                })
//
//                var notificationInfo: [String: AnyObject]?  = [:]
//                notificationInfo!["notificationType"]       = notification as AnyObject
//
//                //POST NOTIFICATION
//                NotificationCenter.default.post(name: Notification.Name(rawValue: "otaTowerInfoRequestResponse"), object: self, userInfo: notificationInfo)
//            } else {
//                print("ERROR = \(String(describing: error))")
//            }
//        }
//        task.resume()
//        print("COMPLETED REQUEST = \(request)")






