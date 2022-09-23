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
	
	public func makeUIView(context: Context) -> SCNView {

		let sceneView = SCNView()
		let camera = SCNCamera()
		let cameraNode = SCNNode()
		
		sceneView.scene = SCNScene()
		cameraNode.camera = camera
		cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 30.0)
		
		sceneView.allowsCameraControl = true
		sceneView.autoenablesDefaultLighting = true
		sceneView.backgroundColor = UIColor.systemBackground
		for item in atoms {
			let sphere = SCNSphere(radius: 0.1)
			sphere.firstMaterial?.diffuse.contents = item.color
			let sphereNode = SCNNode(geometry: sphere)
			//let line = SCNGeometry()
			sphereNode.name = item.element
			sphereNode.position = SCNVector3(x: Float(item.xCoordinate), y: Float(item.yCoordinate), z: Float(item.zCoordinate))
			sceneView.scene?.rootNode.addChildNode(sphereNode)
			//sceneView.scene?.rootNode.addChildNode(
			//var geometry: SCNGeometry
			for connection in item.connections {
				let line = SCNGeometry.lineFrom(vector: sphereNode.position, toVector: SCNVector3(x: Float(atoms[connection - 1].xCoordinate), y: Float(atoms[connection - 1].yCoordinate), z: Float(atoms[connection - 1].zCoordinate)))
				let lineNode = SCNNode(geometry: line)
				sceneView.scene?.rootNode.addChildNode(lineNode)
			}
			//let lineNode = SCNNode(geometry: line)
			//lineNode.addChildNode(line)
			//sceneView.scene?.rootNode.addChildNode(sphereNode)


			//print(sphereNode)
		}
		sceneView.scene?.rootNode.addChildNode(cameraNode)
		
		return sceneView
	}
	
	func updateUIView(_ uiView: SCNView, context: Context) {
		uiView.allowsCameraControl = true
		uiView.autoenablesDefaultLighting = true

		if (!showHydros) {
			uiView.scene?.rootNode.childNodes.filter({ $0.name == "H" }).forEach({ $0.removeFromParentNode() })
		}
		else {
			for item in atoms {
				if item.element == "H" {
				let sphere = SCNSphere(radius: 0.1)
				sphere.firstMaterial?.diffuse.contents = item.color
				let sphereNode = SCNNode(geometry: sphere)
				sphereNode.name = item.element
				sphereNode.position = SCNVector3(x: Float(item.xCoordinate), y: Float(item.yCoordinate), z: Float(item.zCoordinate))
				uiView.scene?.rootNode.addChildNode(sphereNode)
					/*for connection in item.connections {
						let line = SCNGeometry.lineFrom(vector: sphereNode.position, toVector: SCNVector3(x: Float(atoms[connection - 1].xCoordinate), y: Float(atoms[connection - 1].yCoordinate), z: Float(atoms[connection - 1].zCoordinate)))
						let lineNode = SCNNode(geometry: line)
						uiView.scene?.rootNode.addChildNode(lineNode)
					}*/
				}
			}
		}
	}
	
	typealias UIViewType = SCNView
}

extension SCNGeometry {
	class func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
		let indices: [Int32] = [0, 1]
		
		let source = SCNGeometrySource(vertices: [vector1, vector2])
		let element = SCNGeometryElement(indices: indices, primitiveType: .line)
		
		return SCNGeometry(sources: [source], elements: [element])
		
	}
}

/*
struct SceneKitView_Previews: PreviewProvider {
    static var previews: some View {
		SceneKitView(atoms: [Atom](), showHydros: $showHydros)
    }
}
*/
