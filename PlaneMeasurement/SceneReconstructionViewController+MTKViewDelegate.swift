//
//  SceneReconstructionViewController+MTKViewDelegate.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/24/24.
//

import MetalKit

extension SceneReconstructionViewController: MTKViewDelegate {
    // Called whenever view changes orientation or layout is changed
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderer.drawRectResized(size: size)
    }

    // Called whenever the view needs to render
    func draw(in view: MTKView) {
        renderer.draw()
    }
}
