//
//  FormRowStyle.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 19/4/26.
//

import SwiftUI

/// A reusable style component for form rows, creating the text visual and a custom underline.
struct FormRowStyle: View {
    let title: String
    let value: String // The currently selected value or placeholder
    var color: Color = .primary // For value text
    var hasContent: Bool // To determine line color (like the red underline on the Account in your image)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(value)
                .font(.body)
                .foregroundColor(hasContent ? color : .secondary) // Use secondary if it's a placeholder
                .lineLimit(1)

            // Custom line separator: colored if has content, otherwise gray.
            Rectangle()
                .fill(hasContent ? Color.red : Color(UIColor.tertiaryLabel))
                .frame(height: hasContent ? 2 : 1)
        }
        .padding(.vertical, 8)
    }
}
