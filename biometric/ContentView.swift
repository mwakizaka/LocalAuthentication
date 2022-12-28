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
                bitmetricAuthentication()
            }){
                Text("Authenticate with biometric")
            }
            .alert("Authentication Result", isPresented: $showingAlert, actions: {
                Button("OK"){
                    print("triggered: " + authenticationResult)
                    showingAlert = false
                    authenticationResult = "Unknown"
                }
            }, message: {
                Text(authenticationResult)
            })
        }
        .padding()
    }
        
    func bitmetricAuthentication() {
        let context = LAContext()
        var error: NSError?
        let description: String = "Authenticate yourself"
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: description, reply: {success, evaluateError in
                if (success) {
                    self.authenticationResult = "Succeeded"
                    self.showingAlert = true
                } else {
                    self.authenticationResult = "Failed: " + evaluateError!.localizedDescription + "\n error code: " + String(evaluateError!._code)
                    self.showingAlert = true
                }
            })
        } else {
            let errorDescription = error?.userInfo["NSLocalizedDescription"] ?? ""
            self.authenticationResult = String(describing: errorDescription)
            print(errorDescription) // Biometry is not available on this device.
            self.showingAlert = true
        }
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
