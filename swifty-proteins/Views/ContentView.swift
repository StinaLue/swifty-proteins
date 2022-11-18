//
//  ContentView.swift
//  swifty-proteins
//
//  Created by Stina on 05/09/2022.
//

import SwiftUI
import LocalAuthentication // Needed for Face ID / Biometric auth

struct ContentView: View {
    @Binding var isUnlocked: Bool
    @Binding var noBiometrics: Bool
    @State private var context = LAContext()
	@StateObject var model = Ligands()
	
    var body: some View {
		NavigationView {
			VStack {
				if isUnlocked {
					if noBiometrics {
						Text("Your device is not compatible with this application")
					}
					else {
						Text("Unlocked")
						VStack {
							NavigationLink(destination: ProteinListView(model: model), isActive: self.$isUnlocked){
							}
						}
						.padding()
					}
				}
				else {
					Text("Locked")
					Button("Authenticate") {
						authenticate()
					}
				}
			}
			.navigationBarTitle("Login View")
		}
    }
	
    func authenticate() {
        
        //let context = LAContext() 		// Provides info about authentication mechanism on user’s device
        context = LAContext()
        context.localizedFallbackTitle = ""
        var error: NSError? // Obj-C
        
        // Check whether biometric authentication is possible
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            print(error?.localizedDescription ?? "Can't evaluate policy")
            noBiometrics = true
            return
        }
        // it's possible, so go ahead and use it
        
        Task {
            do {
                noBiometrics = false
                let reason = "We need you to login in order to access to the application"
                try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
                isUnlocked = true
            } catch let error {
                print(error.localizedDescription)
                isUnlocked = false
            }
        }
    }
}

class Ligands: ObservableObject {
    
    @Published var dataArray: [String] = []
    
    init() { self.load(/*file: "data"*/) }
    
    func load(/*file: String*/) {
        if let filepath = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                DispatchQueue.main.async {
                    self.dataArray = contents.components(separatedBy: "\n")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("File not found")
        }
    }
}
/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
