import Foundation

struct TransactionModel: Identifiable, Hashable {
    let id: UUID
    let amount: Double
    let date: Date
    let type: TransactionType
    let note: String
    let title: String
    let category: CategoryModel?
    let account: AccountModel?
}
