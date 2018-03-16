//
//  ViewController.swift
//  ARKitExperimenting
//
//  Created by Joe Bakalor on 8/21/17.
//  Copyright © 2017 Joe Bakalor. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addCube(_ sender: UIButton) {
        
        let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
        
        let cc = getCameraCoordinates(sceneView: sceneView)
        cubeNode.position = SCNVector3(cc.x, cc.y, cc.z - 1)
        
        sceneView.scene.rootNode.addChildNode(cubeNode)
    }
    
    struct cameraCoordinates{
        var x = Float()
        var y = Float()
        var z = Float()
    }
    
    func getCameraCoordinates(sceneView: ARSCNView) -> cameraCoordinates{
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let myCameraCoordinates = MDLTransform(matrix: cameraTransform!)
        
        var cc = cameraCoordinates()
        cc.z = myCameraCoordinates.translation.z
        cc.x = myCameraCoordinates.translation.x
        cc.y = myCameraCoordinates.translation.y
        
        return cc
    }
    
    @IBAction func addCup(_ sender: UIButton)
    {
        let chairNode = SCNNode()
        
        let cc = getCameraCoordinates(sceneView: sceneView)
        chairNode.position = SCNVector3(cc.x, cc.y, cc.z)
        
        print("Made it to guard statement")
        //let something = SCNScene(named: "cup.scn", inDirectory: "Models.scnassets/cup", options: nil)
        //let someScene = SCNScene(named: "cup.scn")
        guard let vitrualObjectsScene = SCNScene(named: "vase.scn", inDirectory: "Models.scnassets", options: nil) else {
            print("Failed")
            return
        }
        
        print("Made it past guard statement")
        let wrapperNode = SCNNode()
        
        for child in vitrualObjectsScene.rootNode.childNodes{
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            wrapperNode.addChildNode(child)
        }
        
        chairNode.addChildNode(wrapperNode)
        sceneView.scene.rootNode.addChildNode(chairNode)
        
    }
    
}

