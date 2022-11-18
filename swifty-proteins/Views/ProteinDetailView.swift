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
	@State private var showHydros = true

	@State private var atoms = [Atom]()
	@State var tapLocation = CGPoint(x: 0.0, y: 0.0)
	@State var ligand = ""
    
    @State var sceneView = SCNView()
    @State var snapshot: Image?
    /*
    @State private var cameraNode: SCNNode = SCNNode()
    @State private var scene: SCNScene = SCNScene()
*/
    @ViewBuilder
    var body: some View {
		VStack {
			if finishedLoading {
                Button {
                    let flippedUIsnapshot: UIImage = sceneView.snapshot()
                    //let UIsnapshot = UIImage(cgImage: flippedUIsnapshot.cgImage!, scale: 1.0, orientation: .downMirrored)
                    let UIsnapshot = flippedUIsnapshot
                    snapshot = Image(uiImage: UIsnapshot)
                    print("Snapshot taken !")
                } label: {
                    Image(systemName: "camera")
                }
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        if snapshot != nil {
                            ShareLink(item: snapshot!, preview: SharePreview("protein", image: snapshot!))
                        }
                    }
                }
                SceneKitView(atoms: atoms, showHydros: $showHydros, sceneView: $sceneView, tapLocation: $tapLocation)
                //SceneKitView(atoms: atoms, showHydros: $showHydros, tapLocation: $tapLocation, scene: $scene, cameraNode: $cameraNode)
				.onTapGesture { location in
						tapLocation = location
					}
				.scaledToFill()
				//.scaledToFit()
				HStack {
					Spacer()
					Toggle("Show hydrogens", isOn: $showHydros)
						.toggleStyle(SwitchToggleStyle(tint: .green))
					//Text("Atom : \(currentAtomName)")
					Spacer()
				}
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
        //.onAppear { fetchLigandIdealData() }
		.task {
            //cameraNode = createCamera()
            await fetchLigandIdealData()
        }
		/*.alert("A problem occured. Please check your connection and try again.", isPresented: $showingAlert) {
			Button("OK", role: .cancel) { isLoading = true }
		}*/
    }
	
   /* func createCamera() -> SCNNode {
        print("New camera created")
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 30.0)
        scene.rootNode.addChildNode(cameraNode)
        return cameraNode
    }*/
    
	func fetchLigandIdealData() async {
        errorLoadingData = false
		if let url = URL(string: "https://files.rcsb.org/ligands/view/\(ligand)_ideal.pdb") {
			do {
                let data:Data
                (data, _) = try await URLSession.shared.data(from: url)
                let contents = String(decoding: data, as: UTF8.self)
				//print(contents)
				isLoading = false
                loadLigandIdealData(input: contents)
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
	
    func loadLigandIdealData(input: String) {
		let dataLines = input.split(separator: "\n")
		for line in dataLines {
			// TODO : Protect against invalid files
			let atomDetails = line.split(separator: " ")
			if atomDetails[0].uppercased() == "ATOM"
			{
				let colorOfAtom = setColorOfAtom(atom: String(atomDetails[11]))
				atoms.append(Atom(atomId: Int(atomDetails[1])!,
								  atomName: String(atomDetails[2]),
								  xCoordinate: Double(atomDetails[6])!,
								  yCoordinate: Double(atomDetails[7])!,
								  zCoordinate: Double(atomDetails[8])!,
								  element: String(atomDetails[11]),
								  color: colorOfAtom,
								 connections: [])) // TODO : Protect against invalid types (avoid force unwrapping)
			}
			else if atomDetails[0].uppercased() == "CONECT" {
				for item in atomDetails.dropFirst() {
					atoms[Int(atomDetails[1])! - 1].connections.append(contentsOf: [Int(item)!])
				}
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
		//print(atoms)
		isLoading = false
		finishedLoading = true
	}
	
	func setColorOfAtom(atom: String) -> UIColor {

		let colorOfAtom: UIColor
		if atom == "H" {
			colorOfAtom = UIColor.white
		}
		else if atom == "C" {
			colorOfAtom = UIColor.gray
		}
		else if atom == "F" {
			colorOfAtom = UIColor.green
		}
		else if atom == "L" {
			colorOfAtom = UIColor.brown
		}
		else if atom == "N" {
			colorOfAtom = UIColor.blue
		}
		else if atom == "O" {
			colorOfAtom = UIColor.red
		}
		else if atom == "P" {
			colorOfAtom = UIColor.orange
		}
		else if atom == "S" {
			colorOfAtom = UIColor.yellow
		}
		else {
			colorOfAtom =  UIColor.cyan
		}
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
	var connections: [Int] = []
}
/*
struct ProteinDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProteinDetailView(ligand: "001")
    }
}
*/
