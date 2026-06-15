//
//  URL+Extensions.swift
//  CoinControl
//

import Foundation

extension URL: @retroactive Identifiable {
    public var id: String {
        absoluteString
    }
}
