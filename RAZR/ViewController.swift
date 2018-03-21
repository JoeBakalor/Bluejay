//
//  ViewController.swift
//  RAZR
//
//  Created by Joe Bakalor on 5/25/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var counterView: CounterView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var averageWaterDrunk: UILabel!
    
    
    var isGraphShowing = false
    //var otaFileParser: OTAFileParser?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        counterLabel.text = "\(counterView.counter)"
        //otaFileParser =  OTAFileParser()
        
        //graphView.
        
        // Get the document directory url
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
//            let mp3Files = directoryContents.filter{ $0.pathExtension == "mp3" }
//            print("mp3 urls:",mp3Files)
//            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
//            print("mp3 list:", mp3FileNames)
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let fileManager = FileManager.default
        var documentPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        //let inboxPath = documentPaths[0].appendingPathComponent("Inbox")
        //let oldFilePath = inboxPath.appendingPathComponent(url.lastPathComponent)
        
        //let theFileName = (url.deletingPathExtension()).lastPathComponent
        let newFilePath = documentPaths[0].appendingPathComponent("KitProg2_1.cyacd")
        
        do {
            
            let testTwo = try String(contentsOf: newFilePath, encoding: String.Encoding.utf8)
            print("Load OTA Binary from Documents Directory")
            print("File As String = \(testTwo)")
            
        } catch {
            
            print("Didnt work \(error)")
        }
        // Do any additional setup after loading the view.
    }
    
    func setupGraphDisplay()
    {
        
        //Use 7 days for graph - can use any number,
        //but labels and sample data are set up for 7 days
        let noOfDays:Int = 7
        
        //1 - replace last day with today's actual data
        graphView.graphPoints[graphView.graphPoints.count-1] = counterView.counter
        
        //2 - indicate that the graph needs to be redrawn
        graphView.setNeedsDisplay()
        
        maxLabel.text = "\((graphView.graphPoints).max()!)"
        
        //3 - calculate average from graphPoints
        let average = graphView.graphPoints.reduce(0, +)
            / graphView.graphPoints.count
        averageWaterDrunk.text = "\(average)"
        
        //set up labels
        //day of week labels are set up in storyboard with tags
        //today is last day of the array need to go backwards
        
        //4 - get today's day number
        let dateFormatter = DateFormatter()
        let calendar = NSCalendar.current
        let componentOptions:NSCalendar.Unit = .weekday
        //let set: []
        let components = calendar.dateComponents( [.weekday] ,
                                             from: NSDate() as Date)
        var weekday = components.weekday
        
        let days = ["S", "S", "M", "T", "W", "T", "F"]
        
        //5 - set up the day name labels with correct day
        for i in (1...days.count).reversed() {
            if let labelView = graphView.viewWithTag(i) as? UILabel {
                if weekday == 7 {
                    weekday = 0
                }
                labelView.text = days[weekday!]
                weekday! -= 1
                if weekday! < 0 {
                    weekday = days.count - 1
                }
            }
        }
    }

    @IBAction func counterViewTap(_ sender: UITapGestureRecognizer?)
    {
        if (isGraphShowing) {
            UIView.transition(from: graphView, to: counterView, duration: 1.0, options: [UIViewAnimationOptions.transitionFlipFromLeft, UIViewAnimationOptions.showHideTransitionViews], completion: nil)
            isGraphShowing = false
            
        } else {
            UIView.transition(from: counterView, to: graphView, duration: 1.0, options: [UIViewAnimationOptions.transitionFlipFromRight, UIViewAnimationOptions.showHideTransitionViews], completion: nil)
            setupGraphDisplay()
            isGraphShowing = true
        }
        
        
    }


    
    
    @IBAction func pushButton(_ sender: PushButtonView)
    {
        if sender.isAddButton{
            
            counterView.counter += 1
            if counterView.counter == 9{
                counterView.counter = 8
            }
            
        } else {
            
            if counterView.counter > 0 {
                counterView.counter -= 1
            }
        }
        counterLabel.text = "\(counterView.counter)"
        
        if isGraphShowing {
            counterViewTap(nil)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
