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
    @State private var scene: SCNScene = SCNScene()
    @Binding var sceneView: SCNView
	@Binding var tapLocation: CGPoint
	
	public func makeUIView(context: Context) -> SCNView {

		let camera = SCNCamera()
		let cameraNode = SCNNode()
		
        sceneView.scene = scene
		cameraNode.camera = camera
		cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 30.0)
		
		sceneView.allowsCameraControl = true
		sceneView.autoenablesDefaultLighting = true
		sceneView.backgroundColor = UIColor.systemBackground
		sceneView = drawNodesAndLines(sceneView: sceneView)

		sceneView.scene?.rootNode.addChildNode(cameraNode)

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
            for connection in item.connections {//.dropFirst() { // TODO : Check if i really should drop
                let positionA = sphereNode.position
                let positionB = SCNVector3(x: Float(atoms[connection - 1].xCoordinate), y: Float(atoms[connection - 1].yCoordinate), z: Float(atoms[connection - 1].zCoordinate))
                let node = lineBetweenNodes(positionA: positionA, positionB: positionB, inScene: sceneView.scene!)
                if item.element == "H" || atoms[connection - 1].element == "H" {
                    node.name = "H"
                }
                sceneView.scene?.rootNode.addChildNode(node)
            }
        }
        
        if (!showHydros)
        {
            sceneView.scene?.rootNode.childNodes.filter({ $0.name == "H" }).forEach({ $0.removeFromParentNode() })
        }
        
        return(sceneView)
    }
	
	/// Calculation of the lines between two nodes
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
			let text = SCNText(string: result.node.name ?? "Not found", extrusionDepth: 0.2)
			text.font = UIFont(name: "Skia-Regular_Black", size: 2)
			text.firstMaterial?.diffuse.contents = UIColor.black
			let textNode = SCNNode(geometry: text)
			textNode.scale = SCNVector3Make(0.1, 0.1, 1)
			textNode.position = SCNVector3(x: Float(result.node.position.x), y: Float(result.node.position.y), z: Float(result.node.position.z))
			textNode.name = "oldNode"
			uiView.scene?.rootNode.childNodes.filter({ $0.name == "oldNode" }).forEach({ $0.removeFromParentNode() })

			uiView.scene?.rootNode.addChildNode(textNode)
			count = count + 1
		}
        sceneView = drawNodesAndLines(sceneView: uiView)
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
