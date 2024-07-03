//
//  DrawRulersViewController+HitTesting.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/13/24.
//

import SceneKit

extension DrawRulersViewController {

    func hitTest(at point: CGPoint) -> SCNHitTestResult? {
        let hitResults = sceneView.hitTest(point)
        return hitResults.first
    }

    
}
