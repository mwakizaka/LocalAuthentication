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
        VStack {
            Button(action: {
                bitmetricAuthentication()
            }){
                Text("Authenticate with biometric")
            }
        }
        .padding()
    }
    
    func bitmetricAuthentication() {
        let context = LAContext()
        var error: NSError?
        let description: String = "Authenticate"
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: description, reply: {success, evaluateError in
                if (success) {
                    print("Succeeded to authenticate")
                } else {
                    print("Failed to authenticate")
                }
            })
        } else {
            let errorDescription = error?.userInfo["NSLocalizedDescription"] ?? ""
            print(errorDescription) // Biometry is not available on this device.
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
