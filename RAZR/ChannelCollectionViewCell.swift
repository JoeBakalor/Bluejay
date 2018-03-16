//
//  ChannelCollectionViewCell.swift
//  RAZR
//
//  Created by Joe Bakalor on 7/27/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    var channelImageView: UIImageView!
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    override func awakeFromNib()
    {
        
        let customSize = CGSize(width: contentView.frame.width * 0.85, height: contentView.frame.height * 0.85)
        let customPoint = CGPoint(x: contentView.frame.origin.x + contentView.frame.width*0.075, y: contentView.frame.origin.y + contentView.frame.height*0.075)
        //let customSize = CGSize(width: contentView.frame.width * 0.75, height: 200)
        //let customPoint = CGPoint(x: 10, y: -10)
        let newFrame = CGRect(origin: customPoint, size: customSize)
        channelImageView = UIImageView(frame: newFrame)
        channelImageView.contentMode = .scaleAspectFit
        //widgetImageView.clipsToBounds = true
        
        contentView.addSubview(channelImageView)
    }
}
