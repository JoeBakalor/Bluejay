//
//  GraphView.swift
//  RAZR
//
//  Created by Joe Bakalor on 5/25/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView
{
    /*==========================================================================================*/
    //
    /*==========================================================================================*/
    @IBInspectable var startColor: UIColor      = UIColor.red
    @IBInspectable var endColor: UIColor        = UIColor.green
    @IBInspectable var lineColor: UIColor       = UIColor.white
    @IBInspectable var axisLineColor: UIColor   = UIColor.black
    @IBInspectable var fillColor: UIColor       = UIColor.white
    /*=====================================================================*/
    //
    /*=====================================================================*/
    var graphPoints = Array(repeating: 0, count: 155)//:[Int] = [4, 2, 6, 4, 5, 8, 3, 10, 20, 7, 5, 6, 8]
    var labelHeight: CGFloat?
    let numberOfVerticalAxis = 32
    //var labelArray: [UILabel] = []
    
    //Axis Labels
    var maxVerticalLabel                        : UILabel?
    
    var minHorizontalLabel                      : UILabel?
    var oneEigthHorizontalLabel                 : UILabel?
    var leftFourthHorizontalLabel               : UILabel?
    var threeEighthsHorizontalLabel             : UILabel?
    var midHorizontalLabel                      : UILabel?
    var fiveEighthsHorizontalLabel              : UILabel?
    var rightFourthHorizontalLabel              : UILabel?
    var sevenEighthsHorizontalLabel             : UILabel?
    var maxHorizontalLabel                      : UILabel?
    var midVerticalLabel                        : UILabel?
    
    /*=====================================================================*/
    //
    /*=====================================================================*/
    override func draw(_ rect: CGRect)
    {
        
        let width                               = rect.width
        let height                              = rect.height
        let testPath                            = UIBezierPath(roundedRect: rect.integral, cornerRadius: 5)
        testPath.addClip()
        let context                             = UIGraphicsGetCurrentContext()
        let colors                              = [startColor.cgColor, endColor.cgColor]
        let colorSpace                          = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat]           = [0.0, 1.0]
        let gradient                            = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        
        var startPoint                          = CGPoint.zero
        var endPoint                            = CGPoint(x: 0, y: self.bounds.height)
        
        context!.drawLinearGradient(gradient!,start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        //calculate the x point
        let margin:CGFloat
            = 30.0
        
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - margin*2 - 4) / CGFloat((self.graphPoints.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        
        //calculate the y point
        let topBorder:CGFloat           = 40
        let bottomBorder:CGFloat        = 40
        let graphHeight                 = height - topBorder - bottomBorder
        let maxValue                    = graphPoints.max()
        
        let columnYPoint = { (graphPoint:Int) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint) /
                CGFloat(maxValue!) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            
            if y >= 0 { return y } else { return 0 }
        }

        let horizontalLabelHeight = height - bottomBorder - 15
        let plotAreaWidth = width - (2 * margin)
        /**************************************************************/
        //Testing label positioning
        /**************************************************************/
        
        /*===================MIN HORIZONTAL LABEL====================*/
        if let _ = minHorizontalLabel{
            minHorizontalLabel!.removeFromSuperview()
        }
        
        let x_mnhl = margin - 30
        //let y_mnhl = horizontalLabelHeight//height - bottomBorder - 15
        
        minHorizontalLabel = UILabel(frame: CGRect(x: x_mnhl, y:  horizontalLabelHeight, width: 60, height: 50).integral)
        minHorizontalLabel!.textAlignment = .center
        minHorizontalLabel!.adjustsFontSizeToFitWidth = true
        minHorizontalLabel!.textColor = UIColor.white
        
        if scanManager.spectrumScanConfig.startFrequency != 0{
            minHorizontalLabel!.text = "\(scanManager.spectrumScanConfig.startFrequency/1_000_000)"
        }
        /*============================================================*/
        
        /*===============ONE EIGHTH HORIZONTAL LABEL==================*/
        if let _ = oneEigthHorizontalLabel{
            oneEigthHorizontalLabel!.removeFromSuperview()
        }
        
        let x_ehl = margin + (plotAreaWidth)/8 - 30
        //let y_ehl = horizontalLabelHeight
        
        oneEigthHorizontalLabel = UILabel(frame: CGRect(x: x_ehl, y:  horizontalLabelHeight, width: 60, height: 50).integral)
        oneEigthHorizontalLabel!.textAlignment = .center
        oneEigthHorizontalLabel!.adjustsFontSizeToFitWidth = true
        oneEigthHorizontalLabel!.textColor = UIColor.white
        
        if scanManager.spectrumScanConfig.stopFrequency != 0{
            
            let stop = scanManager.spectrumScanConfig.stopFrequency/1_000_000
            let start = scanManager.spectrumScanConfig.startFrequency/1_000_000
            
            oneEigthHorizontalLabel!.text = "\(((stop - start)/8) + (start))"
        }
        /*============================================================*/
        
        /*=================LEFT FOURTH HORIZONTAL VALUE=======================*/
        if let _ = leftFourthHorizontalLabel{
            leftFourthHorizontalLabel!.removeFromSuperview()
        }
        
        let x_lfh = margin + (plotAreaWidth)/4 - 30
        //let y_lfh = height - bottomBorder - 15
        
        leftFourthHorizontalLabel = UILabel(frame: CGRect(x: x_lfh, y: horizontalLabelHeight, width: 60, height: 50).integral)
        leftFourthHorizontalLabel!.textAlignment                = .center
        leftFourthHorizontalLabel!.adjustsFontSizeToFitWidth    = true
        leftFourthHorizontalLabel!.textColor                    = UIColor.white
        
        if scanManager.spectrumScanConfig.stopFrequency != 0{
            
            let stop = scanManager.spectrumScanConfig.stopFrequency/1_000_000
            let start = scanManager.spectrumScanConfig.startFrequency/1_000_000
            
            leftFourthHorizontalLabel!.text = "\(((stop - start)/4) + (start))"
        }
        /*============================================================*/
        
        /*===============THREE EIGHTHS HORIZONTAL LABEL===============*/
        if let _ = threeEighthsHorizontalLabel{
            threeEighthsHorizontalLabel!.removeFromSuperview()
        }
        
        let x_tehl = margin + (3 * (plotAreaWidth))/8 - 30
        //let y_ehl = horizontalLabelHeight
        
        threeEighthsHorizontalLabel = UILabel(frame: CGRect(x: x_tehl, y:  horizontalLabelHeight, width: 60, height: 50).integral)
        threeEighthsHorizontalLabel!.textAlignment = .center
        threeEighthsHorizontalLabel!.adjustsFontSizeToFitWidth = true
        threeEighthsHorizontalLabel!.textColor = UIColor.white
        
        if scanManager.spectrumScanConfig.stopFrequency != 0{
            
            let stop = scanManager.spectrumScanConfig.stopFrequency/1_000_000
            let start = scanManager.spectrumScanConfig.startFrequency/1_000_000
            
            threeEighthsHorizontalLabel!.text = "\((3*((stop - start)/8)) + (start))"
        }
        /*============================================================*/
        
        /*=================MID HORIZONTAL VALUE=======================*/
        if let _ = midHorizontalLabel{
            midHorizontalLabel!.removeFromSuperview()
        }
        
        let x_mhl = margin + (plotAreaWidth)/2 - 30
        let y_mhl = height - bottomBorder - 15
        
        midHorizontalLabel = UILabel(frame: CGRect(x: x_mhl, y: y_mhl, width: 60, height: 50).integral)
        midHorizontalLabel!.textAlignment                       = .center
        midHorizontalLabel!.adjustsFontSizeToFitWidth           = true
        midHorizontalLabel!.textColor                           = UIColor.white
        
        if scanManager.spectrumScanConfig.stopFrequency != 0{
            
            let stop = scanManager.spectrumScanConfig.stopFrequency/1_000_000
            let start = scanManager.spectrumScanConfig.startFrequency/1_000_000
            
            midHorizontalLabel!.text = "\(((stop - start)/2) + (start))"
        }
        /*============================================================*/
        
        /*================FIVE EIGHTHS HORIZONTAL LABEL===============*/
        if let _ = fiveEighthsHorizontalLabel{
            fiveEighthsHorizontalLabel!.removeFromSuperview()
        }
        
        let x_fehl = margin + (5 * (plotAreaWidth))/8 - 30
        //let y_ehl = horizontalLabelHeight
        
        fiveEighthsHorizontalLabel = UILabel(frame: CGRect(x: x_fehl, y:  horizontalLabelHeight, width: 60, height: 50).integral)
        fiveEighthsHorizontalLabel!.textAlignment = .center
        fiveEighthsHorizontalLabel!.adjustsFontSizeToFitWidth = true
        fiveEighthsHorizontalLabel!.textColor = UIColor.white
        
        if scanManager.spectrumScanConfig.stopFrequency != 0{
            
            let stop = scanManager.spectrumScanConfig.stopFrequency/1_000_000
            let start = scanManager.spectrumScanConfig.startFrequency/1_000_000
            
            fiveEighthsHorizontalLabel!.text = "\((5*((stop - start)/8)) + (start))"
        }
        /*============================================================*/
        
        /*=================RIGHT FOURTH HORIZONTAL VALUE=======================*/
        if let _ = rightFourthHorizontalLabel{
            rightFourthHorizontalLabel!.removeFromSuperview()
        }
        
        let x_rfh = margin + (3 * (plotAreaWidth)) / 4 - 30 //width - (width/4) - 45
        let y_rfh = height - bottomBorder - 15
        
        rightFourthHorizontalLabel = UILabel(frame: CGRect(x: x_rfh, y: y_rfh, width: 60, height: 50).integral)
        rightFourthHorizontalLabel!.textAlignment               = .center
        rightFourthHorizontalLabel!.adjustsFontSizeToFitWidth   = true
        rightFourthHorizontalLabel!.textColor                   = UIColor.white
        
        if scanManager.spectrumScanConfig.stopFrequency != 0{
            
            let stop = scanManager.spectrumScanConfig.stopFrequency/1_000_000
            let start = scanManager.spectrumScanConfig.startFrequency/1_000_000
            rightFourthHorizontalLabel!.text = "\(stop - (stop - start)/4)"
        }
        /*============================================================*/
        
        /*=============== SEVEN EIGHTHS HORIZONTAL LABEL==============*/
        if let _ = sevenEighthsHorizontalLabel{
            sevenEighthsHorizontalLabel!.removeFromSuperview()
        }
        
        let x_sehl = margin + (7 * (plotAreaWidth)) / 8 - 30//(7 * (width/8)) - 30
        //let y_ehl = horizontalLabelHeight
        
        sevenEighthsHorizontalLabel = UILabel(frame: CGRect(x: x_sehl, y:  horizontalLabelHeight, width: 60, height: 50).integral)
        sevenEighthsHorizontalLabel!.textAlignment               = .center
        sevenEighthsHorizontalLabel!.adjustsFontSizeToFitWidth = true
        sevenEighthsHorizontalLabel!.textColor = UIColor.white
        
        if scanManager.spectrumScanConfig.stopFrequency != 0{
            
            let stop = scanManager.spectrumScanConfig.stopFrequency/1_000_000
            let start = scanManager.spectrumScanConfig.startFrequency/1_000_000
            
            sevenEighthsHorizontalLabel!.text = "\((7*((stop - start)/8)) + (start))"
        }
        /*============================================================*/
        
        /*===================MAX HORIZONTAL LABEL=====================*/
        if let _ = maxHorizontalLabel{
             maxHorizontalLabel!.removeFromSuperview()
        }
        
        let x_mxhl = margin + plotAreaWidth - 30 //width - margin - 15
        let y_mxhl = height - bottomBorder - 15
        
        maxHorizontalLabel = UILabel(frame: CGRect(x: x_mxhl, y:  y_mxhl, width: 60, height: 50).integral)
        maxHorizontalLabel!.textAlignment               = .center
        maxHorizontalLabel!.adjustsFontSizeToFitWidth = true
        maxHorizontalLabel!.textColor = UIColor.white
        
        if scanManager.spectrumScanConfig.stopFrequency != 0{
            maxHorizontalLabel!.text = "\(scanManager.spectrumScanConfig.stopFrequency/1_000_000)"
        }
        /*============================================================*/
        
        /*=================MAX VERTICAL LABEL=========================*/
        if let _ = maxVerticalLabel{
            maxVerticalLabel!.removeFromSuperview()
        }
    
        let x_vertical = margin + (plotAreaWidth) - 15
        maxVerticalLabel = UILabel(frame: CGRect(x: x_vertical, y: topBorder - 25, width: 60, height: 50).integral)
        maxVerticalLabel!.textAlignment = .center
        maxVerticalLabel!.adjustsFontSizeToFitWidth = true
        maxVerticalLabel!.textColor = UIColor.white
        let maxGraphPoint = graphPoints.max()
        
        maxVerticalLabel!.text = "\(maxGraphPoint!)"
        /*============================================================*/
        
        /*=================MAX VERTICAL LABEL=========================*/
        if let _ = midVerticalLabel{
            midVerticalLabel!.removeFromSuperview()
        }
        
        //let xmid_vertical = margin + (width - (2 * margin)) - 15
        
        midVerticalLabel = UILabel(frame: CGRect(x: x_vertical, y: topBorder - 25 + (height - topBorder * 2)/2, width: 60, height: 50).integral)
        midVerticalLabel!.textAlignment = .center
        midVerticalLabel!.adjustsFontSizeToFitWidth = true
        midVerticalLabel!.textColor = UIColor.white
        var midGraphPoint = Int(graphPoints.max()!/2)
        
        midVerticalLabel!.text = "\(midGraphPoint)"
        /*============================================================*/
        //  ADD LABELS
        self.addSubview(maxVerticalLabel!)
        self.addSubview(minHorizontalLabel!)
        self.addSubview(oneEigthHorizontalLabel!)
        self.addSubview(leftFourthHorizontalLabel!)
        self.addSubview(threeEighthsHorizontalLabel!)
        self.addSubview(midHorizontalLabel!)
        self.addSubview(fiveEighthsHorizontalLabel!)
        self.addSubview(rightFourthHorizontalLabel!)
        self.addSubview(sevenEighthsHorizontalLabel!)
        self.addSubview(maxHorizontalLabel!)
        self.addSubview(midVerticalLabel!)
        
        // draw the line graph
        fillColor.setFill()
        lineColor.setStroke()
        
        //set up the points line
        var graphPath = UIBezierPath()
        
        //go to start of line
        graphPath.move(to: CGPoint(x:columnXPoint(0), y:columnYPoint(graphPoints[0])))
        
        //add points for each item in the graphPoints array
        //at the correct (x, y) for the point
        for i in 1..<graphPoints.count {
            graphPath.move(to: CGPoint(x:columnXPoint(i), y: height - bottomBorder))
            let nextPoint = CGPoint(x:columnXPoint(i), y:columnYPoint(graphPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        
        //Create the clipping path for the graph gradient
        
        //1 - save the state of the context
        context!.saveGState()
        
        //2 - make a copy of the path
        var clippingPath = graphPath.copy() as! UIBezierPath
        
        //3 - add lines to the copied path to complete the clip area
        clippingPath.addLine(to: CGPoint(x: columnXPoint(graphPoints.count - 1), y:height))
        clippingPath.addLine(to: CGPoint(x:columnXPoint(0), y:height))
        clippingPath.close()
        
        //4 - add the clipping path to the context
        clippingPath.addClip()
        
        let highestYPoint = columnYPoint(maxValue!)
        startPoint = CGPoint(x:margin, y: highestYPoint)
        endPoint = CGPoint(x:margin, y:self.bounds.height)
        
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        context!.restoreGState()
        
        //draw the line on top of the clipped gradient
        graphPath.lineWidth = 1
        graphPath.stroke()

        /**************************************************************/
        //Draw horizontal graph lines on the top of everything
        /**************************************************************/
        var linePath = UIBezierPath()
        
        //top line
        linePath.move(to: CGPoint(x:margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y:topBorder))
        
        //center line
        linePath.move(to: CGPoint(x:margin, y: graphHeight/2 + topBorder))
        linePath.addLine(to: CGPoint(x:width - margin, y:graphHeight/2 + topBorder))
        
        //bottom line
        linePath.move(to: CGPoint(x:margin, y:height - bottomBorder))
        linePath.addLine(to: CGPoint(x:width - margin, y:height - bottomBorder))
        
        /**************************************************************/
        //Draw vertical graph lines for each horizontal label
        /**************************************************************/
        
        let incrimentBetweenLabels = plotAreaWidth/CGFloat(numberOfVerticalAxis)
        let yStart = height - bottomBorder
        let yEnd = topBorder
        
        //add vertical lines except for 0 and max horizontal
        for pointNumber in 1...(numberOfVerticalAxis - 1) {
            if pointNumber == 1{
                let multiplyer = CGFloat(pointNumber)
                linePath.move(to: CGPoint(x: (incrimentBetweenLabels * multiplyer) + margin, y: yStart))
                linePath.addLine(to: CGPoint(x: (incrimentBetweenLabels * multiplyer) + margin, y: yEnd))
            } else {
                let multiplyer = CGFloat(pointNumber)
                linePath.move(to: CGPoint(x: incrimentBetweenLabels * multiplyer + margin, y: yStart))
                linePath.addLine(to: CGPoint(x: incrimentBetweenLabels * multiplyer + margin, y: yEnd))
            }

        }
        
        //let alternateColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        let color = UIColor(white: 1.0, alpha: 0.25)
        color.withAlphaComponent(0.01)
        
        color.setStroke()
        linePath.lineWidth = 0.5
        linePath.stroke()

    }


}



extension GraphView
{
    func addVerticalLine(label: inout UILabel)
    {
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white
    }
    
    /**************************************************************/
    //  Horizontal Label Placement
    /**************************************************************/
    func placeHorizontalLabels()
    {
        
    }
}















//Draw the circles on top of graph stroke
//        for i in 0..<graphPoints.count {
//            var point = CGPoint(x:columnXPoint(i), y:columnYPoint(graphPoints[i]))
//            point.x -= 3.0/2
//            point.y -= 3.0/2
//
//            let circle = UIBezierPath(ovalIn:
//                CGRect(origin: point,
//                       size: CGSize(width: 3.0, height: 3.0)))
//            circle.fill()
//        }


/**************************************************************/
//Draw vertical graph lines
/**************************************************************/
//        labelHeight = height - bottomBorder
//        for i in 0...graphPoints.count{
//
//            //let newPostion = margin + (margin / CGFloat(graphPoints.count - 2) * CGFloat(i))
//            linePath.move(to: CGPoint(x: columnXPoint(i), y:topBorder - 10))
//            linePath.addLine(to: CGPoint(x: columnXPoint(i), y: height - bottomBorder))
//        }
/**************************************************************/

