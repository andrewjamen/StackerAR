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
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var allNodes: [SCNNode] = []
    var nodeNum = 0
    var leftRight = "left"
    var pos = -0.8
    var gameStarted = false
    var leftBound:Float = -0.1
    var rightBound:Float = 0.1
    var currentBoxWidth: Float = 0.2
    var lastBoxWidth: Float!
    var lastBox: SCNNode!
    var tappedBox: SCNNode!
    var scoreLbl: UILabel!
    var currentColor: UIColor!
    var gameLost = false
    var speed = 6.0
    let systemSoundID: SystemSoundID = 1103
    //let systemSoundID: SystemSoundID = 1306
    let audioSource = SCNAudioSource(named: "tick.mp3")!
    
    
    
    
    var score = 0 {
        didSet {
            scoreLbl.text = "\(score)"
        }
    }
    
    
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
        node.position = SCNVector3(0, -0.8, -0.5)
        self.sceneView.scene.rootNode.addChildNode(node)


        lastBox = node
        
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
        
        currentColor = getRandomColor()
        
        node.geometry?.firstMaterial?.diffuse.contents = currentColor
    }
    
    func getRandomColor() -> UIColor{
        
        let randomRed:CGFloat = CGFloat(drand48())
        
        let randomGreen:CGFloat = CGFloat(drand48())
        
        let randomBlue:CGFloat = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        
    }
    
    func moveBox(_ node: SCNNode){
        
        let leftPos = SCNVector3(-1, pos, -0.5)
        let rightPos = SCNVector3(1, pos, -0.5)
        

        if (SCNVector3EqualToVector3(node.position, leftPos)){ //move right
            
            node.runAction(SCNAction.moveBy(x: 2, y: 0, z: 0, duration: speed))
        }
        
        else if (SCNVector3EqualToVector3(node.position, rightPos)){//move left
            
             node.runAction(SCNAction.moveBy(x: -2, y: 0, z: 0, duration: speed))
        }
        
        speed -= 0.2


        
    }
    

    
    func setPostition(_ node: SCNNode){
        
        if (leftRight == "left"){
            
            node.position = SCNVector3(-1, pos, -0.5)
            
        }
        else{
            node.position = SCNVector3(1, pos, -0.5)
        }
        
        
    }
    
    
    func addBox() -> SCNNode{
        
        //initilize node
        let newNode = SCNNode()
        newNode.geometry = SCNBox(width: CGFloat(currentBoxWidth), height: 0.1, length: 0.2, chamferRadius: 0)
        setColor(newNode)
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
    
    
    func boxFall(_ leftRight: String){
        
        let node = SCNNode()
        var width: Float
        
        
        let tappedBoxPos = tappedBox.position
        
        
        let tappedBoxLeftEdge = tappedBoxPos.x - (lastBoxWidth / 2)
        let tappedBoxRightEdge = tappedBoxPos.x + (lastBoxWidth / 2)
        
        

        if (leftRight == "right"){//too far right
            
            
            
            width = tappedBoxRightEdge - rightBound
            
            let newPosition = rightBound + (width / 2)
            
            
            
            node.geometry = SCNBox(width: CGFloat(width), height: 0.1, length: 0.2, chamferRadius: 0)
            node.geometry?.firstMaterial?.diffuse.contents = currentColor
            node.position = SCNVector3(Double(newPosition), pos, -0.5)
            

            node.runAction(SCNAction.moveBy(x: 0, y: -10, z: 0, duration: 10))
            node.runAction(SCNAction.fadeOut(duration: 5.0))

            
            self.sceneView.scene.rootNode.addChildNode(node)
            
            
            
        }
        else{ // too far left
            
            
            width = leftBound - tappedBoxLeftEdge
            
            let newPosition = leftBound - (width / 2)
            
            
            node.geometry = SCNBox(width: CGFloat(width), height: 0.1, length: 0.2, chamferRadius: 0)
            node.geometry?.firstMaterial?.diffuse.contents = currentColor
            node.position = SCNVector3(Double(newPosition), pos, -0.5)
            
            node.runAction(SCNAction.moveBy(x: 0, y: -10, z: 0, duration: 10))
            node.runAction(SCNAction.fadeOut(duration: 5.0))
            
            self.sceneView.scene.rootNode.addChildNode(node)

        }

    }
    
    
    
    
    
    
    func fixBoxPos(_ color: UIColor) -> SCNNode?{
        
        //AudioServicesPlaySystemSound (systemSoundID)
        

        
        let node = SCNNode()
        
        node.runAction(SCNAction.playAudio(audioSource, waitForCompletion: false))
        
        let lastBoxPos = lastBox.position
        let tappedBoxPos = tappedBox.position
        
        
        let tappedBoxLeftEdge = tappedBoxPos.x - (currentBoxWidth / 2)
        let tappedBoxRightEdge = tappedBoxPos.x + (currentBoxWidth / 2)
        

        let difference = tappedBoxPos.x - lastBoxPos.x
        
        lastBoxWidth = currentBoxWidth
        
        
        if !(tappedBoxRightEdge > leftBound && tappedBoxLeftEdge < rightBound){ // miss
            
            gameLost = true
            return nil
        }
        
        

        if (difference == 0){ //perfect hit

            node.geometry = SCNBox(width: 0.2, height: 0.1, length: 0.2, chamferRadius: 0)
            node.geometry?.firstMaterial?.diffuse.contents = color
            node.position = tappedBox.position
            self.sceneView.scene.rootNode.addChildNode(node)
        }
        else if (difference > 0){//too far right, shrink left bound

            currentBoxWidth = rightBound - tappedBoxLeftEdge
            
            let newPosition = tappedBoxLeftEdge + (currentBoxWidth / 2)
            
            
            
            node.geometry = SCNBox(width: CGFloat(currentBoxWidth), height: 0.1, length: 0.2, chamferRadius: 0)
            node.geometry?.firstMaterial?.diffuse.contents = color
            node.position = SCNVector3(Double(newPosition), pos, -0.5)
            self.sceneView.scene.rootNode.addChildNode(node)

            
            leftBound = tappedBoxLeftEdge
            
            
            boxFall("right")
            
        }
        else if(difference < 0){
            
            
            currentBoxWidth = tappedBoxRightEdge - leftBound
            
            let newPosition = leftBound + (currentBoxWidth / 2)
            

            node.geometry = SCNBox(width: CGFloat(currentBoxWidth), height: 0.1, length: 0.2, chamferRadius: 0)
            node.geometry?.firstMaterial?.diffuse.contents = color
            node.position = SCNVector3(Double(newPosition), pos, -0.5)
            self.sceneView.scene.rootNode.addChildNode(node)
            
            
            rightBound = tappedBoxRightEdge
            
            
            boxFall("left")
            
        }
        

        return node
        
    }
    
    
    
    func gameOver(){
        
        scoreLbl.textColor = .orange
        scoreLbl.text = "Score: \(score)"
        

        // game over Lbl
        let lostLbl = UILabel(frame: CGRect(x: 0.0, y: view.frame.height * 0.1, width: view.frame.width, height: view.frame.height * 0.1))
        lostLbl.textColor = .orange
        lostLbl.font = UIFont(name: "Arial", size: view.frame.width * 0.1)
        lostLbl.text = "Game Over!"
        lostLbl.textAlignment = .center
        
        view.addSubview(lostLbl)
    
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (gameStarted == false){
            
            pos += 0.1
            
            let newNode = addBox()
            
            tappedBox = newNode
            
            
            // Score Lbl
            scoreLbl = UILabel(frame: CGRect(x: 0.0, y: view.frame.height * 0.05, width: view.frame.width, height: view.frame.height * 0.1))
            scoreLbl.textColor = .magenta
            scoreLbl.font = UIFont(name: "Arial", size: view.frame.width * 0.1)
            scoreLbl.text = "0"
            scoreLbl.textAlignment = .center
            
            view.addSubview(scoreLbl)
            
            
            
            
            
            gameStarted = true
        }
        else{ //game has started
            
            
            if (gameLost == true){
                
                gameOver()
                
                return
            }
            

            
            
            
            
            
            
            let fixedBox = fixBoxPos(currentColor)
            
            tappedBox.removeFromParentNode()
            
            
            if (gameLost == true){
                
                gameOver()
                
                return
            }
            
            
            score += 1
            
            
            pos += 0.1
            
            lastBox = fixedBox
            
            tappedBox = addBox()
            


        }
        
        
    }
}
