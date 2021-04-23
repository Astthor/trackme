//
//  DayViewController.swift
//  trackme
//
//  Created by Ástþór Bragason on 07/04/2021.
//

import UIKit

class DayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Updateable {
    
    // ------------------------- Variables -------------------------
    
    var fetchDate = Date() // From the CalanderVC, passed through segue, needs formatting to firestoreFetchDate to continue.
    var firestoreFetchDate = String() // Formatted to fit firebase String format for fetching from or inserting to firestore
    var parent_view_controller: CalanderViewController? = nil
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var expenseTableView: UITableView!
    
    
    // ------------------------- ViewDidLoad -------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fS.parent = self
        loadData()
        fS.startListener(fetchDate: firestoreFetchDate)
        expenseTableView.delegate = self
        expenseTableView.dataSource = self
    }
    
    // ------------------------- Table View DataSource Functions -------------------------
    
    // Getting the number of rows for the expense section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fS.expenses.count
    }
    
    // Setting reusable cell:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = expenseTableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath)
        cell.textLabel?.text = String(fS.expenses[indexPath.row].amount)
        return cell
    }

    // Swipe delete function:
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        fS.deleteExpense(index: indexPath.row)
        expenseTableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    // Finding index of selected item
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    
    // ------------------------- Load data, reload and segue prepare functions: -------------------------
    
    // We get fetchDate from segue, from which we set the dateLabel and load the data from after formatting fetchDate to match the type and dateFormat of the dates stored in firestore
    func loadData(){
        // set dateLabel:
        dateLabel.text = CalanderHelper().dayMonthYearString(date: fetchDate)
        firestoreFetchDate = CalanderHelper().formatForFirestore(date: fetchDate)
    }
    
    // Reload data:
    func update() {
        expenseTableView.reloadData()
    }
    
    // Segue :
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ExpenseViewController {
            if (segue.identifier == "updateCellSegue") {
                dest.currentIndex = expenseTableView.indexPathForSelectedRow?.row ?? 0 // else index is 0
            } else {
                dest.currentIndex = -1 // Meaning that we've used button "New Expense" and don't want to load data from fS.
            }
            dest.parent_vc = self
        }
        print("prepare is called: \(segue.destination.description)")
    }
    

    // ------------------------- UIActions: -------------------------
    @IBAction func newExpensePressed(_ sender: UIButton) {
        // Can't not have this function for the button due to the segue. 
    }
}
