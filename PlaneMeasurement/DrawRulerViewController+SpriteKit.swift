//
//  DrawRulerViewController+SpriteKit.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/16/24.
//

import SpriteKit

extension DrawRulersViewController: SKSceneDelegate {

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        skScene.removeAllChildren()
        if let node = quadNode.updateSKNode() {
            skScene.addChild(node)
        }
    }
}
