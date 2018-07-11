//
//  ViewController.swift
//  ARKitExample
//
//  Created by Evgeniy Antonov on 9/5/17.
//  Copyright © 2017 RubyGarage. All rights reserved.
//

import ARKit
import AVFoundation


let kStartingPosition = SCNVector3(0, 0, -0.6)
let kAnimationDurationMoving: TimeInterval = 0.2
let kMovingLengthPerLoop: CGFloat = 0.05
let kRotationRadianPerLoop: CGFloat = 0.2
var toggleStateDroneOnOff = 1
var toggleStatelightOnOff = 1

class ViewController: UIViewController {
    
    var player: AVPlayer?
    var isVideoFinish : Bool = false
    
    
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
    @IBOutlet weak var sceneView: ARSCNView!
    
    var drone = Drone()
    var grids = [Grid]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.questionView.isHidden = true
        
        btn1.layer.cornerRadius = btn1.frame.width / 2
        btn1.clipsToBounds = true
        btn2.layer.cornerRadius = btn1.frame.width / 2
        btn2.clipsToBounds = true
        
        btn3.layer.cornerRadius = btn1.frame.width / 2
        btn3.clipsToBounds = true
        self.view.addSubview(self.videoViewContainer)
        initializeVideoPlayerWithVideo()
        setupScene()
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
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if (UIDevice.current.orientation.isLandscape) {
            
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
            print("Device is portrait")
           // movie.view.frame = videoContainerView.bounds
           // controllsContainerView.frame = videoContainerView.bounds
            self.layer?.removeFromSuperlayer()
        }
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConfiguration()
    }
    
    func addDrone() {
        drone.loadModel()
        drone.position = kStartingPosition
        drone.scale = SCNVector3(0.002, 0.002, 0.002)
        drone.rotation = SCNVector4Zero
        sceneView.scene.rootNode.addChildNode(drone)
        self.viewBottomLeft.isHidden = false
        self.viewBottomRight.isHidden = false
        self.viewBottomCenter.isHidden = false
        self.topHeaderView.isHidden = true
        self.questionView.isHidden = false 
        
    }
    
    // MARK: - setup
    func setupScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func setupConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        configuration.planeDetection = .horizontal
    }
    
    // MARK: - actions

    // Added By Akhzar Nazir
    
    @IBAction func droneLoadAction(_ sender: Any) {
        addDrone()
        
    }
    
    @IBAction func droneOnOffTapPressed(_ sender: UITapGestureRecognizer) {
        if toggleStateDroneOnOff == 1 {
            toggleStateDroneOnOff = 2
            self.imgDroneOnOff.image = UIImage(named: "startdroneon")
        } else {
            toggleStateDroneOnOff = 1
            self.imgDroneOnOff.image = UIImage(named: "startdroneoff")
        }
    }
    
    @IBAction func lightsOnOffTapPressed(_ sender: UITapGestureRecognizer) {
        if toggleStatelightOnOff == 1 {
            toggleStatelightOnOff = 2
            self.imgLightsOnOff.image = UIImage(named: "lightson")
        } else {
            toggleStatelightOnOff = 1
            self.imgLightsOnOff.image = UIImage(named: "lightsoff")
        }
    }
    
    // End
    
    @IBAction func upLongPressed(_ sender: UILongPressGestureRecognizer) {
        let action = SCNAction.moveBy(x: 0, y: kMovingLengthPerLoop, z: 0, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    @IBAction func downLongPressed(_ sender: UILongPressGestureRecognizer) {
        let action = SCNAction.moveBy(x: 0, y: -kMovingLengthPerLoop, z: 0, duration: kAnimationDurationMoving)
        execute(action: action, sender: sender)
    }
    
    @IBAction func moveLeftLongPressed(_ sender: UILongPressGestureRecognizer) {
        let x = -deltas().cos
        let z = deltas().sin
        moveDrone(x: x, z: z, sender: sender)
    }
    
    @IBAction func moveRightLongPressed(_ sender: UILongPressGestureRecognizer) {
        let x = deltas().cos
        let z = -deltas().sin
        moveDrone(x: x, z: z, sender: sender)
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
    
    private func execute(action: SCNAction, sender: UILongPressGestureRecognizer) {
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .began {
            drone.runAction(loopAction)
        } else if sender.state == .ended {
            drone.removeAllActions()
        }
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
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
    // 1.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        let grid = Grid(anchor: anchor as! ARPlaneAnchor)
        self.grids.append(grid)
        node.addChildNode(grid)
    }
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
