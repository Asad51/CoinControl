//
//  RecordsList.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 2/4/24.
//

import SwiftUI

struct RecordsList: View {
    let records: [Record]
    var dailyRecords: [String: [Record]] {
        Dictionary(grouping: records, by: { $0.date.formatted(date: .complete, time: .omitted) })
    }

    var body: some View {
        List {
            ForEach(dailyRecords.sorted(by: { $0.0 > $1.0 }), id: \.key) { date, records in
                Section {
                    ForEach(records.sorted(by: { $0.date > $1.date })) { record in
                        RecordRow(record: record)
                            .padding(.bottom, 30)
                    }
                } header: {
                    Text(date)
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        CoreDataPreview(\.records) { records in
            RecordsList(records: records)
        }
    }
#endif
