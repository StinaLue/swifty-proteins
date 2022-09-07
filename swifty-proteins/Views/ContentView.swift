//
//  ContentView.swift
//  swifty-proteins
//
//  Created by Stina on 05/09/2022.
//

import SwiftUI
import LocalAuthentication // Needed for Face ID / Biometric auth

struct ContentView: View {
	@State private var isUnlocked = true // TODO : put this to false
	@State private var noBiometrics = false
	@ObservedObject var model = Ligands()
	
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

		let context = LAContext() 		// Provides info about authentication mechanism on user’s device
		var error: NSError? // Obj-C
		
		// Check whether biometric authentication is possible
		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			// it's possible, so go ahead and use it
			let reason = "We need you to login in order to access to the application"
			
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
				// authentication has now completed
				if success {
					isUnlocked = true
					// authenticated successfully
				} else {
					let code = LAError.Code(rawValue: error!.code) // TODO : Verify
					
					switch code! {
					case .appCancel:
						break;
						// The app canceled authentication by
						// invalidating the LAContext
					case .authenticationFailed:
						// The user did not provide
						// valid credentials
						break;
					case .invalidContext:
						// The LAContext was invalid
						break;
					case .notInteractive:
						// Interaction was not allowed so the
						// authentication failed
						break;
					case .passcodeNotSet:
						// The user has not set a passcode
						// on this device
						break;
					case .systemCancel:
						// The system canceled authentication,
						// for example to show another app
						break;
					case .userCancel:
						// The user canceled the
						// authentication dialog
						break;
					case .userFallback:
						// The user selected to use a fallback
						// authentication method
						break;
					case .biometryLockout:
						// Too many failed attempts locked
						// biometric authentication
						break;
					case .biometryNotAvailable:
						// The user's device does not support
						// biometric authentication
						break;
					case .biometryNotEnrolled:
						// The user has not configured
						// biometric authentication
						break;
					case .touchIDNotAvailable:
						break;
					case .touchIDNotEnrolled:
						break;
					case .touchIDLockout:
						break;
					@unknown default:
						// An other error occurred
						break;
					}
					print("auth unsuccessful")
					
					// there was a problem
				}
			}
			noBiometrics = false
		} else {
			print("no biometric auth possible")
			noBiometrics = true
			// no biometrics
		}
	}
}

class Ligands: ObservableObject {
	
	@Published var dataArray: [String] = []
	
	init() { self.load(file: "data") }
	
	func load(file: String) {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
