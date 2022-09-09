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
	@Binding var showHydros: Bool
	
	public func makeUIView(context: /*UIViewRepresentableContext<SceneKitView>*/Context) -> SCNView {

		let sceneView = SCNView()
		let camera = SCNCamera()
		let cameraNode = SCNNode()
		
		sceneView.scene = SCNScene()
		cameraNode.camera = camera
		cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 30.0)
		
		sceneView.allowsCameraControl = true
		sceneView.autoenablesDefaultLighting = true
		sceneView.backgroundColor = UIColor.systemBackground
		/*for item in atoms {
			if item.element == "H" && !showHydros {
				//
				print("H found here : \(showHydros)")
			}
			else {
				print("no H : \(showHydros)")
				let sphere = SCNSphere(radius: 0.1)
				sphere.firstMaterial?.diffuse.contents = item.color
				let spherenode = SCNNode(geometry: sphere)
				spherenode.position = SCNVector3(x: Float(item.xCoordinate) , y: Float(item.yCoordinate), z: Float(item.zCoordinate))
				sceneView.scene?.rootNode.addChildNode(spherenode)
			}
		 }*/
		sceneView.scene?.rootNode.addChildNode(cameraNode)
		return sceneView
	}
	
	func updateUIView(_ uiView: SCNView, context: /*UIViewRepresentableContext<SceneKitView>*/Context) {
		uiView.allowsCameraControl = true
		uiView.autoenablesDefaultLighting = true

		for item in atoms {
			let sphere = SCNSphere(radius: 0.1)
			sphere.firstMaterial?.diffuse.contents = item.color
			let spherenode = SCNNode(geometry: sphere)
			spherenode.name = item.element
			spherenode.position = SCNVector3(x: Float(item.xCoordinate) , y: Float(item.yCoordinate), z: Float(item.zCoordinate))
			uiView.scene?.rootNode.addChildNode(spherenode)

		}
		if (!showHydros) {
			uiView.scene?.rootNode.childNodes.filter({ $0.name == "H" }).forEach({ $0.removeFromParentNode() })
		}
	}
	
	typealias UIViewType = SCNView
}

/*
struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
		SceneKitView(atoms: [Atom](), showHydros: $showHydros)
    }
}
*/
