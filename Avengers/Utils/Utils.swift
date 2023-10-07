//
//  Utils.swift
//  Avengers
//
//  Created by Harpreet Singh on 07/10/23.
//

import Foundation

struct Utils {
   static func getFirstDayOfWeek() -> Date? {
        let calendar = Calendar.current
        let today = Date()
        
        let currentWeekday = calendar.component(.weekday, from: today)
        
        let daysToSubtract = currentWeekday - calendar.firstWeekday
        
        if let firstDayOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) {
            return firstDayOfWeek
        }
        
        return nil
    }
    static func getPreviousWeekDates() -> (startDate: Date, endDate: Date)? {
        let calendar = Calendar.current
        let today = Date()
        
        let currentWeekday = calendar.component(.weekday, from: today)
        
        let daysToSubtract = currentWeekday + 6
        
        if let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: today), let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) {
            return (startDate: startDate, endDate: endDate)
        }
        
        return nil
    }
    
    static func getNextWeekDates() -> (startDate: Date, endDate: Date)? {
        let calendar = Calendar.current
        let today = Date()
        
        let currentWeekday = calendar.component(.weekday, from: today)
        
        let daysToAdd = 8 - currentWeekday
        
        if let startDate = calendar.date(byAdding: .day, value: daysToAdd, to: today), let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) {
            return (startDate: startDate, endDate: endDate)
        }
    
        return nil
    }
    static func getStartOfMonth() -> Date? {
        let calendar = Calendar.current
        let today = Date()
        
        // Get the year and month components of the current date
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        
        // Create a DateComponents object for the first day of the month
        var firstDayComponents = DateComponents()
        firstDayComponents.year = year
        firstDayComponents.month = month
        firstDayComponents.day = 1
        
        if let startOfMonth = calendar.date(from: firstDayComponents) {
            return startOfMonth
        }
        return nil
    }
}
