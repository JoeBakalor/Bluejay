//
//  WidgetCollectionViewCell.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/5/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit


//@IBDesignable
class WidgetCollectionViewCell: UICollectionViewCell
{
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    var widgetImageView: UIImageView!
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    override func awakeFromNib()
    {
        
        let customSize = CGSize(width: contentView.frame.width * 0.75, height: contentView.frame.height * 0.75)
        let customPoint = CGPoint(x: contentView.frame.origin.x + contentView.frame.width*0.125, y: contentView.frame.origin.y + contentView.frame.height*0.125)
        let newFrame = CGRect(origin: customPoint, size: customSize)
        widgetImageView = UIImageView(frame: newFrame)
        widgetImageView.contentMode = .scaleAspectFill
        //widgetImageView.clipsToBounds = true
        
        contentView.addSubview(widgetImageView)
    }
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    
}
