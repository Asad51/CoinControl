import Foundation

struct AccountModel: Identifiable, Hashable {
    let id: UUID
    let name: String
    let type: AccountType
}
