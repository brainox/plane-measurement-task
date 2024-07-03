//
//  SceneReconstructionViewController+ARSCNViewDelegate.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/13/24.
//

import ARKit
import SceneKit

extension SceneReconstructionViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let meshAnchor = anchor as? ARMeshAnchor else {
                return nil
            }

        let geometry = createGeometryFromAnchor(meshAnchor: meshAnchor)

//        geometry.firstMaterial?.colorBufferWriteMask = []
//        geometry.firstMaterial?.writesToDepthBuffer = true
//        geometry.firstMaterial?.readsFromDepthBuffer = true
        geometry.firstMaterial?.fillMode = .lines
        geometry.firstMaterial?.diffuse.contents = UIColor.red

        let node = SCNNode(geometry: geometry)
        node.renderingOrder = -1

        return node
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let meshAnchor = anchor as? ARMeshAnchor else {
                return
            }
        let geometry = createGeometryFromAnchor(meshAnchor: meshAnchor)

//            geometry.firstMaterial?.colorBufferWriteMask = []
//            geometry.firstMaterial?.writesToDepthBuffer = true
//            geometry.firstMaterial?.readsFromDepthBuffer = true
            geometry.firstMaterial?.fillMode = .lines
            geometry.firstMaterial?.diffuse.contents = UIColor.red


        node.geometry = geometry
    }
}


// https://developer.apple.com/forums/thread/130599
func createGeometryFromAnchor(meshAnchor: ARMeshAnchor) -> SCNGeometry {
    let meshGeometry = meshAnchor.geometry
    let vertices = meshGeometry.vertices
    let normals = meshGeometry.normals
    let faces = meshGeometry.faces

    let vertexSource = SCNGeometrySource(buffer: vertices.buffer, vertexFormat: vertices.format, semantic: .vertex, vertexCount: vertices.count, dataOffset: vertices.offset, dataStride: vertices.stride)

    let normalsSource = SCNGeometrySource(buffer: normals.buffer, vertexFormat: normals.format, semantic: .normal, vertexCount: normals.count, dataOffset: normals.offset, dataStride: normals.stride)

    let faceData = Data(bytes: faces.buffer.contents(), count: faces.buffer.length)

    let geometryElement = SCNGeometryElement(data: faceData, primitiveType: primitiveType(type: faces.primitiveType), primitiveCount: faces.count, bytesPerIndex: faces.bytesPerIndex)

    return SCNGeometry(sources: [vertexSource, normalsSource], elements: [geometryElement])
}

func primitiveType(type: ARGeometryPrimitiveType) -> SCNGeometryPrimitiveType {
    switch type {
        case .line: return .line
        case .triangle: return .triangles
        default : return .triangles
    }
}
