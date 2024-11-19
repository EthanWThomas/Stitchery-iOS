//
//  InputView.swift
//  Stitchery
//
//  Created by Ethan Thomas on 11/14/24.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    
    let title: String
    let placeholder: String
    
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundStyle(Color.gray)
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 14))
//                    .padding()
//                    .frame(height: 50)
//                    .background(
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(Color.buttons)
//                            .stroke(Color.gray)
//                            .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
//                    )
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 14))
//                    .frame(height: 50)
//                    .background(
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(Color.buttons)
//                            .stroke(Color.gray)
//                            .shadow(color: .primary.opacity(0.15), radius: 10, x: 0, y: 0)
//                    )
                
            }
            Divider()
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "testemail@gmail.com")
}
