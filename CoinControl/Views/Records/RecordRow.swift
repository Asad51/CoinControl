//
//  RecordRow.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 17/2/24.
//

import SwiftUI

struct RecordRow: View {
    let record: Record

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center, spacing: 0) {
                Text(record.category.name)
                    .font(.subheadline)
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .lineLimit(1)
                    .frame(width: proxy.size.width / 4, alignment: .leading)

                VStack(alignment: .leading) {
                    Text(record.note)
                        .font(.title2)
                        .lineLimit(1)

                    Text(record.account)
                        .font(.subheadline)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                }
                .frame(alignment: .leading)

                Spacer()

                Text(String(format: "$%.2f", record.amount))
                    .font(.title3)
                    .frame(alignment: .trailing)
            }
        }
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(\.record) { record in
            RecordRow(record: record)
        }
    }
#endif
