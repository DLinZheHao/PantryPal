//
//  RealityKitViewController.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/15.
//

import UIKit
import RealityKit
import ARKit

class RealityKitViewController: UIViewController {

    @IBOutlet weak var arView: ARView!
    var anchorBeer: MyBeer.Beer!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        arView.session.delegate = self
        setUpCustomObjectView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        arView.addGestureRecognizer(tapGesture)
    }
    func setUpCustomObjectView() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        anchorBeer = try? MyBeer.loadBeer()
//        anchorBeer.generateCollisionShapes(recursive: true)
//        arView.scene.anchors.append(anchorBeer)
        
    }
    @IBAction func onTap(_ recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "beer.usdz", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
            alert("物件放置成功", self)
        } else {
            alert("物件放置失敗", self)
        }
    }
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        guard let entity = try? ModelEntity.loadModel(named: entityName) else { return }
        entity.generateCollisionShapes(recursive: true)
        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}

extension RealityKitViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            print("成功獲取毛點")
            if let anchorObject = anchor.name, anchorObject == "beer.usdz" {
                placeObject(named: anchorObject, for: anchor)
            }
        }
    }
}
