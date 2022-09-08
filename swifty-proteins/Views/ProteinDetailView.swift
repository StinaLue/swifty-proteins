//
//  ProteinDetailView.swift
//  swifty-proteins
//
//  Created by Stina on 06/09/2022.
//
// https://pdb101.rcsb.org/learn/guide-to-understanding-pdb-data/small-molecule-ligands

import SwiftUI
import SceneKit


struct ProteinDetailView: View {
	
	@State private var isLoading = true
	@State private var errorLoadingData = false
	@State private var wrongURL = false
	@State private var showingAlert = true
	
	@State private var finishedLoading = false
	@State private var contents = ""
	@State private var atoms = [Atom]()
	@State var ligand = ""

    var body: some View {
		VStack {
			//Text(Atoms[1].atomName)
			/*Button("lel") {
				fetchLigandIdealData()
				finis = true
			}*/
			if finishedLoading {
				SceneKitView()
					.scaledToFit()
			}
			if errorLoadingData {
				Text("Content could not be loaded")
			}
			if wrongURL {
				Text("URL does not exist")
			}
			if isLoading {
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle())
			}
		}
		.navigationTitle("Ligand: \(ligand)")
		.onAppear { fetchLigandIdealData() }
		/*.alert("A problem occured. Please check your connection and try again.", isPresented: $showingAlert) {
			Button("OK", role: .cancel) { isLoading = true }
		}*/
    }
	
	func fetchLigandIdealData() {
		if let url = URL(string: "https://files.rcsb.org/ligands/view/\(ligand)_ideal.pdb") {
			do {
				contents = try String(contentsOf: url)
				//print(contents)
				isLoading = false
				loadLigandIdealData()
			} catch {
				print("Content could not be loaded")
				errorLoadingData = true
				isLoading = false
			}
		} else {
			print("Bad URL")
			wrongURL = true
			isLoading = false
		}
	}
	
	func loadLigandIdealData() {
		let dataLines = contents.split(separator: "\n")
		for line in dataLines {
			// TODO : Protect against invalid files
			let atomDetails = line.split(separator: " ")
			if atomDetails[0].uppercased() == "ATOM"
			{
				let colorOfAtom = setColorOfAtom(atom: String(atomDetails[11]))
				atoms.append(Atom(atomId: Int(atomDetails[1])!, atomName: String(atomDetails[2]), xCoordinate: Double(atomDetails[6])!, yCoordinate: Double(atomDetails[7])!, zCoordinate: Double(atomDetails[8])!, element: String(atomDetails[11]), color: colorOfAtom)) // TODO : Protect against invalid types (avoid force unwrapping)
			}
			else if atomDetails[0].uppercased() == "CONECT" {
				// TODO : Add connections
			}
			else if atomDetails[0].uppercased() == "END" {
				// Do nothing
			}
			else {
				showingAlert = true
				return;
			}
		}
		isLoading = false
		finishedLoading = true
		/*for atom in atoms {
			print(atom)
		}*/
	}
	func setColorOfAtom(atom: String) -> UIColor {

		let colorOfAtom: UIColor
		if atom == "H" {
			colorOfAtom = UIColor.red
		}
		else {
			colorOfAtom =  UIColor.blue
		}
		//print(atom)
		return(colorOfAtom)
	}
}

struct Protein {
	var Atoms = [Atom]()
	//var Connections = [AtomConnections]()
}

struct Atom {
	var atomId: Int
	var atomName: String
	var xCoordinate: Double
	var yCoordinate: Double
	var zCoordinate: Double
	var element: String
	var color: UIColor // TODO : make type Color
}

struct SceneKitView: UIViewRepresentable {
	@State private var atoms = [Atom]()

	func makeUIView(context: UIViewRepresentableContext<SceneKitView>) -> SCNView {
		let sceneView = SCNView()
		sceneView.scene = SCNScene()
		sceneView.allowsCameraControl = true
		sceneView.autoenablesDefaultLighting = true
		sceneView.backgroundColor = UIColor.systemBackground
		var sphere = [[UIColor.red, Float(1.0)], [UIColor.blue, Float(2.8)], [UIColor.yellow, Float(1.8)], [UIColor.green, Float(4.8)]]
		for atom in atoms {
			print("yas")
			print(atom)
		}
		print(atoms)
		for item in sphere {
			let thing = SCNSphere(radius: 0.1)
			thing.firstMaterial?.diffuse.contents = item[0]
			let spherenode = SCNNode(geometry: thing)
			spherenode.position = SCNVector3(x: item[1] as! Float, y: 0.1, z: 0.1)
			sceneView.scene?.rootNode.addChildNode(spherenode)
		}
		//let sphere = SCNSphere(radius: 0.5)
		//let sphere2 = SCNSphere(radius: 0.5)
		
		//sphere.firstMaterial?.diffuse.contents = UIColor.blue
		//sphere2.firstMaterial?.diffuse.contents = UIColor.red
		
		//let spherenode = SCNNode(geometry: sphere)
		//spherenode.position = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
		//let spherenode2 = SCNNode(geometry: sphere2)
		//spherenode2.position = SCNVector3(x: 0.0, y: 0.0, z: 0.5)
		
		//sceneView.scene?.rootNode.addChildNode(spherenode)
		//sceneView.scene?.rootNode.addChildNode(spherenode2)
		
		return sceneView
	}
	
	func updateUIView(_ uiView: SCNView, context: UIViewRepresentableContext<SceneKitView>) {
		
	}
	
	typealias UIViewType = SCNView
}

struct ProteinDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProteinDetailView(ligand: "001")
    }
}
