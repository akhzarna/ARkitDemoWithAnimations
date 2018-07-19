//
//  ViewController.swift
//  ARKitExample
//
//  Created by Evgeniy Antonov on 9/5/17.
//  Copyright © 2017 RubyGarage. All rights reserved.
//

import ARKit
import AVFoundation

var kAnimationDurationMoving: TimeInterval = 0.2
var kMovingLengthPerLoop: CGFloat = 0.05
var kRotationRadianPerLoop: CGFloat = 0.2
var toggleStateDroneOnOff = 2
var toggleStatelightOnOff = 2

class ViewController: UIViewController , ARSCNViewDelegate {
    @IBOutlet weak var imgSimple: UIImageView!
    @IBOutlet weak var viewTop: UIView!
    var player: AVPlayer?
    var isVideoFinish : Bool = false
    var flagThrottleUp:Int = 1
    @IBOutlet weak var dronOffView: UIView!
    var layer:  AVPlayerLayer?
    @IBOutlet weak var videoViewContainer: UIView!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var topHeaderView: UIView!
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
        setUpBasicConfiguration()
    }
    
    func setUpBasicConfiguration() {
        self.questionView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal,.vertical]
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    @IBAction func restartActionScan(_ sender: Any) {
        self.grids.removeAll()
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
        node.removeFromParentNode()
        }
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        self.questionView.isHidden = true
        configuration.planeDetection = [.horizontal,.vertical]
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        kAnimationDurationMoving = 0.2
        kRotationRadianPerLoop = 0.2
        toggleStateDroneOnOff = 2
        toggleStatelightOnOff = 2
        flagThrottleUp = 1
        planeAnchor = nil
        self.imgLightsOnOff.image = UIImage(named: "lightsoff")
        self.imgDroneOnOff.image = UIImage(named:"startdroneoff")
        let strImageName : String = "\(flagThrottleUp).png"
        self.imageRace.image = UIImage(named:strImageName)!
        self.drone.removeFromParentNode()
        self.viewBottomLeft.isHidden = true
        self.imageRace.isHidden = true
        self.dronOffView.isHidden = true
        self.viewBottomRight.isHidden = true
        self.viewBottomCenter.isHidden = true
        self.topHeaderView.isHidden = false
        self.questionView.isHidden = true
    }
    
    @IBAction func loadDroneAction(_ sender: Any) {
        if self.planeAnchor != nil {
        addDrone()
        }else{
            let alert = UIAlertController(title: "Attention", message: "Please detect the surface to load model", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("destructive")
                }}))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func addDrone() {
        sceneView.scene.rootNode.addChildNode(self.drone)
        self.drone.isPaused = true
        self.viewBottomLeft.isHidden = false
        self.viewBottomRight.isHidden = false
        self.viewBottomCenter.isHidden = false
        self.topHeaderView.isHidden = true
        self.questionView.isHidden = false
    }
    
    // MARK: - actions
    @IBAction func droneOnOffTapPressed(_ sender: UITapGestureRecognizer) {
        if toggleStateDroneOnOff == 1 {
            toggleStateDroneOnOff = 2
            self.drone.isPaused = true
        } else {
            toggleStateDroneOnOff = 1
            self.drone.isPaused = false
        }
    }
    
    @IBAction func lightsOnOffTapPressed(_ sender: UITapGestureRecognizer) {
        if toggleStatelightOnOff == 1 {
            toggleStatelightOnOff = 2
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
            drone.runAction(loopAction)
        } else if sender.state == .ended {
            drone.removeAllActions()
        }
    }

    @IBAction func upLongPressed(_ sender: UILongPressGestureRecognizer) {
        let action = SCNAction.moveBy(x: 0, y: kMovingLengthPerLoop, z: 0, duration: kAnimationDurationMoving)
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .began {
            drone.runAction(loopAction)
        } else if sender.state == .ended {
            drone.removeAllActions()
        }
    }
    
    @IBAction func downLongPressed(_ sender: UILongPressGestureRecognizer) {
        let action = SCNAction.moveBy(x: 0, y: -0.005, z: 0, duration:kAnimationDurationMoving)
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .changed {
            print(drone.position.y)
            print(planeAnchor?.transform.columns.3.y ?? 0)
            if drone.position.y>(planeAnchor?.transform.columns.3.y)!{
                drone.runAction(loopAction)
            }else{
                drone.removeAllActions()
            }
        } else if sender.state == .ended {
            drone.removeAllActions()
        }
    }
    
    @IBAction func moveLeftLongPressed(_ sender: UILongPressGestureRecognizer) {
        let x = -deltas().cos
        let z = deltas().sin
        let action = SCNAction.moveBy(x: x, y: 0, z: z, duration:kAnimationDurationMoving)
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .began {
            drone.runAction(loopAction)
        } else if sender.state == .ended {
            drone.removeAllActions()
        }
    }
    
    @IBAction func moveRightLongPressed(_ sender: UILongPressGestureRecognizer) {
        let x = deltas().cos
        let z = -deltas().sin
        let action = SCNAction.moveBy(x: x, y: 0, z: z, duration:kAnimationDurationMoving)
        let loopAction = SCNAction.repeatForever(action)
        if sender.state == .began {
            drone.runAction(loopAction)
        } else if sender.state == .ended {
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
            self.loadDroneScene(with: planeAnchor)
            let grid = Grid(anchor: anchor as! ARPlaneAnchor)
            self.grids.append(grid)
            node.addChildNode(grid)
        }
    }
    
    func loadDroneScene(with anchor: ARPlaneAnchor) {
        let dragonScene = SCNScene(named: "model.scnassets/ar-drone-2.dae")!
        let positionAnchor = anchor.transform
        for childNode in dragonScene.rootNode.childNodes {
            print(childNode)
            self.drone.addChildNode(childNode)
        }
        let scale:Float = 0.001
        self.drone.scale = SCNVector3(x: scale, y: scale, z: scale)
        self.drone.position = SCNVector3(x: positionAnchor.columns.3.x, y: positionAnchor.columns.3.y, z: positionAnchor.columns.3.z)
    }
    
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
}
