//
//  BottomSheet.swift
//  oneLock
//
//  Created by wesley on 2025/3/2.
//


import SwiftUI

struct BottomSheet: View {
        @Binding var show: Bool
        @Binding var autoCloseDuration: Int
        
        var body: some View {
                if show {
                        VStack {
                                Spacer()
                                VStack(spacing: 0) {
                                        HStack {
                                                Text("Auto close Wallet Duration")
                                                        .font(.headline)
                                                        .padding()
                                                Spacer()
                                                Button(action: {
                                                        show = false
                                                }) {
                                                        Image("close").padding()
                                                }
                                        }
                                        .background(Color.white)
                                        
                                        Divider()
                                        
                                        ForEach([1, 5, 10, 15, 30, 60], id: \ .self) { value in
                                                HStack {
                                                        Text("\(value) Mins")
                                                                .font(.body)
                                                                .padding()
                                                        Spacer()
                                                        if value == autoCloseDuration {
                                                                Image("checked_icon")
                                                        }
                                                }
                                                .background(Color.white)
                                                .onTapGesture {
                                                        changeCloseDuration(value:value)
                                                }
                                                Divider()
                                        }
                                }
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(radius: 10)
                        }
                        .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: show)
                }
        }
        
        private func changeCloseDuration(value:Int){
                
                autoCloseDuration = value
                do{
                        try SdkUtil.shared.setAutoCloseDuration(value)
                        SdkUtil.shared.toastManager?.showToast(message: "Save Success!", isSuccess: true)
                        show = false
                }catch{
                        SdkUtil.shared.toastManager?.showToast(message: "Save Failed!", isSuccess: false)
                }
        }
}
