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
			ForEach(model.dataArray, id: \.self) { data in
				NavigationLink(destination: ProteinDetailView()) {
					Text(data)
				}
			}
		}
		/*List {
			ForEach(model.dataArray, id: \.) {
				Text(model.dataArray)
			}
		}*/
		/*List {
			Text(model.dataArray)
			Text(model.dataArray)
		}*/
		/*List() {
			NavigationLink(destination: ProteinDetailView(model: model)) {
				Text(model.data).frame(maxWidth: .infinity)
			}
		}
		.padding()
		.navigationBarTitle("Ligand IDs")*/
	}
}

struct ProteinListView_Previews: PreviewProvider {
	static var previews: some View {
		ProteinListView(model: LigandModel()/*, dataArray: LigandModel().dataArray*/)
	}
}
