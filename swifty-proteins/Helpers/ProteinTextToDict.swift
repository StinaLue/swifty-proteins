//
//  ProteinTextToDict.swift
//  swifty-proteins
//
//  Created by Stina on 06/09/2022.
//

import Foundation

let path = Bundle.main.path(forResource: "ligands", ofType: "txt")
let source = try? String.init(contentsOfFile: path!)
var elements = source?.components(separatedBy: "\n")
//var parsedObject = [[String: String]]()

