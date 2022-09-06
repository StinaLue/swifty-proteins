//
//  ProteinListView.swift
//  swifty-proteins
//
//  Created by Stina on 06/09/2022.
//

import SwiftUI

struct ProteinListView: View {
	@ObservedObject var model: LigandModel
	
	var body: some View {
		List {
			ForEach(model.dataArray, id: \.self) { ligand in
				NavigationLink(destination: ProteinDetailView(ligand: ligand)) {
					Text(ligand)
				}
			}
		}
	}
}

struct ProteinListView_Previews: PreviewProvider {
	static var previews: some View {
		ProteinListView(model: LigandModel()/*, dataArray: LigandModel().dataArray*/)
	}
}
