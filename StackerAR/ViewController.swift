//
//  ViewController.swift
//  TestAR
//
//  Created by Andrew Amen on 4/20/18.
//  Copyright © 2018 Andrew Amen. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var allNodes: [SCNNode] = []
    var nodeNum = 0;
    var leftRight = "left"
    var pos = 0.0;
    var gameStarted = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/scene.scn")!
        // Set the scene to the view
        sceneView.scene = scene
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
        
        
        
        //place foundation block
        let node = SCNNode()
        node.geometry = SCNBox(width: 0.2, height: 0.1, length: 0.2, chamferRadius: 0)
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        node.position = SCNVector3(0,0,-0.5)
        self.sceneView.scene.rootNode.addChildNode(node)
        node.name = String(nodeNum);
        allNodes.append(node)
        
        nodeNum += 1;
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func findNode(num: Int) -> SCNNode?{
        for node in allNodes {
            if (node.name == String(num)){
                return node
            }
        }
        return nil
    }
    
    func setColor(_ node: SCNNode){
        
        node.geometry?.firstMaterial?.diffuse.contents = getRandomColor()
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    
    func moveBox(_ node: SCNNode){
        
        if (leftRight == "left"){
            
            node.runAction(SCNAction.moveBy(x: 2, y: 0, z: 0, duration: 2))
            
            leftRight = "right"
        }
        else{
            
            node.runAction(SCNAction.moveBy(x: -2, y: 0, z: 0, duration: 2))
            
            leftRight = "left"
        }
        
        
    }
    
    func setPostition(_ node: SCNNode){
        
        if (leftRight == "left"){
            
            node.position = SCNVector3(-1, pos, -0.5)
            
        }
        else{
            node.position = SCNVector3(1, pos, -0.5)
        }
        
        
    }
    
    
    @objc func addBox() -> SCNNode{
        
        //initilize node
        let newNode = SCNNode()
        newNode.geometry = SCNBox(width: 0.2, height: 0.1, length: 0.2, chamferRadius: 0)
        setColor(newNode)
        newNode.name = String(nodeNum);
        setPostition(newNode)
        
        
        
        
        //add node to stack
        self.sceneView.scene.rootNode.addChildNode(newNode)
        
        moveBox(newNode)
        
        
        /*
         Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(addBox), userInfo: nil, repeats: false)
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
         newNode.removeFromParentNode()
         }
         
         */
        
        
        
        
        return newNode
    }
    
    func fixBoxPos(_ position: SCNVector3){
        
        
        //place foundation block
        let node = SCNNode()
        node.geometry = SCNBox(width: 0.2, height: 0.1, length: 0.2, chamferRadius: 0)
        node.geometry?.firstMaterial?.diffuse.contents = getRandomColor()
        node.position = position
        self.sceneView.scene.rootNode.addChildNode(node)
        
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (gameStarted == false){
            
            pos += 0.1
            
            let newNode = addBox()
            
            allNodes.append(newNode)
            nodeNum += 1;
            
            gameStarted = true
        }
        else{ //game has started
            
            let lastNode = findNode(num: nodeNum - 1)
            let lastNodePos = lastNode!.position
            
            
            fixBoxPos(lastNodePos)
            
            lastNode!.removeFromParentNode()
            
            pos += 0.1
            
            
            let newNode = addBox()
            
            
            
            allNodes.append(newNode)
            nodeNum += 1;
            
        }
        
        
    }
}
