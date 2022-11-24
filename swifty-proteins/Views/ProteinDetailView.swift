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
	@Binding var errorLoadingData: Bool
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
				HStack {
					Spacer()
					Toggle("Show hydrogens", isOn: $showHydros)
						.toggleStyle(SwitchToggleStyle(tint: .green))
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
                                errorLoadingData = false
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
					if(Int(atomDetails[1])! - 1 < atoms.count) {
						atoms[Int(atomDetails[1])! - 1].connections.append(contentsOf: [Int(item)!])
					}
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
		switch atom {
		case "H":
			colorOfAtom = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
		case "C":
			colorOfAtom = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
		case "N": 
			colorOfAtom = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
		case "O": 
			colorOfAtom = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
		case "F": 
			colorOfAtom = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
		case "CI": 
			colorOfAtom = UIColor(red: 0, green: 1, blue: 0, alpha: 1)
		case "BR": 
			colorOfAtom = UIColor(red: 0.6, green: 0.13, blue: 0, alpha: 1)
		case "I": 
			colorOfAtom = UIColor(red: 0.4, green: 0, blue: 0.73, alpha: 1)
		case "HE": 
			colorOfAtom = UIColor(red: 0, green: 1, blue: 1, alpha: 1)
		case "NE": 
			colorOfAtom = UIColor(red: 0, green: 1, blue: 1, alpha: 1)
		case "AR": 
			colorOfAtom = UIColor(red: 0, green: 1, blue: 1, alpha: 1)
		case "XE": 
			colorOfAtom = UIColor(red: 0, green: 1, blue: 1, alpha: 1)
		case "KR": 
			colorOfAtom = UIColor(red: 0, green: 1, blue: 1, alpha: 1)
		case "P": 
			colorOfAtom = UIColor(red: 1, green: 0.564, blue: 0, alpha: 1)
		case "S": 
			colorOfAtom = UIColor(red: 1, green: 0.898, blue: 1.33, alpha: 1)
		case "B": 
			colorOfAtom = UIColor(red: 1, green: 0.66, blue: 0.46, alpha: 1)
		case "LI": 
			colorOfAtom = UIColor(red: 0.46, green: 0, blue: 1, alpha: 1)
		case "NA": 
			colorOfAtom = UIColor(red: 0.46, green: 0, blue: 1, alpha: 1)
		case "K":
			colorOfAtom = UIColor(red: 0.46, green: 0, blue: 1, alpha: 1)
		case "RB": 
			colorOfAtom = UIColor(red: 0.46, green: 0, blue: 1, alpha: 1)
		case "CS": 
			colorOfAtom = UIColor(red: 0.46, green: 0, blue: 1, alpha: 1)
		case "FR": 
			colorOfAtom = UIColor(red: 0.46, green: 0, blue: 1, alpha: 1)
		case "BE": 
			colorOfAtom = UIColor(red: 0, green: 0.46, blue: 0, alpha: 1)
		case "MG": 
			colorOfAtom = UIColor(red: 0, green: 0.46, blue: 0, alpha: 1)
		case "CA": 
			colorOfAtom = UIColor(red: 0, green: 0.46, blue: 0, alpha: 1)
		case "SR": 
			colorOfAtom = UIColor(red: 0, green: 0.46, blue: 0, alpha: 1)
		case "BA": 
			colorOfAtom = UIColor(red: 0, green: 0.46, blue: 0, alpha: 1)
		case "RA": 
			colorOfAtom = UIColor(red: 0, green: 0.46, blue: 0, alpha: 1)
		case "TI": 
			colorOfAtom = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
		case "FE": 
			colorOfAtom = UIColor(red: 0.86, green: 0.46, blue: 0, alpha: 1)
		default:
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
