//  ARBling
//  Created by Yi Wang on 8/24/18.
//  Copyright © 2018 Yi Wang. All rights reserved.

import SceneKit

class EmojiNode: SCNNode {
  
  var options: [String]
  var index = 0
  
  init(with options: [String], width: CGFloat = 0.06, height: CGFloat = 0.06) {
    self.options = options
    
    super.init()
    
    let plane = SCNPlane(width: width, height: height)
    plane.firstMaterial?.diffuse.contents = (options.first ?? " ").image()
    plane.firstMaterial?.isDoubleSided = true
    
    geometry = plane
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Custom functions

extension EmojiNode {
  
  func updatePosition(for vectors: [vector_float3]) {
    let newPos = vectors.reduce(vector_float3(), +) / Float(vectors.count)
    position = SCNVector3(newPos)
  }
  
  func next() {
    index = (index + 1) % options.count
    
    if let plane = geometry as? SCNPlane {
      plane.firstMaterial?.diffuse.contents = options[index].image()
      plane.firstMaterial?.isDoubleSided = true
    }
  }
}
