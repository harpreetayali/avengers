//
//  APIEndpoints.swift
//  Avengers
//
//  Created by Harpreet Singh on 06/10/23.
//

import Foundation

enum APIEndpoint{
    
    private var baseUrl: String{
       return "https://gateway.marvel.com:443/"
    }
    
    case characteresList
    case comicsList
    
    var url:String{
        switch self {
        case .characteresList:
            return "\(baseUrl)v1/public/characters"
        case .comicsList:
            return "\(baseUrl)v1/public/comics"
        }
    }
}
