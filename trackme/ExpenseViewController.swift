//
//  ExpenseViewController.swift
//  trackme
//
//  Created by Ástþór Bragason on 07/04/2021.
//

import UIKit

let fS = FirebaseService()

class ExpenseViewController: UIViewController, UITextViewDelegate {

    // ------------------------- Variables -------------------------
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveOrUpdateButton: UIButton!
    
    var placeHolderText = "Type any notes regarding this expense here. This can be helpful to keep track of what your main expenses are."
    var currentIndex = 0
    var parent_vc:DayViewController? = nil
    
    // ------------------------- ViewDidLoad -------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextView.delegate = self
        loadData()
    }
    
    // ------------------------- Setting load data -------------------------
    // loadData depends on whether we're loading from firestore or if user want's to create a new expense:
    func loadData(){
        if currentIndex >= 0 {
            print("Update called")
            setDataForUpdate()
        } else {
            setDataForNewExpense()
            print("New Expense button pressed.")
        }
    }
    
    // Setting the data and view for creating new expense
    func setDataForNewExpense() {
        dateLabel.text = parent_vc?.dateLabel.text
        amountTextField.placeholder = "Insert amount here"
        setNoteTextViewPlaceHolder()
        datePicker.date = CalanderHelper().formatFromFirestore(dateString: parent_vc!.firestoreFetchDate)
        setButton(title: "Save")
    }
    
    // Setting/Getting the data and view from firestore for updating data
    func setDataForUpdate(){
        dateLabel.text = parent_vc?.dateLabel.text
        amountTextField.text = String(fS.expenses[currentIndex].amount)
        noteTextView.text = fS.expenses[currentIndex].note
        datePicker.date = fS.expenses[currentIndex].date
        setButton(title: "Update")
    }
    
    // Changing the name of the button to give reassurance that the user is updating an excisting expense but not creating a new one
    func setButton(title: String) {
        saveOrUpdateButton.setTitle(title, for: .normal)
    }
    
    // ------------------------- UIActions -------------------------
    // Creating or Updating data in firestore using firestoreService:
    @IBAction func saveButton(_ sender: UIButton) {
        // Checks variables and then the current index to see if it's supposed to call updateExpense or addExpense
        if let amount = Double(amountTextField.text!){
            // Making sure that placeHolderText doesn't get saved in firestore
            if noteTextView.text == placeHolderText {
                noteTextView.text = ""
            }
            // Check if we can extract information from note, else save empty string (ideally change this later along with read functionality from firestore, so that we're not creating un-needed fields)
            if let note = noteTextView.text { // Currently not necessary but will need a similar check later (See comment at "else")
                if currentIndex >= 0 {
                    fS.updateExpense(index: currentIndex, amount: amount, date: datePicker.date, note: note)
                } else {
                    fS.addExpense(amount: amount, date: datePicker.date, note: note)
                }
            } else { // Plan: Customise check to not save the empty string, and create a func for handling an expense from firestore that doesn't have a note. 
                if currentIndex >= 0 {
                    fS.updateExpense(index: currentIndex, amount: amount, date: datePicker.date, note: "")
                } else {
                    fS.addExpense(amount: amount, date: datePicker.date, note: "")
                }
            }
        } else {
            print("Error with amount = Double(amountTextField.text) -- Create Alert pop up error handler for this later.")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // ----------------- Text View Placeholder functions -----------------
    func setNoteTextViewPlaceHolder(){
        if noteTextView.text == "" {
            noteTextView.text = placeHolderText
            noteTextView.textColor = UIColor.lightGray
        } else if noteTextView.text == placeHolderText {
            noteTextView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if noteTextView.textColor == UIColor.lightGray {
            noteTextView.text = nil
            noteTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if noteTextView.text.isEmpty {
            noteTextView.text = placeHolderText
            noteTextView.textColor = UIColor.lightGray
        }
    }
    
    

}
