//
//  ViewController.swift
//  myPortal
//
//  Created by Harold Couch on 3/28/18.
//  Copyright © 2018 Harold Couch. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreMotion

class ViewController: UIViewController, ARSCNViewDelegate {

    let motionManager = CMMotionManager()
    let cameraNode = SCNNode()
    var scene:SCNScene!

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(reverse(text: "stressed"))
        
        scene = SCNScene()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.allowsCameraControl = true
        
        loadBox()
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(cameraNode)
        
        sceneView.allowsCameraControl = true

    }
    
    func reverse(text: String) -> String {
        
        return String(text.reversed())
        
    }
    
    func loadSphere()
    {
        guard let imagePath = Bundle.main.path(forResource: "multimaze", ofType: "png") else {
            fatalError("Failed to find path for panaromic file.")
        }
        guard let image = UIImage(contentsOfFile:imagePath) else {
            fatalError("Failed to load panoramic image")
        }

        let sphere = SCNSphere(radius: 1.0)
        sphere.firstMaterial!.isDoubleSided = true
        sphere.firstMaterial!.diffuse.contents = image
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3Make(0,0,0)
        scene.rootNode.addChildNode(sphereNode)
    }
    
    func loadBox()
    {
        let wallBox = SCNBox(width: 3, height: 3, length: 3, chamferRadius: 0)
        let wallNode = SCNNode(geometry: wallBox)
        
        wallNode.name = "wall"
        wallNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(Double.pi))
        wallNode.position = SCNVector3Make(0,0,0)
        
        let colors = [UIColor.green, // front
            UIColor.red, // right
            UIColor.blue, // back
            UIColor.yellow, // left
            UIColor.purple, // top
            UIColor.gray] // bottom
        
        let sideMaterials = colors.map { color -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
            return material
        }
        
        wallNode.geometry!.materials = sideMaterials
        
        for i in 0 ..< 6
        {
            wallNode.geometry?.materials[i].isDoubleSided = true
        }
        
        wallNode.castsShadow = false
        wallNode.position = SCNVector3Make(0.5, 0.0, 0.0)
        scene.rootNode.addChildNode(wallNode)
        
        
        let myscene = SCNScene(named: "art.scnassets/gownfigure1.dae")!
        let objNode = myscene.rootNode.childNode(withName: "gown1", recursively: true)!
        objNode.position = SCNVector3Make(0, 0, -3)
        objNode.name = "greenGuy"
        wallNode.addChildNode(objNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor)
    {
        // Place content only for anchors found by plane detection.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        // Create a SceneKit plane to visualize the plane anchor using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.simdPosition = SIMD3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        /* SCNPlane` is vertically oriented in its local coordinate space, so rotate the plane to match the horizontal orientation of `ARPlaneAnchor`.*/
        planeNode.eulerAngles.x = -.pi / 2
        
        // Make the plane visualization semitransparent to clearly show real-world placement.
        planeNode.opacity = 0.25
        
        /* Add the plane visualization to the ARKit-managed node so that it tracks changes in the plane anchor as plane estimation continues.*/
        node.addChildNode(planeNode)
    }
    
    /// - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update content only for plane anchors and nodes matching the setup created in renderer(_:didAdd:for:)`.
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // Plane estimation may shift the center of a plane relative to its anchor's transform.
        planeNode.simdPosition = SIMD3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        /* Plane estimation may extend the size of the plane, or combine previously detected planes into a larger one. In the latter case, `ARSCNView` automatically deletes the corresponding node for one plane, then calls this method to update the size of the remaining plane.*/
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.height = CGFloat(planeAnchor.extent.z)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
