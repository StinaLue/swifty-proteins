//
//  ProteinDetailView.swift
//  swifty-proteins
//
//  Created by Stina on 06/09/2022.
//

import SwiftUI

struct ProteinDetailView: View {

	@State var ligand = ""

    var body: some View {
		VStack {
			Text("It's the \(ligand) ligand :D")
			Text("https://files.rcsb.org/ligands/view/\(ligand)_model.sdf")
		}
    }
}

struct ProteinDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProteinDetailView(ligand: "001")
    }
}
