//
//  RenameAlertView.swift
//  SwiftUILegandLogger
//
//  Created by Laura Hart on 5/16/24.
//

import SwiftUI

struct RenameAlertView: View {
    @Binding var userInput: String
    @Binding var isPresented: Bool
    var onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter New Title:")
            TextField("New Title", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Button("Save") {
                    hideKeyboard()
                    onSave()
                    isPresented = false
                }
                Button("Cancel") {
                    hideKeyboard()
                    isPresented = false
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(40)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
