//
//  DeviceSelectorViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/5/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit
import CoreBluetooth

let debug = true
var connectedWinegardDevice = WinegardDevice()
var workingPeripheral: CBPeripheral?

class DeviceSelectorViewController: UIViewController
{
/**********************************************************************************/
//
//                         Variable, Constants and UIOutlets
//
/**********************************************************************************/
    /*============================================================================*/
    //  IBOutlets
    /*============================================================================*/
    @IBOutlet weak var availableDevicesTable: UITableView!
    @IBOutlet weak var viewLabel: UILabel!
    /*============================================================================*/
    //  Variables
    /*============================================================================*/
    var listOfPeripherals: [AnyObject] = []
    var listOfPeripheralsCopy: [AnyObject] = []  //used to check for duplicate entries
    var duplicateFound: Bool = false
    var timer = Timer()
    var bluetoothReady: Bool = false
    /*============================================================================*/
    //  Constants
    /*============================================================================*/
/**********************************************************************************/
//
//                          View Setup and Teardown
//
/**********************************************************************************/
    /*============================================================================*/
    //  First function called when view loads
    /*============================================================================*/
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addObservers()
        viewLabel.layer.cornerRadius = 5
        
        //Start Searching for devices with winegard specific UUID
        if bluetoothReady{BLEConnectionManagerSharedInstance.startScanning([WINEGARD_DEVICE_UUID])}
    }
    /*============================================================================*/
    //  Do any setup just before view appears
    /*============================================================================*/
    override func viewWillAppear(_ animated: Bool)
    {
        availableDevicesTable.reloadData()
        if bluetoothReady{BLEConnectionManagerSharedInstance.startScanning([WINEGARD_DEVICE_UUID])}
    }
    /*============================================================================*/
    //  Orientation setup
    /*============================================================================*/
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        //Set supported orienations to portrait only
        return [.portrait]
    }
    /*============================================================================*/
    override var shouldAutorotate: Bool
    {
        //Set autorotate to true
        return true
    }
    /*============================================================================*/
/**********************************************************************************/
//
//                          Notification Setup
//
/**********************************************************************************/
    
    /*============================================================================*/
    //  Add observers for notifications
    /*============================================================================*/
    func addObservers()
    {
        _ = BLEConnectionManagerSharedInstance
        //  Add observer for when winegard devices are found
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceSelectorViewController.foundWinegardDevice(_:)),
                                               name: NSNotification.Name(rawValue: "foundPeripheralID"),
                                               object: nil)
        //  Add observer for when connection to scoreboard succeeds
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceSelectorViewController.connectionToPeripheralSuccessful(_:)),
                                               name: NSNotification.Name(rawValue: "connectedToPeripheralID"),
                                               object: nil)
        //  Add observer for when the connection to peripheral scorebaord fails, can be caused by connection timeout
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceSelectorViewController.connectionToPeripheralFailed(_:)),
                                               name: NSNotification.Name(rawValue: "connectionToPeripheralFailedID"),
                                               object: nil)
        //  Add observer for bluetooth powered on
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DeviceSelectorViewController.bluetoothStatePoweredOn(_:)),
                                               name: NSNotification.Name(rawValue: "bluetoothNowPoweredOnID"),
                                               object: nil)
    }
    /*============================================================================*/
    //  Remove observers so this class isnt called when we arent using it
    /*============================================================================*/
    func removeObservers()
    {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "foundPeripheralID"),
                                                  object:nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "connectedToPeripheralID"),
                                                  object:nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "connectionToPeripheralFailedID"),
                                                  object:nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name(rawValue: "bluetoothNowPoweredOnID"),
                                                  object:nil)
    }
/**********************************************************************************/
//
//                          Bluetooth Functions
//
/**********************************************************************************/
    
    /*============================================================================*/
    //  Called when winegard device found by BLEConnectionManager
    /*============================================================================*/
    func foundWinegardDevice(_ notification: Notification)
    {
        print("Found WinegardDevice")
        
        //save peripheral information to local variable for parsing
        let userInfo = notification.userInfo as! [String: AnyObject]
        let newPeripheral = userInfo["peripheralFound"] as! CBPeripheral!
        
        //rebuild listOfPeripherals check for and removing/replacing duplicate entries.  Updated info always used
        for entry in listOfPeripherals{
            
            let oldPeripheral = entry["peripheralFound"] as! CBPeripheral!
            
            if newPeripheral == oldPeripheral{
                duplicateFound = true
                listOfPeripheralsCopy.append(userInfo as AnyObject)
            }else{
                //duplicateFound = false
                listOfPeripheralsCopy.append(entry)
            }
        }
        
        listOfPeripherals = listOfPeripheralsCopy
        
        //didnt find a duplicate so we just made a copy of the existing list above, so add the new peripheral to the list
        if !duplicateFound{
            listOfPeripherals.append(userInfo as AnyObject)
        }
        
        //clear copy
        listOfPeripheralsCopy = []; self.availableDevicesTable.reloadData()
    }
    /*============================================================================*/
    //  Called when BLEConnectionManager reports BLE is ready
    /*============================================================================*/
    func bluetoothStatePoweredOn(_ notification: Notification)
    {
        bluetoothReady = true
        BLEConnectionManagerSharedInstance.startScanning([WINEGARD_DEVICE_UUID])
    }
    /*============================================================================*/
    //  Connection attempt to peripheral succeded
    /*============================================================================*/
    func connectionToPeripheralSuccessful(_ notifiction: Notification)
    {
        let newView = self.storyboard?.instantiateViewController(withIdentifier: "widgetsViewController") as! WidgetsViewController!
        self.navigationController?.show(newView!, sender: self)
        //Now discover all services so we know what to populate on widget view
    }
    /*============================================================================*/
    // Connection attempt to peripheral failed
    /*============================================================================*/
    func connectionToPeripheralFailed(_ notification: Notification)
    {
        workingPeripheral = nil
        connectedWinegardDevice.winegardDevice = nil
        
        // Clear connectionView status window and stop indicator animation
        //connectingViewLabel.text! = "Connecting"; connectingView.layer.isHidden = true
        
        //  Clear Table data and Start scanning again
        listOfPeripherals = []; listOfPeripheralsCopy = []; availableDevicesTable.reloadData()
        
        //  Re-start scanning since connnection failed
        BLEConnectionManagerSharedInstance.startScanning([(WINEGARD_DEVICE_UUID)])
        
        //  Invalidate timer
        //timer.invalidate()
    }
/**********************************************************************************/
//
//                               END OF CLASS
//
/**********************************************************************************/
}


/**********************************************************************************/
//
//                               Table View Data Source
//
/**********************************************************************************/
extension DeviceSelectorViewController: UITableViewDataSource
{
    /*============================================================================*/
    //  TableView number of rows in table
    /*============================================================================*/
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int
    {
        if debug { print("Number of peripherals \(listOfPeripherals.count)") }
        
        var count = 0
        
        if !debug {
            count = listOfPeripherals.count
        } else {
            count = 1
        }
        
        return count
    }
    /*============================================================================*/
    //  TableView cell data and formatting
    /*============================================================================*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        
        cell.textLabel?.textColor = UIColor(red: 0/255, green: 139/255, blue: 206/255, alpha: 1)
        cell.textLabel?.font = UIFont (name: (cell.textLabel?.font.fontName)!, size: 18)
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1
        cell.layer.borderColor = WINEGARD_PRIMARY_BLUE_COLOR.cgColor//UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 1).cgColor//UIColor(red: 0/255,
        
        var peripheralData: AnyObject?
        
        if !debug {peripheralData = listOfPeripherals[indexPath.row]}
        
        var cellData = ""
        var numberOfLinesNeeded = 2
        
        // Pull Local Name From Peripheral
        if !debug{
            
            if let localName = peripheralData?["localName"] as! String!{
                numberOfLinesNeeded += 1
                cellData = cellData + "\(localName)"
            }
            
            if let rssi = peripheralData?["RSSI"] as! NSInteger!{
                numberOfLinesNeeded += 1
                cellData = cellData + "\rRSSI: [\(rssi)]"
            }
        }
        
        if debug {cell.textLabel?.text = "RAYZAR\rRSSI[-54]"}
        
        let image = UIImage(named: "winegardIcon.png")
        let newImage = resizeImage(image: image!, toTheSize: CGSize(width: 75,height: 75))
        
        var cellImageLayer: CALayer?  = cell.imageView?.layer//.cellImage.layer
        cellImageLayer!.cornerRadius = cellImageLayer!.frame.size.width / 2
        cellImageLayer!.masksToBounds = true
        cell.imageView?.image = newImage
    
        cell.textLabel?.numberOfLines = numberOfLinesNeeded
        //cell.textLabel?.text = cellData
        return cell
    }
    /*============================================================================*/
    //  Resize cell image
    /*============================================================================*/
    func resizeImage(image:UIImage, toTheSize size:CGSize)->UIImage
    {
        let scale = CGFloat(max(size.width/image.size.width, size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        let rr:CGRect = CGRect(x: 0,y: 0,width: width,height: height);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
    }
    /*============================================================================*/
    //  Set table row height
    /*============================================================================*/
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //let height = (tableView.cellForRow(at: indexPath)?.imageView?.frame.height)!*2
        return 100
    }
    /*============================================================================*/
    //
    /*============================================================================*/
    private func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let view:UIView = UIView()
        view.alpha = 0
        return view
    }
    /*============================================================================*/
}


/**********************************************************************************/
//
//                               Table View Delegate
//
/**********************************************************************************/
extension DeviceSelectorViewController: UITableViewDelegate
{
    /*============================================================================*/
    //
    /*============================================================================*/
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //try to connect to peripheral
        if debug == false{
            
            BLEConnectionManagerSharedInstance.stopScanning()
            BLEConnectionManagerSharedInstance.connectToPeripheral((listOfPeripherals[indexPath.row])["peripheralFound"] as! CBPeripheral!)
            workingPeripheral = (listOfPeripherals[indexPath.row])["peripheralFound"] as! CBPeripheral!
            connectedWinegardDevice.winegardDevice = (listOfPeripherals[indexPath.row])["peripheralFound"] as! CBPeripheral!
            //timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(AvailableScoreboardsViewController.connectionTimeout), userInfo: nil, repeats: false);
        } else {
            
            let transistion = CATransition()
            transistion.subtype = kCATransitionReveal
            view.window!.layer.add(transistion, forKey: kCATransition)
            BLEConnectionManagerSharedInstance.stopScanning()
            self.removeObservers()
            let newView = self.storyboard?.instantiateViewController(withIdentifier: "widgetsViewController") as! WidgetsViewController!
            self.navigationController?.show(newView!, sender: self)
            //timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(AvailableScoreboardsViewController.simConnected), userInfo: nil, repeats: false)
        }
    }
    /*============================================================================*/
    
}
