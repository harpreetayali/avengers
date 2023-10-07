//
//  Extensions.swift
//  Avengers
//
//  Created by Harpreet Singh on 07/10/23.
//

import Foundation

extension Date{
    func formatDate(format:String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let formattedDate = dateFormatter.string(from: self)
        return formattedDate
    }
}
