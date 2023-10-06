//
//  Constants.swift
//  Avengers
//
//  Created by Harpreet Singh on 06/10/23.
//

import Foundation

struct Constants {
    static let PUBLIC_API_KEY = "c3a3c1e94d0e1c91dc1a19b85f1f305e"
    static let PRIVATE_API_KEY = "a66d299615fe0d2db92c0561b62bb63cd0f2ac10"
    
    static let SEARCH_HISTORY = "SearchHistory"
    static func printToConsole(_ val:Any){
        #if DEBUG
        print(val)
        #endif
    }
}
