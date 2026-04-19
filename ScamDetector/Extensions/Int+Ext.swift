//
//  Int+Ext.swift
//  ScamDetector
//
//  Created by Kevin Issac on 19/04/26.
//

import Foundation

extension Int {
    func pluralized(_ word: String) -> String {
        self == 1 ? "\(self) \(word)" : "\(self) \(word)s"
    }
}
