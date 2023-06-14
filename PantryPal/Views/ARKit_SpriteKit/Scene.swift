//
//  Secen.swift
//  PantryPal
//
//  Created by 林哲豪 on 2023/6/14.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        // 檢查使用者是否觸碰到一個標籤節點
        if let touchLocation = touches.first?.location(in: self) {
            // 第一個標籤點點到 SKLabelNode 標情貼 
            if let node = nodes(at: touchLocation).first as? SKLabelNode {
                
                let fadeOut = SKAction.fadeOut(withDuration: 1.0)
                node.run(fadeOut) {
                    node.removeFromParent()
                }
                
                return
            }
        }
        
        // 使用相機目前的位置來建立錨點（anchor）
        if let currentFrame = sceneView.session.currentFrame {
            
            // 以相機前平移（translation） 0.2 公尺來建立⼀個變換（transform）
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.2
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            // 加入⼀個新的錨點點⾄ session
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }
}
