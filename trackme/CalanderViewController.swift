//
//  CalanderViewController.swift
//  trackme
//
//  Created by Ástþór Bragason on 06/04/2021.
//

import UIKit

class CalanderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    //------------------ Variables ------------------

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    
    var selectedDate = Date()
    var totalSquares = [String]()
    var firstOfMonth = Date()
    
    //------------------ View Did Load ------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCellsView()
        setMonthView()
    }
    

    //------------------------- Load data -------------------------
    
    // Setting the cell layout and size
    func setCellsView() {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 8
        
        /*
         Flow layout, cells from one row will flow to the next with each row containing as many cells as will fit.
         ATTENTION - TESTING HERE
         dividing by 8, will fit 7 cells in the row. if we divide by 7 it will fill a bit more into the screen.
         
         CGSize is a structure - widht and height.
         */
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
        
    }
    
    // Setting the collectionview layout in regards to what month it is
    func setMonthView() {
        totalSquares.removeAll()
        
        let daysInMonth = CalanderHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalanderHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalanderHelper().weekDay(date: firstDayOfMonth)
        firstOfMonth = CalanderHelper().firstOfMonth(date: selectedDate)
        
        var count: Int = 1
        while count <= 42 {
            if (count <= startingSpaces || count - startingSpaces > daysInMonth) {
                totalSquares.append("")
            } else {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        monthLabel.text = CalanderHelper().monthString(date: selectedDate) + " " + CalanderHelper().yearString(date: selectedDate)

        collectionView.reloadData()
    }
    
    // ------------------------- Collection View DataSource functions -------------------------
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // cell set as the reusable cell and as object of CalanderCell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalanderCell
        //cell.dayOfMonth.text = totalSquares[indexPath.item]
        
        //cell.changeButtonTitle(day: totalSquares[indexPath.item])
        if !totalSquares[indexPath.item].isEmpty{
            cell.dayOfMonth.text = totalSquares[indexPath.item]
            //cell.layer.borderWidth = 1
        } else {
            cell.dayOfMonth.text = ""
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if totalSquares[indexPath.item] != "" { // Checking if it's a date or an empty slot
            performSegue(withIdentifier: "daySegue", sender: totalSquares[indexPath.item])
        }
    }
    
    // ------------------------- UIActions: -------------------------
    @IBAction func previousMonth(_ sender: UIButton) {
        selectedDate = CalanderHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func nextMonth(_ sender: UIButton) {
        selectedDate = CalanderHelper().plusMonth(date: selectedDate)
        setMonthView()
    }
    
    // Autorotate set to false
    override open var shouldAutorotate: Bool {
        return false
    }
    
    // ------------------------- Segue preperation -------------------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? DayViewController {
            if let indexP = collectionView.indexPathsForSelectedItems?.first?.row {
                dest.fetchDate = CalanderHelper().findDatePressed(date: firstOfMonth,
                                                                  dayNumber: Int(totalSquares[indexP])!)
            }
        }
    }
}
