//
//  MeasureViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/15.
//

import UIKit
import ARKit

class MeasureViewController: UIViewController, ARSCNViewDelegate {

    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    var meterValue: Double?
    
    @IBOutlet weak var sceneView: ARSCNView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a seesion configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes {
                dot.removeFromParentNode()
            }
            dotNodes = [SCNNode]()
        }
        
        if let touchesLocation = touches.first?.location(in: sceneView) {
//            let hitTestResults = sceneView.hitTest(touchesLocation, types: .featurePoint)
//            if let hitResult = hitTestResults.first {
//                print("新增點")
//                addDot(at: hitResult)
//            } else {
//                print("什麼都沒做")
//            }
            let estimatedPlane: ARRaycastQuery.Target = .estimatedPlane
            let alignment: ARRaycastQuery.TargetAlignment = .any

            let query: ARRaycastQuery? = sceneView.raycastQuery(from: touchesLocation,
                                                                allowing: estimatedPlane,
                                                                alignment: alignment)
            if let nonOptQuery: ARRaycastQuery = query {

                let result: [ARRaycastResult] = sceneView.session.raycast(nonOptQuery)

                guard let rayCast: ARRaycastResult = result.first else { return }
                addDot(at: rayCast)

            }
        }
    }
    func addDot(at hitResult: ARRaycastResult) {
//      func addDot(at hitResult: ARHitTestResult) {
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x,
                                      hitResult.worldTransform.columns.3.y,
                                      hitResult.worldTransform.columns.3.z)
        sceneView.scene.rootNode.addChildNode(dotNode)
        dotNodes.append(dotNode)
        print(dotNodes.count)
        if dotNodes.count >= 2 {
            print("開始計算")
            calculate()
        }
    }
    
    func calculate() {
        let start = dotNodes[0]
        let end = dotNodes[1]
        
        print(start.position)
        print(end.position)
        
        let distance = sqrt(
            pow(end.position.x - start.position.x, 2) +
            pow(end.position.y - start.position.y, 2) +
            pow(end.position.z - start.position.z, 2)
        )
        
        meterValue = Double(abs(distance))
        
        let heightMeter = Measurement(value: meterValue ?? 0, unit: UnitLength.meters)
        // let heightInches = heightMeter.converted(to: UnitLength.inches) // convert to inches
        let heightCentimeter = heightMeter.converted(to: UnitLength.centimeters) // convert to centimeters
        
        let value = "\(heightCentimeter)"
        let finalMeasurement = String(value.prefix(6))
        updateText(text: finalMeasurement, atPosition: end.position)
        print("測量結果：\(finalMeasurement)")
    }
    func updateText(text: String, atPosition position: SCNVector3) {
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: "\(text)公分", extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(textNode)
        print("距離： \(text)")
    }
}
