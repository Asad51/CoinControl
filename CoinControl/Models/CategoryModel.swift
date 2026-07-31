import Foundation

struct CategoryModel: Identifiable, Hashable {
    let id: UUID
    let name: String
    let icon: String
    let type: TransactionType
}
