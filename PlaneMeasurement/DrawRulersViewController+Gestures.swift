//
//  DrawRulersViewController+Gestures.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/16/24.
//

import UIKit
import SceneKit

extension DrawRulersViewController {
    // MARK: - Pan Gestures

    enum PanningState {
        case first
        case created
        case editing(Int)
    }

    func enablePanGesture() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let touchLocation = recognizer.location(in: view)

        switch recognizer.state {
        case .began:
            switch panningState {
            case .first:
                quadNode.resetMeasurement()
                quadNode.beginNewMeasurement(point: touchLocation)


            case .created:
                if let hit = quadNode.getIntersectingVertex(at: touchLocation) {
                    panningState = .editing(hit)
                }
            default:
                return
            }
        case .changed:
            summonMagnifyingGlass(at: touchLocation)
            switch panningState {
            case .first:
                quadNode.editMeasurement(vertex: 2, point: touchLocation, squared: true)

            case .editing(let vertex):
                quadNode.editMeasurement(vertex: vertex, point: touchLocation, squared: false)

            default:
                return
            }

            dummyNode.isHidden.toggle() // hack to force SKScene update
        case .ended:
            dismissMagnifyingGlass()
            dummyNode.isHidden = true

            switch panningState {
            case .first, .editing:
                quadNode.hitTestVertices()
                panningState = .created
            default:
                return
            }

        default:
            return
        }
    }

    private func summonMagnifyingGlass(at touchLocation: CGPoint) {
        magnifyingGlass.magnifiedView = imageView
        magnifyingGlass.magnify(at: touchLocation)
    }

    private func dismissMagnifyingGlass() {
        magnifyingGlass.magnifiedView = nil
    }
}
