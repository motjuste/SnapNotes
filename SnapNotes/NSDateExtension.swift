import Foundation

extension NSDate {
    var calendar: NSCalendar {
        return NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    }
    
    func after(value: Int, calendarUnit:NSCalendarUnit) -> NSDate{
        return calendar.dateByAddingUnit(calendarUnit, value: value, toDate: self, options: NSCalendarOptions(0))!
    }

    func minus(date: NSDate) -> NSDateComponents{
        return calendar.components(NSCalendarUnit.CalendarUnitMinute, fromDate: self, toDate: date, options: NSCalendarOptions(0))
    }
    
    func equalsTo(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedSame
    }

    func greaterThan(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedDescending
    }

    func lessThan(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedAscending
    }

    
    class func parse(dateString: String, format: String = "yyyy-MM-dd HH:mm:ss") -> NSDate{
        var formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.dateFromString(dateString)!
    }

    func toString(format: String = "yyyy-MM-dd HH:mm:ss") -> String{
        var formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
}