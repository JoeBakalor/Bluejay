//
//  WidgetsViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/5/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//
//  Summary:


//TODO:
//-->
//-->

import UIKit
import CoreBluetooth

var winegardServices: [CBService] = []

@IBDesignable
//============================== Base Class =======================================
class WidgetsViewController: UIViewController
{

    //  UI Outlets
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusViewLabel: UILabel!
    @IBOutlet weak var statusViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tabBar: UITabBar!
    //@IBOutlet weak var tabBar: UITabBar!
    
    
    /******************************************************************************/
    //Variables
    /******************************************************************************/
    var collectionView: UICollectionView!
    var widgetImages = [UIImage(named: "channelViewIconVersionOne"), UIImage(named: "sprectrumAnalyzerConceptOne"),
                        UIImage(named: "mapIconOptionOne"), UIImage(named: "settingsOption2"),
                        UIImage(named: "softwareUpdateIcon"),UIImage(named: "infko"),
                        UIImage(named: "dataLogsIcon"), UIImage(named: "winegardIcon")]
    
    var widgetImages2 = [UIImage(named: "channelViewIconVersionOne"), UIImage(named: "sprectrumAnalyzerConceptOne"),
                        UIImage(named: "mapIconOptionOne"), UIImage(named: "settingsOption2"),
                        UIImage(named: "softwareUpdateIcon"),UIImage(named: "info"),
                        UIImage(named: "dataLogsIcon"), UIImage(named: "winegardIcon")]
    
    var availableServices = 0b00000000
    var serviceArray: [CBService] = []
    var characteristicDisoveryServiceIndex = 0
    
    struct foundServices{
        var spectrumAnalyzer = false
        var otaService = false
        var informationService = false
    }
    
    enum GattDiscoveryStates{
        case idle
        case discoveringServices
        case discoveringCharacteristics
        case complete
        case error
    }
    
    var gattDiscoveryState = GattDiscoveryStates.idle
    var validServices = foundServices()
    
    //New
    var viewModel: WidgetsViewDataModel!
}

extension WidgetsViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        viewModel = WidgetsViewDataModel()
        self.navigationController?.isNavigationBarHidden = false
        tabBar.selectedItem = tabBar.items![1]
        
        self.statusView.isHidden = true
        setupUI()
    }
    
    func setupUI(){
        //Add gradient to background
        let gradient                    = CAGradientLayer()
        gradient.frame                  = self.view.bounds
        gradient.colors                 = [UIColor.white.cgColor, UIColor.lightGray.cgColor]
        self.view.layer.insertSublayer(gradient, at: UInt32(0))
        self.view.bringSubview(toFront: statusView)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        //Lock orientation to portrait
        return [.portrait]
    }
    
    override var shouldAutorotate: Bool
    {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        viewModel.open()
        super.viewWillAppear(false)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    //  Make any changes needed befor view dissapears, will dissapear wasnt working
    override func viewDidDisappear(_ animated: Bool)
    {
        collectionView.removeFromSuperview()
    }
    
    //
    override func viewDidAppear(_ animated: Bool)
    {
        setupCollectionView()
        self.view.bringSubview(toFront: statusView)
        self.view.bringSubview(toFront: tabBar)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.close()
    }
}

//============================== View Related =======================================
extension WidgetsViewController
{
    func setupBindings(){
        
        //  Bind to isConnected variable so we know when connection state changes
        viewModel.isConnected.bind(listener:
        { (connected) in
            if !connected{//  Rayzar disconnected
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
}

//============================== Collection View =================================
extension WidgetsViewController: UICollectionViewDelegate,
                                 UICollectionViewDataSource,
                                 UICollectionViewDelegateFlowLayout{
    
    
    //  Initialize collection(widgets) view and add to view controllers current view
    func setupCollectionView(){
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 75)
        
        let customSize = CGSize(width: view.frame.width - 10, height: view.frame.height - 10)
        let customPoint = CGPoint(x: view.frame.origin.x + 5, y: view.frame.origin.y + 5)
        let newFrame = CGRect(origin: customPoint, size: customSize)
        
        collectionView = UICollectionView(frame: newFrame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear//(red: 215/255, green: 215/255, blue: 215/255, alpha: 1)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WidgetCollectionViewCell.self, forCellWithReuseIdentifier: "widgetCell")
        
        view.addSubview(collectionView)
    }
    
    //  Get number of sections in collection view, only have one group of widgets
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }

    //  Get number of items in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return widgetImages.count
    }

    //  Add each item in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "widgetCell", for: indexPath) as! WidgetCollectionViewCell
        cell.layer.cornerRadius = 7
        cell.contentView.layer.cornerRadius = 2
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath

        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.awakeFromNib()
        return cell
    }

    //  Set image for each collection view item
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        let widgetCell = cell as! WidgetCollectionViewCell
        widgetCell.widgetImageView.image = widgetImages2[indexPath.row]
    }
    
    //  Get size for each item in the collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: (view.frame.width/2) - 10, height: (view.frame.width/2) - 10)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        //invert the cell colors when the user selects
        let selectedCell:UICollectionViewCell = collectionView.cellForItem(at: indexPath)!
        selectedCell.contentView.backgroundColor = WINEGARD_PRIMARY_BLUE_COLOR
        selectedCell.contentView.layer.cornerRadius = 7
        
        // Call appropriate view based on widget selected
        //========================================================
        switch indexPath.row{
        //========================================================
        case 0: //print("One")
            
            guard rayzarGatt.winegardSpectrumAnalyzerService != nil else { return }
            
            let transistion = CATransition()
            transistion.subtype = kCATransitionFade
            view.window!.layer.add(transistion, forKey: kCATransition)
            let newView = self.storyboard?.instantiateViewController(withIdentifier: "channelListViewController") as! ChannelListViewController!
            self.navigationController?.show(newView!, sender: self)
            
        //========================================================
        case 1: //print("Two")

            guard rayzarGatt.winegardSpectrumAnalyzerService != nil else { return }

            let transistion = CATransition()
            transistion.subtype = kCATransitionFade
            view.window!.layer.add(transistion, forKey: kCATransition)
            let newView = self.storyboard?.instantiateViewController(withIdentifier: "spectrumAnalyzerViewController") as! SpectrumAnalyzerViewController!
            self.navigationController?.show(newView!, sender: self)

        //========================================================
        case 2: //print("Three")
        
            //  Add check to make sure location data available before moving to screen
        
            let transistion = CATransition()
            transistion.subtype = kCATransitionFade
            view.window!.layer.add(transistion, forKey: kCATransition)
            let newView = self.storyboard?.instantiateViewController(withIdentifier: "mapView") as! MapViewController!
            self.navigationController?.show(newView!, sender: self)

        //========================================================
        case 3: //print("Four")
        
            //removeObservers()
        
            let transistion = CATransition()
            transistion.subtype = kCATransitionFade
            view.window!.layer.add(transistion, forKey: kCATransition)
            let newView = self.storyboard?.instantiateViewController(withIdentifier: "settingsViewController") as! SettingsViewController!
            self.navigationController?.show(newView!, sender: self)

            //print("Settings")
        //========================================================
        case 4: //print("Five")
            
            guard rayzarGatt.winegardOtaService != nil else { return }

            let transistion = CATransition()
            transistion.subtype = kCATransitionFade
            view.window!.layer.add(transistion, forKey: kCATransition)
            let newView = self.storyboard?.instantiateViewController(withIdentifier: "otaViewController") as! OTAViewController!
            self.navigationController?.show(newView!, sender: self)

        //========================================================
        case 5: //print("Six")
        
            guard rayzarGatt.winegardInformationService != nil else { return }
        
            let transistion = CATransition()
            transistion.subtype = kCATransitionFade
            view.window!.layer.add(transistion, forKey: kCATransition)
            let newView = self.storyboard?.instantiateViewController(withIdentifier: "informationViewController") as! InformationViewController!
            self.navigationController?.show(newView!, sender: self)
            
        //========================================================
        case 6: //print("Log Files View Controller")
        
            let transistion = CATransition()
            transistion.subtype = kCATransitionFade
            view.window!.layer.add(transistion, forKey: kCATransition)
            let newView = self.storyboard?.instantiateViewController(withIdentifier: "logFilesViewController") as! LogFilesViewController!
            self.navigationController?.show(newView!, sender: self)
        //========================================================
        case 7: print("Winegard Company Widget")
            
        if let url = URL(string: "http://www.winegard.com") {
            UIApplication.shared.open(url, options: [:])
            }
            
        default: print("No Match")
        }
    }
    
}
