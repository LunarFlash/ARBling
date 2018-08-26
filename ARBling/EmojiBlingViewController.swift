//
//  ViewController.swift
//  ARBling
//
//  Created by Yi Wang on 8/24/18.
//  Copyright © 2018 Yi Wang. All rights reserved.
//

import UIKit
import ARKit

class EmojiBlingViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - Variables
    let noseOptions = ["👃", "🐽", "💧", "⏄", " "]


    override func viewDidLoad() {
        super.viewDidLoad()
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // configeration to track face
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - Actions

}

// MARK: - Helpers
extension EmojiBlingViewController {

    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
        // Search node for a child whose name is “nose” and is of type EmojiNode
        let child = node.childNode(withName: "nose", recursively: false) as? EmojiNode
        // Get the vertex at index 9 from the ARFaceGeometry property of the ARFaceAnchor and put it into an array.
        // Where did index 9 come from? It’s a magic number. The ARFaceGeometry has 1220 vertices in it and index 9 is on the nose. This works, for now, but you’ll briefly read later the dangers of using these index constants and what you can do about it.
        let vertices = [anchor.geometry.vertices[9]]
        //     Use a member method of EmojiNode to update it’s position based on the vertex. This updatePosition(for:) method takes an array of vertices and sets the node’s position to their center.
        child?.updatePosition(for: vertices)
    }

}

// MARK: - ARSCNViewDelegate
extension EmojiBlingViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else { return nil }
        // Create a face geometry to be rendered by the Metal device.
        let faceGeometry = ARSCNFaceGeometry(device: device)
        // Create a SceneKit node based on the face geometry.
        let node = SCNNode(geometry: faceGeometry)
        // Set the fill mode for the node’s material to be just lines.
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }

    // this updates animation of the face mask on screen
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
        let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        // Update the ARSCNFaceGeometry using the ARFaceAnchor’s ARFaceGeometry
        faceGeometry.update(from: faceAnchor.geometry)
    }
}
