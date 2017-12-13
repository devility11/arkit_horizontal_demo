//
//  ViewController.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Jayven Nhan on 11/14/17.
//  Copyright © 2017 Jayven Nhan. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment to configure lighting
        configureLighting()
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        addTapGestureToSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        
        let configuration = ARWorldTrackingConfiguration()
        //detecting the horizontal plane
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        //after the VC extension we need to add the delegete methods
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer){
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation = hitTestResult.worldTransform.translation
        let x = translation.x
        let y = translation.y
        let z = translation.z
        
        guard let shipScene = SCNScene(named: "ship.scn"),
        let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: false)
            else { return }
        
        shipNode.position = SCNVector3(x,y,z)
        sceneView.scene.rootNode.addChildNode(shipNode)

    }
    
    func addTapGestureToSceneView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addShipToSceneView(withGestureRecognizer:)))
            sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    
}

//to detect the horizontal plane
extension ViewController: ARSCNViewDelegate {
    //This protocol method gets called every time the scene view’s session has a new ARAnchor added.
    //An ARAnchor is an object that represents a physical location and orientation in 3D space.
    //We will use the ARAnchor later for detecting a horizontal plane.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //safely unwrap the anchor argument as an ARPlaneAnchor
        //to we can be sure that we have information about a detected
        // real world flat surface
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        //we create an SCPlane to visualize the ARPlaneAnchor
        //SCNPlane is a rectangular(4szögletes) "one-sided" plane geometry
        //
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // the transparent light blue color
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        // initilaize SCNNode with the SCNPlane geometry
        let planeNode = SCNNode(geometry: plane)
        
        // initialize x,y,z to represent the planeanchors center x,y,z.
        
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        
        planeNode.position = SCNVector3(x,y,z)
        //rotate the planenode x euler angle by 90 degrees in the counter-clockwise direction
        planeNode.eulerAngles.x = -.pi / 2
        
        //we add the planenode onto the scenekit node
        node.addChildNode(planeNode)
    }
    //this method gets called everytime a SceneKit nodes properties have been updated to match its
    //corresponding anchor. This is where ARKit refines its estimation of the horizontal plane’s position and extent.
    // the node argument gives us the updated position of the anchor
    // the anchor argument gives us the anchor updated width and height
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //1
        guard let planeAnchor = anchor as? ARPlaneAnchor,
        let planeNode = node.childNodes.first,
        let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        //2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        //3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        
    }
    
    
}


extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}






