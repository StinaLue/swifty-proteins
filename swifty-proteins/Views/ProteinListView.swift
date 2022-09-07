//
//  ProteinListView.swift
//  swifty-proteins
//
//  Created by Stina on 06/09/2022.
//

import SwiftUI

struct ProteinListView: View {
	@ObservedObject var model: Ligands
	@State private var searchText = ""
	
	var body: some View {
		NavigationView {
			List {
				ForEach(filteredLigands, id: \.self) { ligand in
					NavigationLink(destination: ProteinDetailView(ligand: ligand)) {
						Text(ligand)
					}
				}
			}
			.navigationTitle("Ligands")
			.searchable(text: $searchText, prompt: "Search for a ligand")
		}
	}
	var filteredLigands: [String] {
		if searchText.isEmpty {
			return model.dataArray
		} else {
			return model.dataArray.filter { $0.localizedCaseInsensitiveContains(searchText) }
		}
	}
}

struct ProteinListView_Previews: PreviewProvider {
	static var previews: some View {
		ProteinListView(model: Ligands())
	}
}
