//
//  ViewController.swift
//  StackerAR
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
    let audioSource = SCNAudioSource(named: "tick.mp3")!
    var lostLbl: UILabel!
    var highScoreLbl: UILabel!
    var restartBtn: UIButton!
    let defaults: UserDefaults = UserDefaults.standard
    var highScore = 0
    
    
    
    
    
    
    
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
        
        

        addLightingEffects()
        
        
        
        
        //try to load high score
        highScore = (defaults.value(forKey: "highScore") as? Int) ?? 0
        
        //if there isnt one, set key
        if (highScore == 0){
            //set high score data persistance
            defaults.set(highScore, forKey: "highScore")
            defaults.synchronize() //Call when you're done editing all defaults for the method.
        }

        
        //place foundation block
        var node = SCNNode()
        
        node = createNode(position: SCNVector3(0, -0.8, -0.5), color: UIColor.blue, width: 0.2)
        self.sceneView.scene.rootNode.addChildNode(node)
        
        lastBox = node
    }
    
    func addLightingEffects(){
        
        // Lighting (Ambient)
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white
        ambientLight.intensity = 300.0
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        ambientLightNode.position.y = 2.0
        
        self.sceneView.scene.rootNode.addChildNode(ambientLightNode)
        
        // Lighting (Omnidirectional)
        let omniLight = SCNLight()
        omniLight.type = .omni
        omniLight.color = UIColor.white
        omniLight.intensity = 1000.0
        
        let omniLightNode = SCNNode()
        omniLightNode.light = omniLight
        omniLightNode.position.y = 3.0
        
        self.sceneView.scene.rootNode.addChildNode(omniLightNode)
        
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
        
        let moveLeft = SCNAction.moveBy(x: -2, y: 0, z: 0, duration: speed)
        let moveRight = SCNAction.moveBy(x: 2, y: 0, z: 0, duration: speed)
        
        
        let moveSequence = SCNAction.sequence([moveRight, moveLeft])
        let moveLoop = SCNAction.repeatForever(moveSequence)
        
        node.runAction(moveLoop)
        
        speed -= 0.2
        
    }
    
    
    func addBox() -> SCNNode{
        
        //initilize node
        var newNode = SCNNode()
        currentColor = getRandomColor()
        
        newNode = createNode(position: SCNVector3(-1, pos, -0.5), color: currentColor, width: currentBoxWidth)
        
        //add node to stack
        self.sceneView.scene.rootNode.addChildNode(newNode)
        
        
        moveBox(newNode)
        
        
        /*
         Timer.scheduledTimer(timeInterval: speed, target: self, selector: #selector(addBox), userInfo: nil, repeats: false)
         
         DispatchQueue.main.asyncAfter(deadline: .now() + speed) { // change 2 to desired number of seconds
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
    
    
    func createNode(position: SCNVector3, color: UIColor, width: Float) -> SCNNode{
        
        let node = SCNNode()
        
        node.geometry = SCNBox(width: CGFloat(width), height: 0.1, length: 0.2, chamferRadius: 0)
        node.geometry?.firstMaterial?.diffuse.contents = color
        node.position = position
        
        return node
        
        
        
    }
    
    
    
    
    func fixBoxPos(_ color: UIColor) -> SCNNode?{
        
        //AudioServicesPlaySystemSound (systemSoundID)
        
        
        
        var node = SCNNode()
        
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
            
            node = createNode(position: tappedBoxPos, color: color, width: currentBoxWidth)
            self.sceneView.scene.rootNode.addChildNode(node)
        }
        else if (difference > 0){//too far right, shrink left bound
            
            currentBoxWidth = rightBound - tappedBoxLeftEdge
            
            let newPosition = tappedBoxLeftEdge + (currentBoxWidth / 2)
            
            node = createNode(position: SCNVector3(Double(newPosition), pos, -0.5), color: color, width: currentBoxWidth)
            self.sceneView.scene.rootNode.addChildNode(node)
            
            
            leftBound = tappedBoxLeftEdge
            
            
            boxFall("right")
            
        }
        else if(difference < 0){
            
            
            currentBoxWidth = tappedBoxRightEdge - leftBound
            
            let newPosition = leftBound + (currentBoxWidth / 2)
            
            node = createNode(position: SCNVector3(Double(newPosition), pos, -0.5), color: color, width: currentBoxWidth)
            self.sceneView.scene.rootNode.addChildNode(node)
            
            rightBound = tappedBoxRightEdge
            
            boxFall("left")
        }
        return node
        
    }
    
    
    
    
    
    func gameOver(){
        
        gameStarted = false
        
        
        if (score > highScore){
            
            
            //set high score data persistance
            defaults.set(score, forKey: "highScore")
            defaults.synchronize() //Call when you're done editing all defaults for the method.
        }
        
        scoreLbl.textColor = .orange
        scoreLbl.text = "Score: \(score)"
        
        
        // game over Lbl
        lostLbl = UILabel(frame: CGRect(x: 0.0, y: view.frame.height * 0.1, width: view.frame.width, height: view.frame.height * 0.1))
        lostLbl.textColor = .orange
        lostLbl.font = UIFont(name: "Arial", size: view.frame.width * 0.1)
        lostLbl.text = "Game Over!"
        lostLbl.textAlignment = .center
        lostLbl.isHidden = false
        view.addSubview(lostLbl)
        
        
        //load high score data persistance
        highScore = (defaults.value(forKey: "highScore") as? Int)!
        
        // high score Lbl
        highScoreLbl = UILabel(frame: CGRect(x: 0.0, y: view.frame.height * 0.8, width: view.frame.width, height: view.frame.height * 0.1))
        highScoreLbl.textColor = .magenta
        highScoreLbl.font = UIFont(name: "Arial", size: view.frame.width * 0.1)
        highScoreLbl.text = "High Score: \(highScore)"
        highScoreLbl.textAlignment = .center
        highScoreLbl.isHidden = false
        view.addSubview(highScoreLbl)
        
        
        
        
        restartBtn = UIButton(frame: CGRect(x: view.frame.width * 0.25, y: view.frame.height * 0.7, width: view.frame.width * 0.5, height: view.frame.height * 0.1))
        restartBtn.backgroundColor = .red
        restartBtn.setTitle("Try Again", for: .normal)
        restartBtn.addTarget(self, action: #selector(restartButtonAction), for: .touchUpInside)
        restartBtn.isHidden = false
        
        self.view.addSubview(restartBtn)
        
        
    }
    
    @objc func restartButtonAction(sender: UIButton!) {
        
        print("\nGAME RESTARTED\n")
        
        // remove all nodes
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, stop) -> Void in          node.removeFromParentNode()
        }
        
        // place a new foundation
        var node = SCNNode()
        node = createNode(position: SCNVector3(0, -0.8, -0.5), color: UIColor.blue, width: 0.2)
        self.sceneView.scene.rootNode.addChildNode(node)
        
        lastBox = node
        
        
        gameStarted = false
        gameLost = false
        score = 0
        pos = -0.8
        leftBound = -0.1
        rightBound = 0.1
        currentBoxWidth = 0.2
        speed = 6
        lostLbl.isHidden = true
        scoreLbl.textColor = .magenta
        
        restartBtn.isHidden = true
        scoreLbl.isHidden = true
        highScoreLbl.isHidden = true
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (gameStarted == false){
            
            if (gameLost == true){
                return
            }
            
            pos += 0.1
            
            let newNode = addBox()
            
            tappedBox = newNode
            
            
            // Score Lbl
            scoreLbl = UILabel(frame: CGRect(x: 0.0, y: view.frame.height * 0.05, width: view.frame.width, height: view.frame.height * 0.1))
            scoreLbl.textColor = .magenta
            scoreLbl.font = UIFont(name: "Arial", size: view.frame.width * 0.1)
            scoreLbl.text = "0"
            scoreLbl.textAlignment = .center
            scoreLbl.isHidden = false
            
            
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
