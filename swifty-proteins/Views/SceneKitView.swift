//
//  SceneKitView.swift
//  swifty-proteins
//
//  Created by Stina on 09/09/2022.
//

import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
	let atoms: [Atom]
	
	public func makeUIView(context: /*UIViewRepresentableContext<SceneKitView>*/Context) -> SCNView {

		let sceneView = SCNView()
		sceneView.scene = SCNScene()
		sceneView.allowsCameraControl = true
		sceneView.autoenablesDefaultLighting = true
		sceneView.backgroundColor = UIColor.systemBackground
		for item in atoms {
			if item.element != "H" {
				let sphere = SCNSphere(radius: 0.1)
				sphere.firstMaterial?.diffuse.contents = item.color
				let spherenode = SCNNode(geometry: sphere)
				spherenode.position = SCNVector3(x: Float(item.xCoordinate) , y: Float(item.yCoordinate), z: Float(item.zCoordinate))
				sceneView.scene?.rootNode.addChildNode(spherenode)
			}
		}
		return sceneView
	}
	
	func updateUIView(_ uiView: SCNView, context: /*UIViewRepresentableContext<SceneKitView>*/Context) {
		
	}
	
	typealias UIViewType = SCNView
}


struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
		SceneKitView(atoms: [Atom]())
    }
}
