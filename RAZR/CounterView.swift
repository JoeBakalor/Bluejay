//
//  CounterView.swift
//  RAZR
//
//  Created by Joe Bakalor on 5/25/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

let NoOfGlasses = 8
let π: CGFloat = CGFloat(Double.pi)


@IBDesignable

class CounterView: UIView
{
    var percentComplete: CGFloat = 0
    @IBInspectable var counter: Int = 8 {
        didSet {
            if counter <= NoOfGlasses {
                setNeedsDisplay()
            }
        }
    }
    @IBInspectable var outlineColor: UIColor = UIColor.winegardBlue
    @IBInspectable var counterColor: UIColor = UIColor.winegardBlue
    @IBInspectable var backlayerColor: UIColor = UIColor.customGray
    
    var percentStatus: UILabel?
    
    override func draw(_ rect: CGRect)
    {
        
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let diameter: CGFloat = min(bounds.width, bounds.height)
        let arcWidth: CGFloat = 30
        
        var resultAngle: CGFloat!
        
        //start angle = π / 2
        //0-75% = 2pi/4 to 8pi/4
        switch percentComplete{
        case let x where (x >= 0) && (x <= 75): print("")
        
            resultAngle = ((π / 2) + ((6 * π) / 4) * (x / 75))
            
        case let x where (x > 75): print("")
        
            resultAngle = ((π / 2) * ((x - 75) / 25))
            
        default: print("Unknown value")
        }
        
        //Set loading background stroke
        let startAngle: CGFloat = π / 2
        let endAngle: CGFloat =  resultAngle//(π / 2) + (6 * π) / 4//π / 4
        let backPath = UIBezierPath(arcCenter: center, radius: diameter/2 - arcWidth/2 - 1, startAngle: startAngle, endAngle:  0.999999 * (π / 2)  , clockwise: true)
        
        backPath.lineWidth = arcWidth - 2
        backlayerColor.setStroke()
        backPath.stroke()
        
        
        //set primary loading stroke
        let path = UIBezierPath(arcCenter: center, radius: diameter/2 - arcWidth/2 - 1, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        path.lineWidth = arcWidth - 2
        counterColor.setStroke()
        path.stroke()
        

        
        let angleDifference: CGFloat = 2 * π - startAngle + endAngle
        let arcLengthPerGlass = angleDifference / CGFloat(NoOfGlasses)
        let outlineEndAngle = arcLengthPerGlass * CGFloat(counter) + startAngle
        
        var outlinePath = UIBezierPath(arcCenter: center, radius: diameter/2 - 2, startAngle: startAngle, endAngle: outlineEndAngle, clockwise: true)
        
        outlinePath.addArc(withCenter: center, radius: diameter/2 - arcWidth, startAngle: outlineEndAngle, endAngle: startAngle, clockwise: false)
        
        outlinePath.close()
        //UIColor.gray.setStroke()
        outlineColor.setStroke()
        outlinePath.lineWidth = 1.0
        //outlinePath.stroke()

    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


extension UIColor
{
    static var customGray: UIColor{
        return UIColor(red: 225/255, green: 225/255, blue: 220/255, alpha: 1)
    }
}







































