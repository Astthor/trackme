//
//  Expense.swift
//  trackme
//
//  Created by Ástþór Bragason on 06/04/2021.
//

import Foundation

class Expense {
    var id: String
    var date: Date
    var amount: Double
    var note: String
    
    init(id: String, date: Date, amount: Double, note: String) {
        self.id = id
        self.date = date
        self.amount = amount
        self.note = note
    }
}
