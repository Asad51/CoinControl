//
//  CoreDataPreview.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 14/2/24.
//

import CoreData
import SwiftUI

struct CoreDataPreview<Content: View, PersistenceModel: Hashable>: View {
    private let content: Content

    init(item keyPath: KeyPath<PreviewData, (NSManagedObjectContext) -> PersistenceModel>, @ViewBuilder content: (PersistenceModel) -> Content) {
        let data = PreviewData()
        let closure = data[keyPath: keyPath]
        let item = closure(PersistenceController.preview.viewContext)

        self.content = content(item)
    }

    init(items keyPath: KeyPath<PreviewData, (NSManagedObjectContext) -> [PersistenceModel]>, @ViewBuilder content: ([PersistenceModel]) -> Content) {
        let data = PreviewData()
        let closure = data[keyPath: keyPath]
        let items = closure(PersistenceController.preview.viewContext)

        self.content = content(items)
    }

    var body: some View {
        content
            .environmentObject(Settings())
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
