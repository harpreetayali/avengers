//
//  Encryption.swift
//  Avengers
//
//  Created by Harpreet Singh on 06/10/23.
//

import Foundation
import CryptoKit

class Encryption{
    static let shared = Encryption()
    
    func MD5(string: String) -> String {
        let hash = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
        return hash.map{
            String(format: "%02hhx", $0)
        }.joined()
    }
}
