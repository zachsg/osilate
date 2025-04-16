//
//  OrientationControlledView.swift
//  Osilate
//
//  Created by Zach Gottlieb on 4/16/25.
//

import SwiftUI
import UIKit

class OrientationHostingController<Content: View>: UIHostingController<Content> {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        // Allow portrait and landscape for this view
        return [.portrait, .landscapeLeft, .landscapeRight]
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
}

struct OrientationControlledView<Content: View>: UIViewControllerRepresentable {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> OrientationHostingController<Content> {
        let hostingController = OrientationHostingController(rootView: content)
        return hostingController
    }
    
    func updateUIViewController(_ uiViewController: OrientationHostingController<Content>, context: Context) {
        uiViewController.rootView = content
    }
}
