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
	@State var sceneView = SCNView()
	@Binding var tapLocation: CGPoint
	@State var teeeest: String = "xs"
	
	public func makeUIView(context: Context) -> SCNView {

		//var sceneView = SCNView()
		let camera = SCNCamera()
		let cameraNode = SCNNode()
		let nodeLabel = SCNText(string: self.teeeest, extrusionDepth: 0)
		//let textNode = SCNNode(geometry: nodeLabel)
		
		sceneView.scene = SCNScene()
		cameraNode.camera = camera
		cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 30.0)
		
		sceneView.allowsCameraControl = true
		sceneView.autoenablesDefaultLighting = true
		sceneView.backgroundColor = UIColor.systemBackground
		sceneView = drawNodesAndLines(sceneView: sceneView)
		sceneView.scene?.rootNode.addChildNode(cameraNode)
		//sceneView.scene?.rootNode.addChildNode(textNode)
		//let hitResults = self.sceneView.hitTest(position, options: [:])

		//let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
		//sceneView.addGestureRecognizer(tapGesture)

		return sceneView
	}
	
	func drawNodesAndLines(sceneView: SCNView) -> SCNView {
		for item in atoms {
			let sphere = SCNSphere(radius: 0.1)
			sphere.firstMaterial?.diffuse.contents = item.color
			let sphereNode = SCNNode(geometry: sphere)
			sphereNode.name = item.element
			sphereNode.position = SCNVector3(x: Float(item.xCoordinate), y: Float(item.yCoordinate), z: Float(item.zCoordinate))
			sceneView.scene?.rootNode.addChildNode(sphereNode)
			for connection in item.connections.dropFirst() {
				let positionA = sphereNode.position
				let positionB = SCNVector3(x: Float(atoms[connection - 1].xCoordinate), y: Float(atoms[connection - 1].yCoordinate), z: Float(atoms[connection - 1].zCoordinate))
				let node = lineBetweenNodes(positionA: positionA, positionB: positionB, inScene: sceneView.scene!)
				if item.element == "H" || atoms[connection - 1].element == "H" {
					node.name = "H"
				}
				sceneView.scene?.rootNode.addChildNode(node)
			}
		}

		return(sceneView)
	}
	
	// Calculation of the lines between two nodes
	func lineBetweenNodes(positionA: SCNVector3, positionB: SCNVector3, inScene: SCNScene) -> SCNNode {
		let vector = SCNVector3(positionA.x - positionB.x, positionA.y - positionB.y, positionA.z - positionB.z)
		let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
		let midPosition = SCNVector3 (x:(positionA.x + positionB.x) / 2, y:(positionA.y + positionB.y) / 2, z:(positionA.z + positionB.z) / 2)
		
		let lineGeometry = SCNCylinder()
		lineGeometry.radius = 0.02
		lineGeometry.height = CGFloat(distance)
		//lineGeometry.radialSegmentCount = 5
		lineGeometry.firstMaterial!.diffuse.contents = UIColor.blue
		
		let lineNode = SCNNode(geometry: lineGeometry)
		lineNode.position = midPosition
		lineNode.look(at: positionB, up: inScene.rootNode.worldUp, localFront: lineNode.worldUp)
		return lineNode
	}

	func updateUIView(_ uiView: SCNView, context: Context) {
		uiView.allowsCameraControl = true
		uiView.autoenablesDefaultLighting = true
		
		let hitResults = uiView.hitTest(tapLocation, options: [:])
		var count = 0
		if hitResults.count > 0 {
			let result = hitResults[count]
			self.teeeest = result.node.name ?? "No atom tapped" // TODO: Check this
			print(self.teeeest)
			count = count + 1
		}

		if (!showHydros) {
			uiView.scene?.rootNode.childNodes.filter({ $0.name == "H" }).forEach({ $0.removeFromParentNode() })
		}
		//uiView = drawNodesAndLines(sceneView: uiView)

		else {
			for item in atoms {
					let sphere = SCNSphere(radius: 0.1)
					sphere.firstMaterial?.diffuse.contents = item.color
					let sphereNode = SCNNode(geometry: sphere)
					sphereNode.name = item.element
					sphereNode.position = SCNVector3(x: Float(item.xCoordinate), y: Float(item.yCoordinate), z: Float(item.zCoordinate))
				if item.element == "H" {
					uiView.scene?.rootNode.addChildNode(sphereNode)
				}
				for connection in item.connections {
					if atoms[connection - 1].element == "H" {
						let positionA = sphereNode.position
						let positionB = SCNVector3(x: Float(atoms[connection - 1].xCoordinate), y: Float(atoms[connection - 1].yCoordinate), z: Float(atoms[connection - 1].zCoordinate))
						let node = lineBetweenNodes(positionA: positionA, positionB: positionB, inScene: uiView.scene!)
						uiView.scene?.rootNode.addChildNode(node)
					}
				}
			}
		}
	}
	typealias UIViewType = SCNView
}

extension SCNVector3 {
	func distance(to destination: SCNVector3) -> CGFloat {
		let dx = destination.x - x
		let dy = destination.y - y
		let dz = destination.z - z
		return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
	}
}

extension SCNCylinder {
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
