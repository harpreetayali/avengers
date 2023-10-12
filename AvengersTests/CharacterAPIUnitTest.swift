//
//  CharacterAPIUnitTest.swift
//  AvengersTests
//
//  Created by Harpreet Singh on 07/10/23.
//

import XCTest
@testable import Avengers

final class CharacterAPIUnitTest: XCTestCase {

    override class func setUp() {
        super.setUp()
        
    }
    var viewModel = CharactersViewModel()
    
    func checkCharacterAPI(){
        viewModel.getCharacters(limit: "10", offset: "0", query: "a").sink { completion in
            
        } receiveValue: { model in
            XCTAssertNotNil(model)
        }

    }
}
