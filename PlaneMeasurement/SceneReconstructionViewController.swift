//
//  SceneReconstructionViewController.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/13/24.
//

import Foundation
import ARKit
import SceneKit
import MetalKit

class SceneReconstructionViewController: UIViewController, ARSessionDelegate {
    
    var sceneView: ARSCNView!
    var recordButton: UIButton!
    let shutterButtonTest = UIButton(type: .system)
    var innerCircle: UIView!
    var isRecording = false
    var renderer: Renderer!

    
    var session: ARSession {
        return sceneView.session
    }
    
    override func loadView() {
        view = MTKView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }
        
        setupSceneView()
        session.delegate = self
        
        // Set the view to use the default device
        if let view = view as? MTKView {
            view.device = device
            
            view.backgroundColor = UIColor.clear
            // we need this to enable depth test
            view.depthStencilPixelFormat = .depth32Float
            view.contentScaleFactor = 1
            view.delegate = self
            
            // Configure the renderer to draw to the view
            renderer = Renderer(session: session, metalDevice: device, renderDestination: view)
            renderer.drawRectResized(size: view.bounds.size)
            renderer.delegate = self
        } else {
            print("NO MTK VIEW")
        }
        
        initializeRecordButton()
        setupShutterButton()
        setupCoachingOverlay()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureSession()
        sceneView.scene.rootNode.isHidden = false
    }
    
    func configureSession() {
        // TODO: device compat?
        let configuration = ARWorldTrackingConfiguration()
        configuration.sceneReconstruction = .meshWithClassification
        configuration.environmentTexturing = .automatic
        configuration.frameSemantics = [.sceneDepth, .smoothedSceneDepth]
        session.run(configuration)
    }
    
    // MARK: - Coaching overlay
    let coachingOverlay = ARCoachingOverlayView()
    
    
    func setupSceneView() {
        //instantiate scene view in viewDidLoad
        sceneView = ARSCNView()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        
        //add it to parents subview
        self.view.addSubview(sceneView)
        
        //add autolayout contstraints
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func updateIsRecording(_isRecording: Bool) {
        // Provide haptic feedback
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()
        isRecording = _isRecording
        if isRecording {
            startBlinkingAnimation()
            renderer.currentFolder = getTimeStr()
            createDirectory(folder: renderer.currentFolder + "/data")
        } else {
            stopBlinkingAnimation()
            renderer.savePointCloud()
        }
        renderer.isRecording = isRecording
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        print("memory warning!!!")
        memoryAlert()
        updateIsRecording(_isRecording: false)
    }
    
    private func memoryAlert() {
        let alert = UIAlertController(title: "Low Memory Warning", message: "The recording has been paused. Do not quit the app until all files have been saved.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension SceneReconstructionViewController: TaskDelegate {
    func didStartTask() {
        print("Did Start Task")
    }
    
    func didFinishTask() {
        print("Completed another task")
    }
}


// MARK: - RenderDestinationProvider

protocol RenderDestinationProvider {
    var currentRenderPassDescriptor: MTLRenderPassDescriptor? { get }
    var currentDrawable: CAMetalDrawable? { get }
    var colorPixelFormat: MTLPixelFormat { get set }
    var depthStencilPixelFormat: MTLPixelFormat { get set }
    var sampleCount: Int { get set }
}

extension MTKView: RenderDestinationProvider {
    
}
