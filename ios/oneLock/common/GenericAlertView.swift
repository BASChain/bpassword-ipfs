//
//  GenericAlertView.swift
//  oneLock
//
//  Created by wesley on 2024/12/26.
//


import SwiftUI

struct GenericAlertView: View {
        @Binding var isPresented: Bool
        let title: String
        let message: String
        let onConfirm: () -> Void
        let onCancel: () -> Void
        
        var body: some View {
                if isPresented {
                        ZStack {
                                Color.black.opacity(0.4)
                                        .edgesIgnoringSafeArea(.all)
                                
                                VStack(spacing: 20) {
                                        Text(title)
                                                .font(.headline)
                                                .padding(.top)
                                        
                                        Text(message)
                                                .font(.body)
                                                .multilineTextAlignment(.center)
                                                .padding()
                                        
                                        HStack(spacing: 20) {
                                                Button(action: {
                                                        onCancel()
                                                        isPresented = false
                                                }) {
                                                        Text("Cancel")
                                                                .padding()
                                                                .frame(maxWidth: .infinity)
                                                                .background(Color.gray.opacity(0.2))
                                                                .cornerRadius(10)
                                                }
                                                
                                                Button(action: {
                                                        onConfirm()
                                                        isPresented = false
                                                }) {
                                                        Text("Confirm")
                                                                .padding()
                                                                .frame(maxWidth: .infinity)
                                                                .background(Color.blue)
                                                                .foregroundColor(.white)
                                                                .cornerRadius(10)
                                                }
                                        }
                                        .padding([.leading, .trailing, .bottom])
                                }
                                .background(Color.white)
                                .cornerRadius(20)
                                .padding()
                                .shadow(radius: 10)
                        }
                }
        }
}

extension View {
        func showAlert(
                isPresented: Binding<Bool>,
                title: String,
                message: String,
                onConfirm: @escaping () -> Void,
                onCancel: @escaping () -> Void
        ) -> some View {
                self.overlay(
                        GenericAlertView(
                                isPresented: isPresented,
                                title: title,
                                message: message,
                                onConfirm: onConfirm,
                                onCancel: onCancel
                        )
                )
        }
}
