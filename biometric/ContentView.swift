//
//  ContentView.swift
//  biometric
//
//  Created by mwakizaka on 2022/12/28.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @State private var showingAlert = false
    @State private var authenticationResult = "Unknown"
    var body: some View {
        VStack {
            Button(action: {
                bitmetricAuthentication(completion: self.toggleAuthenticationResult)
            }){
                Text("Authenticate with biometric")
            }
            .alert("Authentication Result", isPresented: $showingAlert, actions: {
                Button("OK"){
                    toggleAuthenticationResult(showAlert: false, authenticationResult: "Unknown")
                }
            }, message: {
                Text(authenticationResult)
            })
        }
        .padding()
    }
    
    func toggleAuthenticationResult(showAlert: Bool, authenticationResult: String) {
        if showAlert { // The order matters
            self.authenticationResult = authenticationResult
            self.showingAlert = showAlert
        } else {
            self.showingAlert = showAlert
            self.authenticationResult = authenticationResult
        }
    }
}

func bitmetricAuthentication(completion:@escaping (Bool, String)->()) {
    let context = LAContext()
    var error: NSError?
    let description: String = "Authenticate yourself"
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: description, reply: {success, evaluateError in
            if (success) {
                completion(true, "Succeeded")
            } else {
                let msg = "Failed: " + evaluateError!.localizedDescription + "\n error code: " + String(evaluateError!._code)
                completion(true, msg)
            }
        })
    } else {
        let msg = String(describing: error?.userInfo["NSLocalizedDescription"] ?? "")
        completion(true, msg)
    }
}

func supportBiometricAuthentication(biometryType: LABiometryType) -> (supported: Bool, errorMessage: String) {
    let context = LAContext()
    var error: NSError?
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        if (context.biometryType == biometryType) {
            return (true, "")
        } else {
            let names = ["None", "Touch ID", "Face ID"]
            let msg = String(names[biometryType.rawValue]) + " is not available"
            return (false, msg)
        }
    } else { // Biometry is not available on this device.
        let errorDescription = error?.userInfo["NSLocalizedDescription"] ?? ""
        return (false, String(describing: errorDescription))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
