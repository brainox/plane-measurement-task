//
//  ContentView.swift
//  PlaneMeasurement
//
//  Created by Adwith Mukherjee on 6/10/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        PlaneDetectionView()
            .ignoresSafeArea()
    }
}

struct PlaneDetectionView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return UINavigationController(rootViewController: SceneReconstructionViewController())
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

#Preview {
    ContentView()
}
