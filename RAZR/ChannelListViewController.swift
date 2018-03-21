//
//  ChannelListViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/13/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData

let testingTableView = false

//============================== Base Class =======================================
class ChannelListViewController: UIViewController
{
    //  NOTIFICATION HANDLER METHODS
    let SINGLE_CHANNEL_UPDATE_HANDLER = #selector(ChannelListViewController.updateSingleChannelPowerGuage)
    let CHANNEL_SUMMARY_UPDATE_HANDLER = #selector(ChannelListViewController.updateChannelSummaryTable)

    //  IBOutlets
    @IBOutlet weak var channelListTable             : UITableView!
    @IBOutlet weak var individualChannelView        : UIView!
    @IBOutlet weak var channelViewSelectionSegment  : UISegmentedControl!
    @IBOutlet weak var indicatorView                : UIView!
    @IBOutlet weak var powerValueLabel              : UILabel!
    @IBOutlet weak var channelNumberButton          : UIButton!
    
    @IBOutlet weak var blurView                     : UIView!
    @IBOutlet weak var channelUiPickerView          : UIPickerView!
    @IBOutlet weak var channelScrollViewContainer   : UIView!
    @IBOutlet weak var mainGaugeView                : UIView!
    
    @IBOutlet weak var indicatorImage               : UIImageView!
    @IBOutlet weak var tableTitle                   : UILabel!
    
    @IBOutlet weak var scanningStatusView           : UIView!
    @IBOutlet weak var scanningStatusIndicator      : UIActivityIndicatorView!

    //  Variables
    var setupComplete                   = false
    var summaryViewIsShown              = true
    var angleIncrement: CGFloat         = CGFloat(Double.pi/12)
    var currentAngle: Double            = -135
    var zeroAngle: Double               = -135
    var channelList: [Int]              = []
    var tableCellCountTemporary         = 0
    
    var selectedRowIndex                : IndexPath?
    var lastSelectedRowIndex            : IndexPath?
    var utilityTimer                    : Timer?
    var currentChannelSelected          : Int?
    var refreshControl                  : UIRefreshControl!
    
    var recievedChannelDataArrayLocalCopy: ScanManager.ChannelSummaryData = []
    var firstUpdate = false
    //angle range -30 to 210
    //var lastReading = 0
    
    //not used yet, need to add
    enum scanMode{
        case summary
        case individual
    }
    
    //Attempt to add collection view to cell when select and remove when deselected
    var collectionView: UICollectionView!
    var widgetImages = [UIImage(named: "channelViewIconVersionOne"),
                        UIImage(named: "sprectrumAnalyzerConceptOne"),
                        UIImage(named: "mapIconOptionOne"),
                        UIImage(named: "settingsOption2"),
                        UIImage(named: "info"),
                        UIImage(named: "winegardIcon"),
                        UIImage(named: "winegardIcon"),
                        UIImage(named: "winegardIcon")]
    
    var defaultImages = [UIImage(named: "channelViewIconVersionOne"),
                         UIImage(named: "sprectrumAnalyzerConceptOne"),
                         UIImage(named: "mapIconOptionOne"),
                         UIImage(named: "settingsOption2"),
                         UIImage(named: "info"),
                         UIImage(named: "winegardIcon"),
                         UIImage(named: "winegardIcon"),
                         UIImage(named: "winegardIcon")]
    
    let coreDatController = CoreDataController()
    var viewModel: ChannelListViewModel!
}

//
extension ChannelListViewController
{
    //
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        channelScrollViewContainer.layer.opacity = 0
        channelScrollViewContainer.isHidden = true
        viewModel = ChannelListViewModel()
        addObservers()
        setupUI()
        setupBindings()
        
        for i in 1...52{
            channelList.append(i)
        }
        
        scanningStatusIndicator.startAnimating()
        currentChannelSelected = 10
        
        if testingTableView{
            scanningStatusView.isHidden = true
            scanningStatusIndicator.stopAnimating()
        }
        
        //init to 0 value on gauge
        self.indicatorView.transform = self.indicatorView.transform.rotated(by: CGFloat(self.zeroAngle * Double.pi/180))
        self.view.layoutIfNeeded()
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(self.refreshChannelSummaryTableData), for: UIControlEvents.valueChanged)
        self.channelListTable.addSubview(refreshControl)
    }
    
    func setupBindings(){
        viewModel.isConnected.bind { (connected) in
            if !connected{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    //  Do anything that needs to be done before the view dissapears
    override func viewWillDisappear(_ animated: Bool){
        removeObservers()
        viewModel.close()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.open()
    }

    //  Do any UI setup needed when view
    func setupUI()
    {
        //Add gradient to background
        let gradient                    = CAGradientLayer()
        gradient.frame                  = self.view.bounds
        gradient.colors                 = [UIColor.white.cgColor, UIColor.lightGray.cgColor]
        individualChannelView.isHidden  = true
        
        self.view.layer.insertSublayer(gradient, at: UInt32(0))
        //powerValueLabel.layer.cornerRadius = 5
        
        //setup blur view
        blurView.layer.opacity          = 0
        blurView.isHidden               = true
        self.blurView.backgroundColor   = UIColor.clear
        let blurEffect                  = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView              = UIVisualEffectView(effect: blurEffect)
        
        //always fill the view
        blurEffectView.frame            = self.blurView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha            = 0.97
        self.blurView.addSubview(blurEffectView)
    }
    
    //
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        //Set supported orientation to portrait only
        return [.portrait]
    }
    
    //
    override var shouldAutorotate: Bool
    {
        //set autorotate to true
        return true
    }
    
    //
    func rotateIndicator(newValue: Float)
    {
        UIView.animate(withDuration: 0.25, animations:{
            self.indicatorView.transform = CGAffineTransform(rotationAngle: CGFloat(newValue - Float(((Double.pi/180)*135))))
        })
    }
    
    //UPDATE POWER LEVEL FOR SINGLE CHANNEL SCAN
    @objc func updateSingleChannelPowerGuage()
    {
        var rotationAngleCurrent: Float = 0
        rotationAngleCurrent            = (log10(Float(scanManager.singleChannelAveragePower))*(Float(180/Double.pi))*2.2283)*Float(Double.pi/180)
        
        if rotationAngleCurrent < 1{ rotationAngleCurrent = 1}
        rotateIndicator(newValue: rotationAngleCurrent )
        
        powerValueLabel.text = "\(scanManager.singleChannelAveragePower)"
        print("Recieved notification from scan manager")
        print("New Average Power = \(scanManager.singleChannelAveragePower)")
    }
    
    //UPDATE CHANNEL SUMMARY TABLE 
    @objc func updateChannelSummaryTable()
    {
        //ADDED TEMPORARILY FOR DEBUGGING SO TABLE DOESNT UPDATE
        NotificationCenter.default.removeObserver(self, name: CHANNEL_SUMMARY_DATA_UPDATED, object:nil)
        
        if !scanningStatusView.isHidden{
            scanningStatusView.isHidden = true
            scanningStatusIndicator.stopAnimating()
        }
        
        tableTitle.text = "Found \(scanManager.recievedChannelDataArray.count) Channels"
        
        //used to avoid issues with change in value
        //lets call this a local copy
        tableCellCountTemporary = scanManager.recievedChannelDataArray.count
        
        let updatedChannelDataArray = scanManager.recievedChannelDataArray.sorted{$0.channel > $1.channel}

        print("Updated and Sorted channel data array \r \(updatedChannelDataArray)")
        
        recievedChannelDataArrayLocalCopy = updatedChannelDataArray//scanManager.recievedChannelDataArray.sorted{$0.channel > $1.channel}
        
        if selectedRowIndex == nil{
            channelListTable.reloadData()
            //firstUpdate = true
        }
        
        print("Recieved updated channel summary data")
    }
    

    //
    @objc func refreshChannelSummaryTableData()
    {
        selectedRowIndex = nil
        recievedChannelDataArrayLocalCopy = scanManager.recievedChannelDataArray
        channelListTable.reloadData()
        self.refreshControl.endRefreshing()
    }
}


//MARK: Notification setup and removal
extension ChannelListViewController
{
    
    //
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: SINGLE_CHANNEL_UPDATE_HANDLER, name: INDIVIDUAL_CHANNEL_DATA_UPDATED, object: nil)
        NotificationCenter.default.addObserver(self, selector: CHANNEL_SUMMARY_UPDATE_HANDLER, name: CHANNEL_SUMMARY_DATA_UPDATED, object: nil)
    }
    
    //
    func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: INDIVIDUAL_CHANNEL_DATA_UPDATED, object:nil)
        NotificationCenter.default.removeObserver(self, name: CHANNEL_SUMMARY_DATA_UPDATED, object:nil)
    }
}


extension ChannelListViewController
{
    //
    func switchChannelScanModeTo(mode: scanMode){
        
        switch mode{
        case .individual:
            viewModel.updateScanMode(mode: .individual)

        case .summary:
            viewModel.updateScanMode(mode: .summary)

        }
    }
}


//
extension ChannelListViewController
{
    //  Change channel up or down based on user input
    @IBAction func upDownButton(_ sender: UIButton){
        
        // Need to move channel selected state to view model
        if sender.restorationIdentifier == "upButton"{
            if currentChannelSelected! < 52{
                currentChannelSelected! += 1
            }
        } else {
            if currentChannelSelected! > 0{
                currentChannelSelected! -= 1
            }
        }
    
        //  Need to move this to viewModel
        let formattedChannel    = UInt8(currentChannelSelected!)
        let testPacket: [UInt8] = [0x03, formattedChannel]
        let data = Data(bytes: testPacket)
        
        viewModel.changeChannel(newChannelDataConfig: data)
        channelNumberButton.setTitle("\(currentChannelSelected!)", for: .normal)
        channelNumberButton.titleLabel?.text = "\(currentChannelSelected!)"
    }

    //  Switch between channel summary and individual channel
    @IBAction func switchChannelView(_ sender: UISegmentedControl)
    {
        let selected = sender.selectedSegmentIndex
        print("Index sent \(selected)")
        switch selected{
        //==================================================
        case 0: print("Summary selected")
            if !summaryViewIsShown{
            
                switchChannelScanModeTo(mode: .summary)
                UIView.transition(from: individualChannelView,
                                  to: channelListTable,
                                  duration: 1.0,
                                  options: [UIViewAnimationOptions.transitionFlipFromLeft, UIViewAnimationOptions.showHideTransitionViews],
                                  completion: nil)
            
                summaryViewIsShown = true
            }
        //==================================================
        case 1: print("Individual selected")
            if summaryViewIsShown{
            
                switchChannelScanModeTo(mode: .individual)
                UIView.transition(from: channelListTable,
                                  to: individualChannelView,
                                  duration: 1.0,
                                  options: [UIViewAnimationOptions.transitionFlipFromRight, UIViewAnimationOptions.showHideTransitionViews],
                                  completion: nil)
            
                summaryViewIsShown = false
            }
        //==================================================
        default: print("Unkown case")
        }
        
    }
    
    //
    func gotDirectlyToSingleChannel()
    {

            switchChannelScanModeTo(mode: .individual)
            UIView.transition(from: channelListTable,
                              to: individualChannelView,
                              duration: 1.0,
                              options: [UIViewAnimationOptions.transitionFlipFromRight,UIViewAnimationOptions.showHideTransitionViews],
                              completion: nil)
            
            summaryViewIsShown = false
        
    }
    
    //  Show channel veiw scroll selctions
    @IBAction func channelNumberButton(_ sender: UIButton){
        channelScrollViewContainer.isHidden = false
        blurView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: {
            self.individualChannelView.layer.borderWidth      = 0
            self.blurView.layer.opacity                       = 1
            self.channelScrollViewContainer.layer.opacity     = 1
        })
    }
}


//MARK: CHANNEL TABLE VIEW SETUP
extension ChannelListViewController: UITableViewDataSource
{
    //NUMBER OF ROWS IN TABLE
    func tableView(_ tableView: UITableView,numberOfRowsInSection section: Int) -> Int{
        
        var count = tableCellCountTemporary

        if testingTableView{
            count = 10
        } else {
            count = recievedChannelDataArrayLocalCopy.count
        }

        return count
    }

    //FORMAT EACH CELL FOR TABLE
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        var cell                                     = UITableViewCell()
        var channelEntry: (channel: Int, power: Int) = (0, 0)
        var numberOfLinesNeeded                      = 1
        var cellData                                 = ""
        var isSelected                               = false
        var networkCallsign: String                  = ""
        var towerDistance                            = ""
        var virtualChannel                           = ""
        var accessoryLabel                           = UILabel()
        var image                                    = UIImage(named: "winegardIcon.png")//default cell image
        //SETUP CELL
        cell.accessoryType                           = .none
        //cell.accessoryType                           = .disclosureIndictor
        cell.textLabel?.font                         = UIFont (name: (cell.textLabel?.font.fontName)!, size: 18)
        cell.layer.cornerRadius                      = 10
        cell.layer.borderWidth                       = 1
        cell.selectionStyle                          = .none
        cell.layer.borderColor                       = UIColor(red: 215/255,green: 215/255,blue: 215/255,alpha: 1.0).cgColor
        cell.backgroundColor                         = UIColor.white
        
        let jumpToIndividualButton =  UIButton(frame: CGRect(x: 0, y: 20, width: 40, height: 40))
        jumpToIndividualButton.backgroundColor = UIColor.black
        jumpToIndividualButton.setTitle("TEST", for: .normal)
        
        var towerEntryInDB: Tower?
        var falseBackgroundHeight = 100

        //MAKE SURE WE HAVE THIS DATA
        if recievedChannelDataArrayLocalCopy.indices.contains(indexPath.row){
            channelEntry = recievedChannelDataArrayLocalCopy[indexPath.row]
            towerEntryInDB = coreDatController.retrieveTowerEntryUsing(retrieveByOption: .physicalChannel, optionValue: "\(recievedChannelDataArrayLocalCopy[indexPath.row].channel)")
        }
        
        //POPULATE DATA RETRIEVED FROM DATABASE
        //PROBABLY DONT NEED THIS ADDITIONAL CHECK, CAN MOST LIKELY JUST UNWRAP ABOVE
        if let dbData = towerEntryInDB{
            
            print("CDDEBUG===>  PHY CHANNEL: == : \(channelEntry.channel)")
            networkCallsign = dbData.callSign!
            print("CDDEBUG===>  Core Data Tower Callsign = \(networkCallsign)")
            towerDistance = dbData.distance!
            print("CDDEBUG===>  Core Data Tower Distance = \(towerDistance)")
            virtualChannel = dbData.virtualChannel!
            
            if dbData.networkImage != nil{
                image = UIImage(data: dbData.networkImage! as Data)
            }
        }
        
        cellData = cellData + "CH: \(virtualChannel)-1 (\(channelEntry.channel))\r"
        numberOfLinesNeeded += 1
        cellData = cellData + "RSSI: \(channelEntry.power)"
        numberOfLinesNeeded += 1
        
        
        //  IF SELECTED CELL, TWEEK SIZE AND POSTION OF CONTENT
        if let selectedIndexPathRow = selectedRowIndex{
            if selectedIndexPathRow == indexPath{
                isSelected = true
                
                //cell.accessoryView!.frame.origin.y -= 65
                cell.contentView.frame.origin.y -= 65//65
                falseBackgroundHeight = 200
            } else {
                falseBackgroundHeight = 100
            }
        }
        
        if false{
            cell.backgroundColor = UIColor.clear
            let falseCellBackground = UIView(frame: CGRect(x: 5, y: 5, width: channelListTable.frame.width - 10, height: CGFloat(falseBackgroundHeight)))
            //falseCellBackground.layer.backgroundColor = UIColor.black.cgColor
            falseCellBackground.layer.cornerRadius = 5
            falseCellBackground.layer.shadowColor       = UIColor.darkGray.cgColor
            falseCellBackground.layer.shadowOffset      = CGSize(width: 1, height: 2)
            falseCellBackground.layer.shadowRadius      = 2.0
            falseCellBackground.layer.shadowOpacity     = 1.0
            falseCellBackground.layer.masksToBounds     = false
            //falseCellBackground.layer.backgroundColor   = UIColor.clear.cgColor
            falseCellBackground.layer.backgroundColor   = UIColor.white.cgColor//??, why do i have this twice
            cell.addSubview(falseCellBackground)
        }
        
        let newImage = resizeImage(image: image!, toTheSize: CGSize(width: 70,height: 70), selected: isSelected)
        formatCellImage(cell: &cell, image: newImage)
        
        cell.layer.shadowPath = UIBezierPath(roundedRect: (cell.imageView?.frame)!, cornerRadius: 3).cgPath
        cell.textLabel?.numberOfLines = numberOfLinesNeeded
        cell.textLabel?.text = cellData
        
        //Accessory label
        if isSelected{
            accessoryLabel = UILabel(frame: CGRect(x: cell.contentView.frame.origin.x + cell.contentView.frame.width - 75,
                                                   y: cell.contentView.frame.origin.y + 130,width: 75,height: 75))
        } else {
            accessoryLabel = UILabel(frame: CGRect(x: cell.contentView.frame.origin.x + cell.contentView.frame.width - 75,
                                                   y: cell.contentView.frame.origin.y + 15,width: 75,height: 75))
        }
            
        //Accessory label
        accessoryLabel.tag              = 201
        accessoryLabel.textColor        = UIColor.black
        accessoryLabel.numberOfLines    = 2
        accessoryLabel.text             = "\(networkCallsign)\r\(towerDistance) mi"
        accessoryLabel.textAlignment    = .center
        accessoryLabel.backgroundColor = UIColor.clear
        
        cell.accessoryView?.addSubview(jumpToIndividualButton)
        cell.contentView.addSubview(accessoryLabel)
        //cell.sendSubview(toBack: falseCellBackground)
        return cell
    }
    
    func formatCellImage(cell: inout UITableViewCell, image: UIImage){
        
        //let cellImageLayer: CALayer?            = cell.imageView?.layer//.cellImage.layer
        //cellImageLayer!.cornerRadius            = cellImageLayer!.frame.size.width / 2
        cell.imageView?.layer.borderColor       = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 0.25).cgColor
        cell.imageView?.contentMode             = .scaleAspectFit
        cell.imageView?.image                   = image
        cell.imageView?.layer.cornerRadius      = 70/2
        cell.imageView?.layer.borderWidth       = 1.0
        cell.imageView?.layer.borderWidth       = 1
        cell.imageView?.layer.borderColor       = UIColor.clear.cgColor
        cell.imageView?.layer.masksToBounds     = true
        //Shadow effect
        cell.imageView?.layer.shadowColor       = UIColor.lightGray.cgColor
        cell.imageView?.layer.shadowOffset      = CGSize(width: 0, height: 2)
        cell.imageView?.layer.shadowRadius      = 2.0
        cell.imageView?.layer.shadowOpacity     = 1.0
        cell.imageView?.layer.masksToBounds     = false
        cell.imageView?.layer.backgroundColor   = UIColor.white.cgColor
    }

    // Resize cell image function if we add image to cell view
    func resizeImage(image:UIImage, toTheSize size:CGSize, selected: Bool)->UIImage{
        
        let scale           = CGFloat(max(size.width/image.size.width, size.height/image.size.height))
        var width:CGFloat   = image.size.width * scale
        var height:CGFloat  = image.size.height * scale;
        var lessThan        = false
        
        //only scale is image is larger that specified size
        if image.size.width <= width{
            lessThan = true
            width    = image.size.width
        }
        
        if image.size.height <= height{
            lessThan = true
            height   = image.size.height
        }
        
        var rr: CGRect
        if lessThan{
            rr = CGRect(x: 70/2 - (width/2), y: 70/2 - (height/2), width: width, height: height);
        } else {
            rr = CGRect(x: 0, y: 0, width: width, height: height);
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
    }
    
    //  Set cell height for each cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        guard let selectedIndexPathRow = selectedRowIndex else {return 110}
        
        var height = 0
        if selectedIndexPathRow.row == indexPath.row{
            height = 210
            //tableView.cellForRow(at: indexPath)?.viewWithTag(1)?.frame.height = 200
        }else{
            height = 110
            //tableView.cellForRow(at: indexPath)?.viewWithTag(1)?.frame.height = 100
        }
        //print("HEIGHT FOR ROW AT INDEX = \(height)")
        return CGFloat(height)
    }

    //
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?{
        let view:UIView = UIView()
        view.alpha = 0
        return view
    }
    
    //
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?){
        print("Did end editing row at \(String(describing: indexPath?.row))")
        
    }
    
    //
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath){
        print("Accessory Button Tapped for \(indexPath.row)")
        gotDirectlyToSingleChannel()
    }
}

// Mark: Table View Delegate
extension ChannelListViewController: UITableViewDelegate
{
    
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        // Get channel to see if there are images available for channel
        var imagesFromServer: [UIImage] = []
        //===========================================
        //GET TOWER DATA IF IT EXISTS
        var towerEntryInDB: Tower?
        towerEntryInDB = coreDatController.retrieveTowerEntryUsing(retrieveByOption: .physicalChannel, optionValue: "\(recievedChannelDataArrayLocalCopy[indexPath.row].channel)")
        //=========================================
        
        //check if we have valid tower data
        if let towerDataFromDB =  towerEntryInDB{
            
            if let shows = towerDataFromDB.shows{
                for show in shows{
                    
                    let data = show as! Show
                    //var data = image as! Data
                    imagesFromServer.append(UIImage(data: data.image! as Data)!)
                    print("Retrieved show image from CoreData Successfully")
                    print("Show image count = \(imagesFromServer.count)")
                    
                };widgetImages = imagesFromServer
            }

        } else {
            widgetImages = defaultImages
        }
        
        // Assign selectedRowIndex value to selectedRow if selectedRowIndex has not been
        // assigned before, else assign it
        guard let selectedRow = selectedRowIndex else {
            selectedRowIndex = indexPath;
            
            //really no point in using a guard statment here 
            guard (collectionView) != nil else{
                setupCollectionView(tableViewCell: tableView.cellForRow(at: indexPath)!)
                
                self.channelListTable.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .automatic)
                self.channelListTable.endUpdates()
                
                addCollectionViewToCell()
                return
            }

            self.channelListTable.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            self.channelListTable.endUpdates()
            
            addCollectionViewToCell()
            collectionView.reloadData()//reload collection view and apply content vew shift
            return
        }
        
        //  Check if the selected row is the same as the current selected cell, if it is
        //  then go to else
        if selectedRow.row != indexPath.row{
            
            removeObservers()
            removeCollectionViewFromCell()
            lastSelectedRowIndex    = selectedRowIndex
            selectedRowIndex        = indexPath
            
            self.channelListTable.beginUpdates()
            if let last = lastSelectedRowIndex{
                //tableView.reloadRows(at: [last], with: .automatic)
                tableView.reloadRows(at: [indexPath], with: .automatic)
                //
            } else {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            
            self.channelListTable.endUpdates()
            
            addCollectionViewToCell()
            collectionView.reloadData()
            addObservers()
        } else {

            removeCollectionViewFromCell()
            lastSelectedRowIndex    = selectedRowIndex
            selectedRowIndex = nil
            
            //reload table data after removing collectionView from cell
            channelListTable.reloadData()
        }
        
    }
    
    //
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath){
        
        if let checkForSelection = selectedRowIndex{
            if checkForSelection == indexPath{
            
                //deselect selected cell when it goes off screen. This is working for now
                //would like to maintain selected cell content when cell goes off screen
                //but having dificulty getting to work right now.  PUT ON HOLD FOR NOW
                if tableView.indexPathsForVisibleRows?.index(of: indexPath) == nil{
                    print("are we setting index to nil")
                    selectedRowIndex = nil
                }
            }
        }
    }
    
    
    
}

extension ChannelListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    //SETUP THE COLLECTION VIEW TO DISPLAY SHOWS
    func setupCollectionView(tableViewCell: UITableViewCell)
    {
        print("SETUP COLLECTION VIEW")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 2
        
        layout.itemSize     = CGSize(width: (tableViewCell.frame.height - 25),height: (tableViewCell.frame.height - 25)/2)
        let customSize      = CGSize(width: tableViewCell.frame.width - 20,height: (tableViewCell.frame.height - 25)*1.35)
        let customPoint     = CGPoint(x: tableViewCell.contentView.frame.origin.x + 10, y: tableViewCell.contentView.frame.origin.y + (tableViewCell.frame.height - 25) + 7)
        let newFrame        = CGRect(origin: customPoint, size: customSize)
        collectionView      = UICollectionView(frame: newFrame, collectionViewLayout: layout)
        
        print("Collection View Size = \(customSize)")
        print("Collection View Frame = \(customPoint)")
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        //collectionView.tag = (selectedRowIndex?.row)!
        collectionView.register(ChannelCollectionViewCell.self,forCellWithReuseIdentifier: "channelCollectionCell")
        collectionView.tag = 200
        
        //print("ATTEMPTED TO ADD COLLECTION VIEW TO CELL")
    }
    
    //ADD COLLECTION VIEW WITH SHOWS TO CELL
    func addCollectionViewToCell()
    {
        if let index = selectedRowIndex{
            print("Added Collection View")
            channelListTable.cellForRow(at: index)!.addSubview(collectionView)
        }
        
    }
    
    //  This is called current selected tableviewcell changes
    func removeCollectionViewFromCell()
    {
        // Only remove view if it exist, if cell goes out of view it isnt avialable
        if let cell = channelListTable.cellForRow(at: selectedRowIndex!){//?.viewWithTag(200)?.removeFromSuperview(){
            //collection view
            channelListTable.cellForRow(at: selectedRowIndex!)!.viewWithTag(200)?.removeFromSuperview()
            //accessory label
            channelListTable.cellForRow(at: selectedRowIndex!)!.viewWithTag(201)?.frame.origin.y -= 50
            //channelListTable.cellForRow(at: selectedRowIndex!)!.contentView.frame.origin.y += 50
        }
        //print("CELL SUBVIEWS = \(subviews)")
    }
    
    /******************************************************************************/
    //  Number of section in the collection view
    /******************************************************************************/
    func numberOfSections(in collectionView: UICollectionView) -> Int{
        return 1
    }
    
    //  Number of cells in section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let checkForSelection = selectedRowIndex{
            print("UPDATED CELL CONTENT VIEW POSITION")
            channelListTable.cellForRow(at: checkForSelection)?.contentView.frame.origin.y -= 50
        }
        return widgetImages.count
    }
    
    //  Add each cell to collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channelCollectionCell", for: indexPath) as! ChannelCollectionViewCell
        formatCollectionViewCell(cell: &cell)

        //fixed issue of multiple image view being added per cell
        if let _ = cell.channelImageView{
        }else {
            cell.awakeFromNib()
        }
        return cell
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath){
        
        let channelCollectionCell = cell as! ChannelCollectionViewCell
        if widgetImages.indices.contains(indexPath.row){
            channelCollectionCell.channelImageView.image = widgetImages[indexPath.row]
        }
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        //print("Collection view height = \(collectionView.frame.height)")
        return CGSize(width: collectionView.frame.height*0.9,
                      height: collectionView.frame.height*0.9)
    }
    
    
}

//MARK: PICKERVIEW DATA SOURCE METHODS
extension ChannelListViewController: UIPickerViewDataSource
{
    //NUMBER OF COMPONENTS IN ROW
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }

    //NUMBER OF ROWS IN COMPONENTS
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return channelList.count
    }
    
    //DATA FOR EACH ROW
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString?
    {
        print("Load Data")
        let titleData = "\(channelList[row])"
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedStringKey.font:UIFont(name: "Helvetica Neue", size: 50.0)!, NSAttributedStringKey.foregroundColor:UIColor(red: 17/255, green: 136/255, blue: 201/255, alpha: 1)])
        return myTitle
    }
}



//MARK: PICKERVIEW DELEGATE METHODS
extension ChannelListViewController: UIPickerViewDelegate
{
    //
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }

    //
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickerLabel = UILabel()
        pickerLabel.text = "\(channelList[row])"
        
        //Return array of only channels
        let availableChannels =  scanManager.recievedChannelDataArray.map({$0.channel})
            
        if availableChannels.contains(channelList[row]){
            pickerLabel.textColor = UIColor.winegardRed
        } else {
            pickerLabel.textColor = UIColor.winegardBlue
        }
            
        pickerLabel.font = UIFont(name: pickerLabel.font.fontName, size: 60)
        pickerLabel.textAlignment = .center
        //pickerLabel.layer.height
        return pickerLabel
    }

    //
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
        //individualChannelView.layer.borderWidth = 2
        let numberSelected                  = channelList[row]
        //channelScrollViewContainer.isHidden = true
        currentChannelSelected              = numberSelected
        
        UIView.animate(withDuration: 0.5, animations: {
            self.blurView.layer.opacity                       = 0
            self.channelScrollViewContainer.layer.opacity     = 0
            }, completion: { (Bool) -> Void in
                self.channelScrollViewContainer.isHidden = true
                self.blurView.isHidden = true
        })
        
        print("number selected = \(numberSelected)")

        let formattedChannel                = UInt8(currentChannelSelected!)
        let testPacket: [UInt8]             = [0x03, formattedChannel]
        let data = Data(bytes: testPacket)
        
        viewModel.changeChannel(newChannelDataConfig: data)
        channelNumberButton.setTitle("\(currentChannelSelected!)", for: .normal)
        //blurView.isHidden = true
    }
}

//============================== CELL FORMATTING FUNCTIONS ========================
extension ChannelListViewController
{
    func formatCollectionViewCell(cell: inout ChannelCollectionViewCell)
    {
        cell.layer.cornerRadius                 = 5
        cell.contentView.layer.cornerRadius     = 5
        cell.contentView.layer.borderWidth      = 1
        cell.contentView.layer.borderColor      = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds    = true
        
        //Shadow effect
        cell.layer.shadowColor                  = UIColor.lightGray.cgColor
        cell.layer.shadowOffset                 = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius                 = 2.0
        cell.layer.shadowOpacity                = 1.0
        cell.layer.masksToBounds                = false
        cell.layer.backgroundColor              = UIColor.clear.cgColor
        cell.layer.shadowPath                   = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        cell.layer.backgroundColor              = UIColor(red: 245/255,green: 245/255,blue: 245/255,alpha: 1).cgColor
    }
}

