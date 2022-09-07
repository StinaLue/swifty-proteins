//
//  ProteinDetailView.swift
//  swifty-proteins
//
//  Created by Stina on 06/09/2022.
//
// https://pdb101.rcsb.org/learn/guide-to-understanding-pdb-data/small-molecule-ligands

import SwiftUI

struct ProteinDetailView: View {
	
	@State private var isLoading = true
	@State private var errorLoadingData = false
	@State private var wrongURL = false
	@State private var contents = ""
	@State private var Atoms = []
	@State var ligand = ""

    var body: some View {
		VStack {
			/*Button("Print data") {
				loadLigandIdealData()
			}*/
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
			let atomDetails = line.split(separator: " ")
			if atomDetails[0].uppercased() == "ATOM"
			{
				//Atoms.iid = String(atomDetails[1])
				Atoms.append(contentsOf: [atomDetails[8], atomDetails[7]])
			}
		}
		print(Atoms)
	}
}


struct ProteinDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProteinDetailView(ligand: "001")
    }
}
