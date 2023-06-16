//
//  ARSCNView.swift
//
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/15.
//

import SceneKit
import ARKit

extension ARSCNView {
    func realWorldVector(screenPosition: CGPoint) -> SCNVector3? {
        let results = self.hitTest(screenPosition, types: [.featurePoint])
        guard let result = results.first else { return nil }
        return SCNVector3.positionFromTransform(result.worldTransform)
    }
}
