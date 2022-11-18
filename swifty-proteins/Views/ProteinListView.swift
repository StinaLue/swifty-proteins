//
//  ProteinListView.swift
//  swifty-proteins
//
//  Created by Stina on 06/09/2022.
//

import SwiftUI

struct ProteinListView: View {
	@ObservedObject var model: Ligands // TODO : obs. necessary?
	@State private var searchText = ""
	@State private var errorLoadingData: Bool = false
	
	var body: some View {
		NavigationView {
			List {
				ForEach(filteredLigands, id: \.self) { ligand in
					NavigationLink(destination: ProteinDetailView(errorLoadingData: $errorLoadingData, ligand: ligand)) {
						Text(ligand)
					}
				}
				.listRowSeparator(.hidden)
				.listRowBackground(
					RoundedRectangle(cornerRadius: 20)
						.background(.clear)
						.foregroundColor(Color.gray)
						.padding(
							EdgeInsets(
								top: 3,
								leading: 0,
								bottom: 3,
								trailing: 00
							)
						)
				)
				.listRowSeparator(.hidden)
			}
			.padding(.bottom)
			.navigationTitle("Ligands")
			.searchable(text: $searchText, prompt: "Search for a ligand")
		}
		.navigationBarHidden(true)
		.navigationBarBackButtonHidden(true)
		.alert("Couldn't fetch the protein", isPresented: $errorLoadingData) {
			Button("OK :´(", role: .cancel) {
				//errorLoadingData = false
			}
		} message: {
			Text("Check your internet connection or retry later")
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
