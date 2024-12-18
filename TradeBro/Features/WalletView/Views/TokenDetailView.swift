////
////  TokenDetailView.swift
////  TradeBro
////
////  Created by Veronica Rudiuk on 09/11/2024.
////
//
//import Foundation
//
//private var sentToken: some View {
//        VStack {
//            TextField("Recipient Address", text: $viewModel.sentTokenToAddress)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//            TextField("Amount", text: $viewModel.sentTokenAmount)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//                .keyboardType(.numberPad)
//
//            Button(action: {
//                Task {
//                    await viewModel.sendSPLTokens()
//                }
//            }) {
//                Text("Send Tokens")
//                    .fontWeight(.bold)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//            .padding()
//        }
//        .padding()
//    }
