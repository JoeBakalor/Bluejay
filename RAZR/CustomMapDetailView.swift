//
//  CustomMapDetailView.swift
//  RAZR
//
//  Created by Joe Bakalor on 9/11/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

//MARK: BASE CLASS
class CustomMapDetailView: UIView
{
    var collectionView      : UICollectionView!
    var networkImage        : UIImageView!
    var channelLabel        : UILabel?
    var channel = ""
    var callSignLabel       : UILabel?
    var callSign = ""
    var towerDistanceLabel  : UILabel?
    var towerDistance = ""
    var rssiLabel           : UILabel?
    var rssi = "RSSI: -76"
    
    var imageIcon = UIImage(named: "winegardIcon")!
    
    var isShown = false
    var collectionViewSetup = false
    
    
    var defaultImages = [UIImage(named: "channelViewIconVersionOne"),
                         UIImage(named: "sprectrumAnalyzerConceptOne"),
                         UIImage(named: "mapIconOptionOne"),
                         UIImage(named: "settingsOption2"),
                         UIImage(named: "info"),
                         UIImage(named: "winegardIcon"),
                         UIImage(named: "winegardIcon"),
                         UIImage(named: "winegardIcon")]
    
    var showImages = [UIImage(named: "channelViewIconVersionOne"),
                         UIImage(named: "sprectrumAnalyzerConceptOne"),
                         UIImage(named: "mapIconOptionOne"),
                         UIImage(named: "settingsOption2"),
                         UIImage(named: "info"),
                         UIImage(named: "winegardIcon"),
                         UIImage(named: "winegardIcon"),
                         UIImage(named: "winegardIcon")]
    
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: VIEW SETUP AND TEAR DOWN
extension CustomMapDetailView
{

    
    //DRAW VIEW
    override func draw(_ rect: CGRect)
    {
        let width = rect.size.width
        let height = rect.size.height
        let imageSize = CGSize(width: height/2 - 10, height: height/2 - 10)
        let imageOrigon = CGPoint(x: rect.origin.x + 5, y: rect.origin.y + 5)
        
        networkImage = UIImageView(frame: CGRect(origin: imageOrigon, size: imageSize))
        let imgae = resizeImage(image: imageIcon, toTheSize: imageSize)//UIImage(named: "winegardIcon")
        
       // networkImage.backgroundColor         = UIColor.white
        networkImage.layer.borderColor       = UIColor(red: 215/255, green: 215/255, blue: 215/255, alpha: 0.25).cgColor
        networkImage.contentMode             = .scaleAspectFill
        networkImage.image                   = imgae
        networkImage.layer.cornerRadius      = networkImage.frame.size.width/2
        networkImage.layer.borderWidth       = 1.0
        networkImage.layer.borderWidth       = 1
        networkImage.layer.borderColor       = UIColor.clear.cgColor
        networkImage.layer.masksToBounds     = true
        //Shadow effect
        networkImage.layer.shadowColor       = UIColor.lightGray.cgColor
        networkImage.layer.shadowOffset      = CGSize(width: 0, height: 2)
        networkImage.layer.shadowRadius      = 2.0
        networkImage.layer.shadowOpacity     = 1.0
        networkImage.layer.masksToBounds     = false
        networkImage.layer.backgroundColor   = UIColor.white.cgColor
        
        if !collectionViewSetup{
            collectionViewSetup = true
            setupCollectionView(rect: rect)
        }
    
        self.addSubview(networkImage)
        self.addSubview(collectionView)
        
        if let _ = channelLabel{
            channelLabel!.removeFromSuperview()
        }
        
        let labelSize = CGSize(width: (width - imageSize.width - 10)/2, height: 15)
        let channelLabelOrigon = CGPoint(x: imageSize.width + 15, y: imageSize.height/2 - 10)//imageSize.height )
        channelLabel        = MapDetailLabel(frame: CGRect(origin: channelLabelOrigon, size: labelSize))
        channelLabel!.text   = channel
        self.addSubview(channelLabel!)
        
        if let _ = rssiLabel{
            rssiLabel!.removeFromSuperview()
        }
        
        let rssiLabelOrigon = CGPoint(x: imageSize.width + 15, y: imageSize.height/2 + 15)//imageSize.height )
        rssiLabel        = MapDetailLabel(frame: CGRect(origin: rssiLabelOrigon, size: labelSize))
        rssiLabel!.text   = rssi
        self.addSubview(rssiLabel!)
        
        if let _ = callSignLabel{
            callSignLabel!.removeFromSuperview()
        }
        
        let callSignLabelOrigon = CGPoint(x: width - channelLabel!.frame.size.width - 25, y: imageSize.height/2 - 10)//imageSize.height )
        callSignLabel       = MapDetailLabel(frame: CGRect(origin: callSignLabelOrigon, size: labelSize))
        callSignLabel!.text  = callSign
        callSignLabel!.textAlignment = .right
        self.addSubview(callSignLabel!)
        
        if let _ = towerDistanceLabel{
            towerDistanceLabel!.removeFromSuperview()
        }
        
        let towerDistanceLabelOrigon = CGPoint(x: width - channelLabel!.frame.size.width - 25, y: imageSize.height/2 + 15)//imageSize.height )
        towerDistanceLabel  = MapDetailLabel(frame: CGRect(origin: towerDistanceLabelOrigon, size: labelSize))
        towerDistanceLabel!.text = towerDistance
        towerDistanceLabel!.textAlignment = .right
        self.addSubview(towerDistanceLabel!)
        
        
    }
    
    func reloadCollectionData()
    {
        collectionView.reloadData()
    }

    
    /******************************************************************************/
    // Resize cell image function if we add image to cell view
    /******************************************************************************/
    func resizeImage(image:UIImage, toTheSize size:CGSize)->UIImage
    {
        let scale           = CGFloat(max(size.width/image.size.width, size.height/image.size.height))
        var width:CGFloat   = image.size.width * scale
        var height:CGFloat  = image.size.height * scale;
        var lessThan        = false
        
        //only scale is image is larger that specified size
        print("image width \(image.size.width)")
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
            print("less than image")
            rr = CGRect(x: size.width/2 - (width/2), y: size.width/2 - (height/2), width: width, height: height);
        } else {
            print("expanded image")
            rr = CGRect(x: 0, y: 0, width: width, height: height);
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
    }
}

extension CustomMapDetailView: UICollectionViewDataSource, UICollectionViewDelegate
{
    /******************************************************************************/
    //
    /******************************************************************************/
    func setupCollectionView(rect: CGRect)
    {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 2
        
        layout.itemSize     = CGSize(width: (rect.size.height/2 - 10),height: (rect.size.height/2 - 10))
        let customSize      = CGSize(width: rect.size.width - 10,height: rect.size.height/2)
        let customPoint     = CGPoint(x: rect.origin.x + 5, y: rect.origin.y + rect.size.height - (rect.size.height/2))
        let newFrame        = CGRect(origin: customPoint, size: customSize)
        collectionView      = UICollectionView(frame: newFrame, collectionViewLayout: layout)
        
        collectionView.backgroundColor = UIColor.clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ChannelCollectionViewCell.self,forCellWithReuseIdentifier: "cell")
    }
    
    /******************************************************************************/
    //  Number of section in the collection view
    /******************************************************************************/
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    /******************************************************************************/
    //  Number of section in the collection view
    /******************************************************************************/
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return showImages.count
    }

    /******************************************************************************/
    //  Number of section in the collection view
    /******************************************************************************/
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",for: indexPath) as! ChannelCollectionViewCell
        formatCollectionViewCell(cell: &cell)
        cell.backgroundColor = UIColor.winegardLightBlue
        //cell.channelImageView.image = defaultImages[indexPath.row]
        //cell.awakeFromNib()
        
        if let _ = cell.channelImageView{
        }else {
            //cell.channelImageView.image = defaultImages[indexPath.row]
            cell.awakeFromNib()
        }
        
        return cell
    }
    
    /******************************************************************************/
    //
    /******************************************************************************/
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        let channelCollectionCell = cell as! ChannelCollectionViewCell
        if showImages.indices.contains(indexPath.row){
            channelCollectionCell.channelImageView.image = showImages[indexPath.row]
        }
        
    }
    
    //============================== CELL FORMATTING FUNCTIONS ========================
        func formatCollectionViewCell(cell: inout ChannelCollectionViewCell)
        {
            cell.layer.cornerRadius                 = 5
            cell.contentView.layer.cornerRadius     = 5
            cell.contentView.layer.borderWidth      = 1
            cell.contentView.layer.borderColor      = UIColor.clear.cgColor
            cell.contentView.layer.masksToBounds    = true
            
            //Shadow effect
            cell.layer.shadowColor                  = UIColor.white.cgColor
            cell.layer.shadowOffset                 = CGSize(width: 0, height: 2)
            cell.layer.shadowRadius                 = 2.0
            cell.layer.shadowOpacity                = 1.0
            cell.layer.masksToBounds                = false
            cell.layer.backgroundColor              = UIColor.clear.cgColor
            cell.layer.shadowPath                   = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
            cell.layer.backgroundColor              = UIColor(red: 245/255,green: 245/255,blue: 245/255,alpha: 1).cgColor
        }
    
    
}

class MapDetailLabel: UILabel
{
    override func awakeFromNib() {
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont(name: "Helvetica", size: 20)
        self.textColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
}




