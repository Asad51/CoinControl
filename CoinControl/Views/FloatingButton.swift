//
//  FloatingButton.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 10/2/24.
//

import SwiftUI

struct FloatingButton: View {
    private let systemImage: String
    private let action: () -> Void

    init(systemImage: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action, label: {
            Image(systemName: systemImage)
                .font(.system(size: 24))
                .foregroundStyle(.white)
        })
        .frame(width: 60, height: 60)
        .background(.red)
        .clipShape(Circle())
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    FloatingButton(systemImage: "plus") {
        print("pressed")
    }
}
