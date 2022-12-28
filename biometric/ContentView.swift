//
//  ContentView.swift
//  biometric
//
//  Created by mwakizaka on 2022/12/28.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    var body: some View {
        BiometricAuthenticationButton(biometryType: LABiometryType.touchID)
    }
}

struct BiometricAuthenticationButton: View {
    @State private var showingAlert = false
    @State private var authenticationResult = "Unknown"
    private let biometryNames = ["None", "Touch ID", "Face ID"]
    var biometryType: LABiometryType
    var body: some View {
        VStack {
            Button(action: {
                let (supported, msg) = supportBiometricAuthentication(biometryName: biometryNames[biometryType.rawValue], biometryType: biometryType)
                if supported {
                    bitmetricAuthentication(completion: toggleAuthenticationResult)
                } else {
                    toggleAuthenticationResult(showAlert: true, authenticationResult: msg)
                }
            }){
                Text("Authenticate with " + biometryNames[biometryType.rawValue])
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
    let description: String = "Authenticate yourself"
    context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: description, reply: {success, evaluateError in
        if (success) {
            completion(true, "Succeeded")
        } else {
            let msg = "Failed: " + evaluateError!.localizedDescription + "\n error code: " + String(evaluateError!._code)
            completion(true, msg)
        }
    })
}

func supportBiometricAuthentication(biometryName: String, biometryType: LABiometryType) -> (supported: Bool, errorMessage: String) {
    let context = LAContext()
    var error: NSError?
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        if (context.biometryType == biometryType) {
            return (true, "")
        } else {
            return (false, biometryName + " is not available")
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
