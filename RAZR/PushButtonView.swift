//
//  PushButtonView.swift
//  RAZR
//
//  Created by Joe Bakalor on 5/25/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit
@IBDesignable


class PushButtonView: UIButton
{
    @IBInspectable var fillColor: UIColor = UIColor.green
    @IBInspectable var isAddButton: Bool = true
    
    override func draw(_ rect: CGRect) {
        var path = UIBezierPath(ovalIn: rect)
        //UIColor.green.setFill()
        fillColor.setFill()
        path.fill()
        
        let plusLineThickness: CGFloat = 3.0
        let plusLength: CGFloat = min(bounds.width, bounds.height) * 0.6
        
        
//        var plusPath = UIBezierPath()
//        plusPath.lineWidth = plusLineThickness
//        
//        plusPath.move(to: CGPoint(x: bounds.width/2 - plusLength/2 + 0.5, y: bounds.height/2 + 0.5))
//        
//        plusPath.addLine(to: CGPoint(x: bounds.width/2 + plusLength/2 + 0.5, y: bounds.height/2 + 0.5))
//        
//        
//        if isAddButton
//        {
//            plusPath.move(to: CGPoint(x: bounds.width/2 + 0.5, y: bounds.height/2 - plusLength/2 + 0.5))
//            
//            plusPath.addLine(to: CGPoint(x: bounds.width/2 + 0.5, y: bounds.height/2 + plusLength/2 + 0.5))
//        }
//        
//        
//        UIColor.white.setStroke()
//        plusPath.stroke()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
