//
//  TopAlignedUILabel.swift
//  RAZR
//
//  Created by Joe Bakalor on 6/6/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

@IBDesignable
class TopAlignedUILabel: UILabel
{
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    override func drawText(in rect: CGRect)
    {
        if let stringText = text {
            
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil).size
            super.drawText(in: CGRect(x: 0, y: 0, width: self.frame.width, height: ceil(labelStringSize.height)))
            var rotate = CGAffineTransform.init(rotationAngle: CGFloat(-Double.pi/2))
            super.layer.setAffineTransform(rotate)
            
        } else {
            
            super.drawText(in: rect)
        }
    }
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    override func prepareForInterfaceBuilder()
    {
        super.prepareForInterfaceBuilder()
        //layer.borderWidth = 1
        //layer.borderColor = UIColor.black.cgColor
        
    }
    /*==========================================================================================*/
    //
    /*==========================================================================================*/

}
