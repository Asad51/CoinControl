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
                .font(.system(size: 25))
                .foregroundStyle(.white)
        })
        .frame(width: 60, height: 60)
        .background(.red)
        .clipShape(Circle())
        .shadow(radius: 10)
    }
}

#Preview {
    FloatingButton(systemImage: "plus") {
        print("pressed")
    }
}
