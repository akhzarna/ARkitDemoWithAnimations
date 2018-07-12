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
var toggleStateDroneOnOff = 1
var toggleStatelightOnOff = 1

var xPos:CGFloat = 0.0
var yPos:CGFloat = 0.0
var zPos:CGFloat = 0.0

class ViewController: UIViewController {
    
    @IBOutlet weak var viewTop: UIView!
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
//        setupScene()
        addTapGestureToSceneView()
        configureLighting()
        self.questionView.isHidden = true
        btn1.layer.cornerRadius = btn1.frame.width / 2
        btn1.clipsToBounds = true
        btn2.layer.cornerRadius = btn1.frame.width / 2
        btn2.clipsToBounds = true
        btn3.layer.cornerRadius = btn1.frame.width / 2
        btn3.clipsToBounds = true
//        self.view.addSubview(self.videoViewContainer)
//        initializeVideoPlayerWithVideo()
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
//        setupConfiguration()
        setUpSceneView()
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = false
        sceneView.automaticallyUpdatesLighting = false
    }
    
//    func addDrone() {
//        drone.loadModel()
//        drone.position = kStartingPosition
//        drone.scale = SCNVector3(0.002, 0.002, 0.002)
//        drone.rotation = SCNVector4Zero
//        sceneView.scene.rootNode.addChildNode(drone)
//        self.viewBottomLeft.isHidden = false
//        self.viewBottomRight.isHidden = false
//        self.viewBottomCenter.isHidden = false
//        self.topHeaderView.isHidden = true
//        self.questionView.isHidden = false 
//    }
    
    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
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
        shipNode.scale = SCNVector3(0.08, 0.08, 0.08)
        shipNode.rotation = SCNVector4Zero
        sceneView.scene.rootNode.addChildNode(shipNode)
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.addShipToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
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
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    @IBAction func loadDroneAction(_ sender: Any) {
        addDrone()
    }
    
    func addDrone() {
       
//        if xPos == 0.0 && yPos == 0.0 && zPos == 0.0 {
//            let alert = UIAlertController(title: "Attention", message: "No Plan Detected to place the object", preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//                switch action.style{
//                case .default:
//                    print("default")
//                case .cancel:
//                    print("cancel")
//                case .destructive:
//                    print("destructive")
//                }}))
//            self.present(alert, animated: true, completion: nil)
//
//        }else{
            
            drone.loadModel()
            drone.position = SCNVector3(0.0, 0.0, -0.2)
            drone.scale = SCNVector3(0.0007, 0.0007, 0.0007)
            drone.rotation = SCNVector4Zero
            sceneView.scene.rootNode.addChildNode(drone)
            
//            guard let shipScene = SCNScene(named: "ship.scn"),
//                let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: false)
//                else { return }
//            shipNode.position = SCNVector3(xPos,yPos,zPos)
//            shipNode.scale = SCNVector3(0.0008, 0.0008, 0.0008)
//            shipNode.rotation = SCNVector4Zero
//            sceneView.scene.rootNode.addChildNode(shipNode)
            
            self.viewBottomLeft.isHidden = false
            self.viewBottomRight.isHidden = false
            self.viewBottomCenter.isHidden = false
//            self.topHeaderView.isHidden = true
//            self.questionView.isHidden = false
       
//        }
    }
    
    // MARK: - actions

    // Added By Akhzar Nazir
    
    @IBAction func droneOnOffTapPressed(_ sender: UITapGestureRecognizer) {
        if toggleStateDroneOnOff == 1 {
            toggleStateDroneOnOff = 2
            self.imgDroneOnOff.image = UIImage(named: "startdroneoff")
        } else {
            toggleStateDroneOnOff = 1
            self.imgDroneOnOff.image = UIImage(named: "startdroneon")
        }
    }
    
    @IBAction func lightsOnOffTapPressed(_ sender: UITapGestureRecognizer) {
        if toggleStatelightOnOff == 1 {
            toggleStatelightOnOff = 2
            self.imgLightsOnOff.image = UIImage(named: "lightsoff")
        } else {
            toggleStatelightOnOff = 1
            self.imgLightsOnOff.image = UIImage(named: "lightson")
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
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        let grid = Grid(anchor: anchor as! ARPlaneAnchor)
//        self.grids.append(grid)
//        node.addChildNode(grid)
//    }
//    // 2.
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        let grid = self.grids.filter { grid in
//            return grid.anchor.identifier == anchor.identifier
//            }.first
//
//        guard let foundGrid = grid else {
//            return
//        }
//
//        foundGrid.update(anchor: anchor as! ARPlaneAnchor)
//    }
    
    
    
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

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // 3
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        // 4
        let planeNode = SCNNode(geometry: plane)
        
        // 5
        xPos = CGFloat(planeAnchor.center.x)
        yPos = CGFloat(planeAnchor.center.y)
        zPos = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(xPos,yPos,zPos)
        planeNode.eulerAngles.x = -.pi / 2
        
        // 6
        node.addChildNode(planeNode)
        
        // Added by Akhzar Nazir
        drone.loadModel()
        drone.position = planeNode.position
        drone.scale = SCNVector3(0.0002, 0.0002, 0.0002)
        drone.rotation = SCNVector4Zero
        sceneView.scene.rootNode.addChildNode(drone)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
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
