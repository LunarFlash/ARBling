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
    // last element is left blank for switching off emoji bling for the traget area
    let noseOptions = ["👃", "🐽", "💧", " "]
    let eyeOptions = ["👁", "🌕", "🌟", "🔥", "⚽️", "🔎", " "]
    let mouthOptions = ["👄", "👅", "❤️", " "]
    let hatOptions = ["🎓", "🎩", "🧢", "⛑", "👒", " "]

    let features = ["nose", "leftEye", "rightEye", "mouth", "hat"]
    let featureIndices = [[9], [1064], [42], [24, 25], [20]]


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
}

// MARK: - Actions
extension EmojiBlingViewController {
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        // Get the location of the tap within the sceneView.
        let location = sender.location(in: sceneView)
        // Perform a hit test to get a list of nodes under the tap location.
        let results = sceneView.hitTest(location, options: nil)
        // Get the first (top) node at the tap location and make sure it’s an EmojiNode.
        if let result = results.first, let node = result.node as? EmojiNode {
            // Call the next() method to switch the EmojiNode to the next option in the list you used, when you created it.
            node.next()
        }
    }
}

// MARK: - Helpers
extension EmojiBlingViewController {

    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
        // Loop through the features and featureIndexes that you defined at the top of the class.
        for (feature, indices) in zip(features, featureIndices)  {
            // Find the the child node by the feature name and ensure it is an EmojiNode.
            let child = node.childNode(withName: feature, recursively: false) as? EmojiNode
            // Map the array of indexes to an array of vertices using the ARFaceGeometry property of the ARFaceAnchor.
            let vertices = indices.map { anchor.geometry.vertices[$0] }
            // Update the child node’s position using these vertices.
            child?.updatePosition(for: vertices)

            switch feature {
            case "leftEye":
                // Save off the x-scale of the node defaulting to 1.0.
                let scaleX = child?.scale.x ?? 1.0
                // Get the blend shape coefficient for eyeBlinkLeft and default to 0.0 (unblinked) if it’s not found.
                let eyeBlinkValue = anchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
                // Modify the y-scale of the node based on the blend shape coefficient.
                child?.scale = SCNVector3(scaleX, 1.0 - eyeBlinkValue, 1.0)
            case "rightEye":
                let scaleX = child?.scale.x ?? 1.0
                let eyeBlinkValue = anchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0
                child?.scale = SCNVector3(scaleX, 1.0 - eyeBlinkValue, 1.0)
            case "mouth":
                let jawOpenValue = anchor.blendShapes[.jawOpen]?.floatValue ?? 0.2
                child?.scale = SCNVector3(1.0, 0.8 + jawOpenValue, 1.0)
            default:
                break
            }
        }
    }

}

// MARK: - ARSCNViewDelegate
extension EmojiBlingViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let device = sceneView.device else {
                return nil
        }
        // Create a face geometry to be rendered by the Metal device.
        let faceGeometry = ARSCNFaceGeometry(device: device)
        // Create a SceneKit node based on the face geometry.
        let node = SCNNode(geometry: faceGeometry)
        // Set the fill mode for the node’s material to be just lines.
        node.geometry?.firstMaterial?.fillMode = .lines

        // Hide the mesh mask by making it transparent.
        node.geometry?.firstMaterial?.transparency = 0.0
        // Create an EmojiNode using our defined nose options.
        let noseNode = EmojiNode(with: noseOptions)
        // Name the nose node, so it can be found later.
        noseNode.name = "nose"
        // Add the nose node to the face node.
        node.addChildNode(noseNode)

        let leftEyeNode = EmojiNode(with: eyeOptions)
        leftEyeNode.name = "leftEye"
        leftEyeNode.rotation = SCNVector4(0, 1, 0, GLKMathDegreesToRadians(180.0))
        node.addChildNode(leftEyeNode)

        let rightEyeNode = EmojiNode(with: eyeOptions)
        rightEyeNode.name = "rightEye"
        node.addChildNode(rightEyeNode)

        let mouthNode = EmojiNode(with: mouthOptions)
        mouthNode.name = "mouth"
        node.addChildNode(mouthNode)

        let hatNode = EmojiNode(with: hatOptions)
        hatNode.name = "hat"
        node.addChildNode(hatNode)


        // Call our helper function that repositions facial features.
        updateFeatures(for: node, using: faceAnchor )

        return node
    }

    // this updates animation of the face mask on screen
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
        let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        // Update the ARSCNFaceGeometry using the ARFaceAnchor’s ARFaceGeometry
        faceGeometry.update(from: faceAnchor.geometry)
        updateFeatures(for: node, using: faceAnchor)
    }
}
