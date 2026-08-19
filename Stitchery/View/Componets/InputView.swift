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
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .foregroundStyle(isFocused ? Color.accentColor : Color.gray)
                .fontWeight(.semibold)
                .font(.footnote)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            Group {
                if isSecureField {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.system(size: 14))
            .focused($isFocused)
            .tint(Color.accentColor)
            
            Rectangle()
                .fill(isFocused ? Color.accentColor : Color.gray.opacity(0.4))
                .frame(height: isFocused ? 1.5 : 1)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "Email Address", placeholder: "testemail@gmail.com")
}
