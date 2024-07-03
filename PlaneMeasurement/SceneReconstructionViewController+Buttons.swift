//
//  SceneReconstructionViewController+Buttons.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/13/24.
//

import UIKit

// MARK: - Methods for Record Button Setup

extension SceneReconstructionViewController {
    
    func initializeRecordButton() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            containerView.widthAnchor.constraint(equalToConstant: 60),
            containerView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let outerCircle = UIView()
        outerCircle.translatesAutoresizingMaskIntoConstraints = false
        outerCircle.backgroundColor = .white
        outerCircle.layer.cornerRadius = 30
        containerView.addSubview(outerCircle)
        
        NSLayoutConstraint.activate([
            outerCircle.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            outerCircle.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            outerCircle.widthAnchor.constraint(equalToConstant: 60),
            outerCircle.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        innerCircle = UIView()
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        innerCircle.backgroundColor = .red
        innerCircle.layer.cornerRadius = 25
        outerCircle.addSubview(innerCircle)
        
        NSLayoutConstraint.activate([
            innerCircle.centerXAnchor.constraint(equalTo: outerCircle.centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: outerCircle.centerYAnchor),
            innerCircle.widthAnchor.constraint(equalToConstant: 50),
            innerCircle.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(recordButtonTapped))
        containerView.addGestureRecognizer(tapGestureRecognizer)
    }
    
     func startBlinkingAnimation() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.autoreverses = true
        animation.repeatCount = .infinity
        innerCircle.layer.add(animation, forKey: "blinkingAnimation")
    }
    
    func stopBlinkingAnimation() {
        innerCircle.layer.removeAnimation(forKey: "blinkingAnimation")
    }
    
    @objc func recordButtonTapped() {
        updateIsRecording(_isRecording: !isRecording)
    }
}

// MARK: - Methods for Shutter Button setup

extension SceneReconstructionViewController {
    
    func setupShutterButton() {
        let shutterButton = UIButton(type: .system)
        shutterButton.translatesAutoresizingMaskIntoConstraints = false

        let largeConfig = UIImage.SymbolConfiguration(pointSize: 48, weight: .bold, scale: .large)
        let plusCircleImage = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)

        shutterButton.setImage(plusCircleImage, for: .normal)
        shutterButton.backgroundColor = .clear
        shutterButton.tintColor = .white
        shutterButton.layer.cornerRadius = 50
        view.addSubview(shutterButton)

        NSLayoutConstraint.activate([
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            shutterButton.widthAnchor.constraint(equalToConstant: 100),
            shutterButton.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        shutterButton.addTarget(self, action: #selector(shutterButtonPressed), for: .touchDown)
        shutterButton.addTarget(self, action: #selector(shutterButtonReleased), for: [.touchUpInside, .touchUpOutside])
    }
    
    @objc func shutterButtonPressed() {
        UIView.animate(withDuration: 0.1, animations: {
            self.shutterButtonTest.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }

    @objc func shutterButtonReleased() {
        UIView.animate(withDuration: 0.1, animations: {
            self.shutterButtonTest.transform = CGAffineTransform.identity
        })
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        self.shutterButtonTapped()
    }
    
    func shutterButtonTapped() {
        session.pause()
        sceneView.scene.rootNode.isHidden = true

        guard let frame = session.currentFrame else { return }
        guard let pov = sceneView.pointOfView else { return }
        let image = sceneView.snapshot()
        let rootNode = sceneView.scene.rootNode

        if let navigationController {
            let nextVC = DrawRulersViewController(
                viewSnapshot: image,
                pov: pov,
                frame: frame,
                root: rootNode
            )
            navigationController.pushViewController(nextVC, animated: false)
        }
    }
}
