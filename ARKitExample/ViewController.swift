//
//  ViewController.swift
//  ARKitExample
//
//  Created by Evgeniy Antonov on 9/5/17.
//  Copyright © 2017 RubyGarage. All rights reserved.
//

import ARKit
import AVFoundation

let kStartingPosition = SCNVector3(0.0, 0.0, -0.6)
let kAnimationDurationMoving: TimeInterval = 0.2
let kMovingLengthPerLoop: CGFloat = 0.05
let kRotationRadianPerLoop: CGFloat = 0.2
var toggleStateDroneOnOff = 2
var toggleStatelightOnOff = 2

class ViewController: UIViewController , ARSCNViewDelegate {
    
    @IBOutlet weak var imgSimple: UIImageView!
    @IBOutlet weak var viewTop: UIView!
    var player: AVPlayer?
    var isVideoFinish : Bool = false
    var flagThrottleUp:Int = 1
    var doubleflagThrottleUp:Double = 0.0

    @IBOutlet weak var dronOffView: UIView!

    var layer:  AVPlayerLayer?
    @IBOutlet weak var videoViewContainer: UIView!
    @IBOutlet weak var questionView: UIView!
    
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var viewBottomLeft: UIView!
    @IBOutlet weak var viewBottomRight: UIView!
    @IBOutlet weak var viewBottomCenter: UIView!
    
    @IBOutlet weak var imgLightsOnOff: UIImageView!
    @IBOutlet weak var imgDroneOnOff: UIImageView!
    
    @IBOutlet weak var imgLeftPressed: UIImageView!
    @IBOutlet weak var lightXposition: NSLayoutConstraint!
    @IBOutlet weak var raceXPosition: NSLayoutConstraint!
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var imageRace: UIImageView!
    var grids = [Grid]()
    let drone = SCNNode()

    @IBOutlet weak var droneOffXPosition: NSLayoutConstraint!
    @IBOutlet weak var dronYPosition: NSLayoutConstraint!
    
    var planeAnchor: ARPlaneAnchor?
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupScene()
        configureLighting()
        self.questionView.isHidden = true
        btn1.layer.cornerRadius = btn1.frame.width / 2
        btn1.clipsToBounds = true
        btn2.layer.cornerRadius = btn1.frame.width / 2
        btn2.clipsToBounds = true
        btn3.layer.cornerRadius = btn1.frame.width / 2
        btn3.clipsToBounds = true
        self.view.addSubview(self.videoViewContainer)
        initializeVideoPlayerWithVideo()
        
    }
    
    func initializeVideoPlayerWithVideo() {
        // get the path string for the video from assets
        let videoString:String? = Bundle.main.path(forResource: "animation", ofType: "mp4")
        guard let unwrappedVideoPath = videoString else {return}
        // convert the path string to a url
        let videoUrl = URL(fileURLWithPath: unwrappedVideoPath)
        // initialize the video player with the url
        self.player = AVPlayer(url: videoUrl)
        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        // create a video layer for the player
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        // make the layer the same size as the container view
        layer.frame = videoViewContainer.bounds
        // make the video fill the layer as much as possible while keeping its aspect size
        layer.videoGravity = AVLayerVideoGravity.resizeAspect
        // add the layer to the container view
        videoViewContainer.layer.addSublayer(layer)
        player?.play()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        print("Video Finished")
        self.isVideoFinish = true
        self.videoViewContainer.isHidden = true
    }
    
    @IBAction func restartActionScan(_ sender: Any) {
//        self.grids.removeAll()
//        let configuration = ARWorldTrackingConfiguration()
//
//        sceneView.session.pause()
//        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
//            node.removeFromParentNode()
//        }
//        
//        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//
//        setUpSceneView()
}
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if (UIDevice.current.orientation.isLandscape) {
            self.droneOffXPosition.constant = 60
            self.dronYPosition.constant = 50
            self.raceXPosition.constant = 120
            self.lightXposition.constant = 5
            if isVideoFinish == false {
                DispatchQueue.main.async {
                    self.view.didAddSubview(self.videoViewContainer)
                    self.layer = AVPlayerLayer(player: self.player!)
                    self.layer?.frame = self.view.frame
                    self.layer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    self.videoViewContainer.layer.addSublayer(self.layer!)
                }
            }
            print("Device is landscape")
        }else{
            self.droneOffXPosition.constant = 90
            self.raceXPosition.constant = 10
            self.lightXposition.constant = 5
            self.dronYPosition.constant = 10
            
            print("Device is portrait")
           // movie.view.frame = videoContainerView.bounds
           // controllsContainerView.frame = videoContainerView.bounds
            self.layer?.removeFromSuperlayer()
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        setupConfiguration()
        
//        let imgListArray :NSMutableArray = []
//        for countValue in 1...10
//        {
//
//            let strImageName : String = "\(countValue).png"
//            let image  = UIImage(named:strImageName)
//            imgListArray .add(image!)
//        }
//
//        self.imageRace.animationImages = imgListArray as? [UIImage]
//        self.imageRace.animationDuration = 3.0
//        self.imageRace.startAnimating()
        
        //self.imageRace.stopAnimating()
        
        
        setUpSceneView()
    }
    
    func configureLighting() {
//        sceneView.autoenablesDefaultLighting = true
//        sceneView.automaticallyUpdatesLighting = true
    }

    // MARK: - setup
    //    func setupScene() {
    //        let scene = SCNScene()
    //        sceneView.scene = scene
    //        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    //    }
    //
    //    func setupConfiguration() {
    //                let configuration = ARWorldTrackingConfiguration()
    //                sceneView.session.run(configuration)
    //                configuration.planeDetection = .horizontal
    //    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal,.vertical]
//        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    @IBAction func loadDroneAction(_ sender: Any) {
        if self.planeAnchor != nil {
        addDrone()
        }
    }
    
    func addDrone() {
        sceneView.scene.rootNode.addChildNode(self.drone)
        self.drone.isPaused = true
        self.viewBottomLeft.isHidden = false
        self.imageRace.isHidden = false
        self.dronOffView.isHidden = false
        self.viewBottomRight.isHidden = false
        self.viewBottomCenter.isHidden = false
        self.topHeaderView.isHidden = true
        self.questionView.isHidden = false
        
//        for result in sceneView.hitTest(CGPoint(x: 0.5, y: 0.5), types: [.existingPlaneUsingExtent, .featurePoint]) {
//            print(result.distance, result.worldTransform)
//        }
        
    }
    
    // MARK: - actions

    // Added By Akhzar Nazir
    
    @IBAction func droneOnOffTapPressed(_ sender: UITapGestureRecognizer) {
        if toggleStateDroneOnOff == 1 {
            toggleStateDroneOnOff = 2
            self.imgDroneOnOff.image = UIImage(named:"startdroneoff")
            self.drone.isPaused = true
        } else {
            toggleStateDroneOnOff = 1
            self.imgDroneOnOff.image = UIImage(named:"startdroneon")
            self.drone.isPaused = false
        }
    }
    
    @IBAction func lightsOnOffTapPressed(_ sender: UITapGestureRecognizer) {
        if toggleStatelightOnOff == 1 {
            toggleStatelightOnOff = 2
            self.imgLightsOnOff.image = UIImage(named: "lightsoff")
            //            sceneView.autoenablesDefaultLighting = false
            //            sceneView.automaticallyUpdatesLighting = false
            for childNodes in self.drone.childNodes{
                // For Head Lights
                if childNodes.name == "Omni003"{
                    childNodes.light?.intensity = 0.0
                }
                if childNodes.name == "Omni002"{
                    childNodes.light?.intensity = 0.0
                }
            }
        } else {
            toggleStatelightOnOff = 1
            self.imgLightsOnOff.image = UIImage(named: "lightson")
            for childNodes in self.drone.childNodes{
                // For Head Lights
                if childNodes.name == "Omni003"{
                    childNodes.light?.intensity = 1000.0
                }
                if childNodes.name == "Omni002"{
                    childNodes.light?.intensity = 1000.0
                }
            }
        }
    }
    
    
    
    // End
    
    private func execute(action: SCNAction, sender: UILongPressGestureRecognizer) {
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .began {
       //     self.imgLeftPressed.backgroundColor = UIColor.lightGray
            //self.imgLeftPressed. = UIColor.lightGray
            drone.runAction(loopAction)
        } else if sender.state == .ended {
//            self.imgLeftPressed.backgroundColor = UIColor.white

            drone.removeAllActions()
        }
    }
    
    @IBAction func throttleUpLongPressed(_ sender: Any) {
        var image:UIImage? = nil
        if self.flagThrottleUp<=9{
            flagThrottleUp+=1
            let strImageName : String = "\(flagThrottleUp).png"
            image = UIImage(named:strImageName)!
            self.imageRace.image = image
        }else{
        let strImageName : String = "\(10).png"
        image = UIImage(named:strImageName)!
        self.imageRace.image = image
        }
    }
    
    @IBAction func throttleDownLongPressed(_ sender: Any) {
        var image:UIImage? = nil
        if self.flagThrottleUp>=2{
            flagThrottleUp-=1
            let strImageName : String = "\(flagThrottleUp).png"
            image = UIImage(named:strImageName)!
            self.imageRace.image = image
        }else{
            let strImageName : String = "\(1).png"
            image = UIImage(named:strImageName)!
            self.imageRace.image = image
        }
        
    }

    @IBAction func upLongPressed(_ sender: UILongPressGestureRecognizer) {
        doubleflagThrottleUp = Double(flagThrottleUp/2)
        if doubleflagThrottleUp == 0{
            doubleflagThrottleUp = 0.5
        }
        let action = SCNAction.moveBy(x: 0, y: kMovingLengthPerLoop, z: 0, duration: kAnimationDurationMoving/doubleflagThrottleUp)
//        execute(action: action, sender: sender)
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .began {
            self.imgSimple.image = UIImage(named: "top")
            drone.runAction(loopAction)
        } else if sender.state == .ended {
            self.imgSimple.image = UIImage(named: "simple")
            drone.removeAllActions()
        }
        
    }
    
    @IBAction func downLongPressed(_ sender: UILongPressGestureRecognizer) {
        doubleflagThrottleUp = Double(flagThrottleUp/2)
        if doubleflagThrottleUp == 0{
            doubleflagThrottleUp = 0.5
        }
        let action = SCNAction.moveBy(x: 0, y: -0.005, z: 0, duration:kAnimationDurationMoving/doubleflagThrottleUp)
//        execute(action: action, sender: sender)
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .changed {
            print(drone.position.y)
            print(planeAnchor?.transform.columns.3.y ?? 0)
            if drone.position.y>(planeAnchor?.transform.columns.3.y)!{
                self.imgSimple.image = UIImage(named: "bottom")
                drone.runAction(loopAction)
            }else{
                self.imgSimple.image = UIImage(named: "simple")
                drone.removeAllActions()
            }
        } else if sender.state == .ended {
            self.imgSimple.image = UIImage(named: "simple")
            drone.removeAllActions()
        }
    }
    
    @IBAction func moveLeftLongPressed(_ sender: UILongPressGestureRecognizer) {
        
        let x = -deltas().cos
        let z = deltas().sin
//        moveDrone(x: x, z: z, sender: sender)
        doubleflagThrottleUp = Double(flagThrottleUp/2)
        if doubleflagThrottleUp == 0{
            doubleflagThrottleUp = 0.5
        }
//        moveDrone(x: x, z: z, sender: sender)
        let action = SCNAction.moveBy(x: x, y: 0, z: z, duration:kAnimationDurationMoving/doubleflagThrottleUp)
//        execute(action: action, sender: sender)
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .began {
            self.imgSimple.image = UIImage(named: "left")
            drone.runAction(loopAction)
        } else if sender.state == .ended {
            self.imgSimple.image = UIImage(named: "simple")
            drone.removeAllActions()
        }
    }
    
    @IBAction func moveRightLongPressed(_ sender: UILongPressGestureRecognizer) {
        let x = deltas().cos
        let z = -deltas().sin
        doubleflagThrottleUp = Double(flagThrottleUp/2)
        if doubleflagThrottleUp == 0{
            doubleflagThrottleUp = 0.5
        }
//        moveDrone(x: x, z: z, sender: sender)
        let action = SCNAction.moveBy(x: x, y: 0, z: z, duration:kAnimationDurationMoving/doubleflagThrottleUp)
//        execute(action: action, sender: sender)
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .began {
            self.imgSimple.image = UIImage(named: "right")
            drone.runAction(loopAction)
        } else if sender.state == .ended {
            self.imgSimple.image = UIImage(named: "simple")
            drone.removeAllActions()
        }
    }
    
    @IBAction func moveForwardLongPressed(_ sender: UILongPressGestureRecognizer) {
        let x = -deltas().sin
        let z = -deltas().cos
        moveDrone(x: x, z: z, sender: sender)
    }
    
    @IBAction func moveBackLongPressed(_ sender: UILongPressGestureRecognizer) {
        let x = deltas().sin
        let z = deltas().cos
        moveDrone(x: x, z: z, sender: sender)
    }
    
    @IBAction func rotateLeftLongPressed(_ sender: UILongPressGestureRecognizer) {
        rotateDrone(yRadian: kRotationRadianPerLoop, sender: sender)
    }
    
    @IBAction func rotateRightLongPressed(_ sender: UILongPressGestureRecognizer) {
        rotateDrone(yRadian: -kRotationRadianPerLoop, sender: sender)
    }
    
    // MARK: - private
    private func rotateDrone(yRadian: CGFloat, sender: UILongPressGestureRecognizer) {
        let action = SCNAction.rotateBy(x: 0, y: yRadian, z: 0, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    private func moveDrone(x: CGFloat, z: CGFloat, sender: UILongPressGestureRecognizer) {
        let action = SCNAction.moveBy(x: x, y: 0, z: z, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    private func moveDroneUpDown(y: CGFloat, z: CGFloat, sender: UILongPressGestureRecognizer) {
        let action = SCNAction.moveBy(x: 0, y: y, z: z, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    private func deltas() -> (sin: CGFloat, cos: CGFloat) {
        return (sin: kMovingLengthPerLoop * CGFloat(sin(drone.eulerAngles.y)), cos: kMovingLengthPerLoop * CGFloat(cos(drone.eulerAngles.y)))
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        if self.planeAnchor == nil {
            self.planeAnchor = planeAnchor
            // Clear out the debugging options once a plane has been detected
            self.sceneView.debugOptions = []
            self.loadDragonScene(with: planeAnchor)
            let grid = Grid(anchor: anchor as! ARPlaneAnchor)
            self.grids.append(grid)
            node.addChildNode(grid)
        }
        
    }
    
    func loadDragonScene(with anchor: ARPlaneAnchor) {
        let dragonScene = SCNScene(named: "001_Drone.dae")!
        let positionAnchor = anchor.transform
        for childNode in dragonScene.rootNode.childNodes {
            print(childNode)
            self.drone.addChildNode(childNode)
        }
        
//        if self.drone.name == "Omni001"{
//            self.drone.light?.intensity = 1000.0
//        }
//
//        if self.drone.name == "Omni002"{
//            self.drone.light?.intensity = 1000.0
//        }
//
//        if self.drone.name == "Omni003"{
//            self.drone.light?.intensity = 1000.0
//        }
//
//        if self.drone.name == "Omni004"{
//            self.drone.light?.intensity = 1000.0
//        }
        
        let scale:Float = 0.002
        self.drone.scale = SCNVector3(x: scale, y: scale, z: scale)
        self.drone.position = SCNVector3(x: positionAnchor.columns.3.x, y: positionAnchor.columns.3.y+0.05, z: positionAnchor.columns.3.z)
       
//        xPos = CGFloat(position.columns.3.x)
//        yPos = CGFloat(position.columns.3.y)
//        zPos = CGFloat(position.columns.3.z)
//        sceneView.scene.rootNode.addChildNode(self.drone)

    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */

//    func session(_ session: ARSession, didFailWithError error: Error) {
//        // Present an error message to the user
//    }
//    
//    func sessionWasInterrupted(_ session: ARSession) {
//        // Inform the user that the session has been interrupted, for example, by presenting an overlay
//    }
//    
//    func sessionInterruptionEnded(_ session: ARSession) {
//        // Reset tracking and/or remove existing anchors if consistent tracking is required
//    }
//    
//    // 1.
 
    

// 2.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let grid = self.grids.filter { grid in
            return grid.anchor.identifier == anchor.identifier
            }.first
        guard let foundGrid = grid else {
            return
        }
        foundGrid.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        DispatchQueue.main.async {
            self.grids.removeAll()
        }
    }
    
    
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        // Your code goes here
//        print("YES Detected")
//
//        if let anchor = anchor as? ARPlaneAnchor {
//            // Your code goes here
//        }
//
//        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
//        plane.materials.first?.diffuse.contents = UIColor.red.withAlphaComponent(0.5)
//
//
//        let planeNode = SCNNode(geometry: plane)
//
//        planeNode.position = SCNVector3(CGFloat(anchor.center.x), CGFloat(anchor.center.y), CGFloat(anchor.center.z))
//        planeNode.eulerAngles.x = -.pi / 2
//
//        node.addChildNode(planeNode)
    
}
