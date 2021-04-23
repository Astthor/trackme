//
//  FirebaseService.swift
//  trackme
//
//  Created by Ástþór Bragason on 06/04/2021.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseService {
    
    // ------------------------- Variables -------------------------
    
    private var db = Firestore.firestore()
    var parent: Updateable?
    var expenses = [Expense]() //
    var expensesCollection = "expenses"
    
    
    // ------------------------- CRUD -------------------------
    
    func addExpense(amount: Double, date: Date, note: String) {
        let dateToString = CalanderHelper().formatForFirestore(date: date)
        if amount >= 0 {
            db.collection(expensesCollection).document().setData([
                "amount" : amount,
                "date" : dateToString,
                "note" : note
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Successfully written document")
                }
            }
        }
    }
    
    func updateExpense(index: Int, amount: Double, date: Date, note: String) {
        let dateToString = CalanderHelper().formatForFirestore(date: date)
        if amount >= 0 {
            db.collection(expensesCollection).document(expenses[index].id).setData([
                "amount" : amount,
                "date" : dateToString,
                "note" : note
            ]) {err in
                if let err = err {
                    print("Error updating document: \(self.expenses[index].id), \nError: \(err)")
                } else {
                    print("Update was A Okay")
                }
            }
        }
    }
    
    func deleteExpense (index: Int) {
        if index < expenses.count {
            let docID = expenses[index].id
            db.collection(expensesCollection).document(docID).delete(){ err in
                if let e = err {
                    print("Error deleting DocID: \(docID) \nError: \(e) ")
                } else {
                    print("Deleting successfull, DocID: \(docID)")
                }
            }
            expenses.remove(at: index)
        }
    }
    
    
    // ------------------------- Listener -------------------------
    
    func startListener(fetchDate: String){
        print("First line startListener with string: \(fetchDate)")
        db.collection("expenses").whereField("date", isEqualTo: fetchDate).addSnapshotListener { (snap, error) in
            if let e = error {
                print("error fetching data: \(e)")
            } else {
                //print("First inside else statement. ")
                if let s = snap {
                    //print("let s = snap is successful")
                    self.expenses.removeAll()
                    print("s.documents.count: \(s.documents.count)")
                    for doc in s.documents {
                        //print("Inside doc in s.documents")
                        //var newDate = Date()
                        guard let dateString = doc.data()["date"] as? String else {
                            print("ERROR: Date could not be set ")
                            return
                        }
                        guard let amount = doc.data()["amount"] as? Double else {
                            print("ERROR: Amount could not be set")
                            return
                        }
                        let date = CalanderHelper().formatFromFirestore(dateString: dateString)
                        if let note = doc.data()["note"] as? String {
                            let expense = Expense(id: doc.documentID, date: date, amount: amount, note: note)
                            self.expenses.append(expense)
                        } else {
                            let expense = Expense(id: doc.documentID, date: date, amount: amount, note: "")
                            self.expenses.append(expense)
                        }
                    }
                    self.parent?.update()
                }
            }
        }
    }
    
}
