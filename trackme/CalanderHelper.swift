
import Foundation
import UIKit

class CalanderHelper {
    
    let calander = Calendar.current //.current based on machine so far as I could tell, will not track any changes made on user device.
    
    
    // ------------------------- Plus/Minus month calander function -------------------------
    
    // plus month by 1 month to date.
    func plusMonth(date: Date) -> Date {
        return calander.date(byAdding: .month, value: 1, to: date)!
    }
    
    // minus month by 1 month to date.
    func minusMonth(date: Date) -> Date {
        return calander.date(byAdding: .month, value: -1, to: date)!
    }
    
    // ------------------------- String Formatting -------------------------
    
    // Returns the day (e.g. -> 14) from the date
    func dayString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: date)
    }
    
    // Returns month from date in format LLLL - returning the month in text form
    // Example: input: 01.02.2021 -> output: February
    // Note for: 3 L's: Feb
    func monthString (date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    
    // Returns year from date as string of numbers
    // Example: input: 05.02.2021 -> output: "2021"
    func yearString (date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    func dayMonthYearString(date: Date) -> String {
        let day = dayString(date: date)
        let month = monthString(date: date)
        let year = yearString(date: date)
        let labelDateString = day + ". " + month + " " + year
        return labelDateString
    }
    
    // ------------------------- Date manipulation or calculations -------------------------

    // Range of smaller components (day(s)) in bigger component (month) for date
    // returns an int of how many dates are in current month based on the date in the parameter.
    // Example: input: xx.01.2021 -> output: 31
    func daysInMonth (date: Date) -> Int {
        let range = calander.range(of: .day, in: .month, for: date)!
        return range.count // get the count of elements in Range<Int> 
    }
    
    // Returns the number of the day of the date passed into the function
    // Example: input: 14.01.2021 -> output: 14
    func daysOfMonth (date: Date) -> Int {
        let components = calander.dateComponents([.day], from: date)
        return components.day!
    }
    
    // Gets component of the first date in the month of the date passed in and the return uses the components of the date to convert to the specific date.
    // Example: input: 15.01.2021 -> output: 01.01.2021
    func firstOfMonth (date: Date) -> Date {
        let components = calander.dateComponents([.year, .month], from: date)
        return calander.date(from: components)! // returns date from the date component
    }
 
    /*
     The weekday units are the numbers 1 through N (where for the Gregorian calendar N=7 and 1 is Sunday).
     So starting the week, we need to do -2 on the weekday.
     See loop in "CalanderViewController.setMonthView()"
     April 2021 example:
     1 <= 3
     2 <= 3
     3 <= 3
     --- Making it 3 blank spaces before we hit the first day of the week in april
     same with last days. We want 9 blank spaces after 30th of April.
     42 - 33 = 9.
     33 - 30 = 30
     */
    func weekDay (date: Date) -> Int {
        let components = calander.dateComponents([.weekday], from: date)
        return components.weekday! - 2
    }
    
    func findDatePressed(date: Date, dayNumber: Int) -> Date{
        var dateComponent = DateComponents()
        dateComponent.day = dayNumber - 1
        // Passing in the first day (1) of the month and the day number pressed, so we add them together after subtracting 1 from the dayNumber.
        if let calcDate = calander.date(byAdding: dateComponent, to: date) {
            return calcDate
        } else {
            return defaultDate()
        }
    }
    
    // ------------------------- Formatting for/from database -------------------------
    func formatForFirestore (date: Date) -> String {
        let dateStartOfDay = setDateStartOfDay(date: date) // Set the date to the first minute of the day, at midnight
        let formatter = DateFormatter()
        formatter.dateStyle = .short // Month/Day/Year: 6th of April 2021 -> 4/6/21
        let formattedDate = formatter.string(from: dateStartOfDay)
        return formattedDate
    }
    
    func formatFromFirestore (dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yy" // Setting the format of the String it will be receiving
        let date = formatter.date(from: dateString) // Converting into regular date ~ 4th of April 2021 printing: 2021-04-06 22:00:00 +0000 (swift timezone at UTC)
        let dateStartOfDay = setDateStartOfDay(date: date!) // In case some get through on a different minute, for example, those created manually.
        return dateStartOfDay
    }
    
    func setDateStartOfDay(date: Date) -> Date {
        return date.startOfDay
    }
    
    // Default date used in findDatePressed(Line 98 in this class)
    // Only intend to use this until a proper error check is in place.
    func defaultDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let date = formatter.date(from: "01/01/01")
        return date!
    }
        
    // ------------------------- Functions not needed / not in use -------------------------
    func prettyStringDateToString(dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd. LLLL yyyy"
        let date = formatter.date(from: dateString)
        let dateStartOfDay = setDateStartOfDay(date: date!)
        return dateStartOfDay
    }
}

    // ------------------------- Extension to date class -------------------------

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    // Currently not using endOfDay for anything
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
