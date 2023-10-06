//
//  CharactersViewModel.swift
//  Avengers
//
//  Created by Harpreet Singh on 06/10/23.
//

import Foundation
import Combine
import Alamofire
import CryptoKit

class CharactersViewModel {
    
    private var cancellables = Set<AnyCancellable>()
    @Published var characters:CharactersModel?

    func getCharacters(limit:String,offset:String,query:String = ""){

        var params:[String:Any] = [String:Any]()
        params["limit"] = limit
        params["offset"] = offset
        if !query.isEmpty{
            params["nameStartsWith"] = query
        }
        let result = APIService.shared.sendRequest(endPoint: APIEndpoint.characteresList.url,
                                                   method: .get,
                                                   encoding: URLEncoding.queryString,
                                                   params: params,
                                                   type: CharactersModel.self)
        
        result.sink { completion in
            switch completion{
            case .failure(let error):
                Constants.printToConsole("Error --> \(error)")
            case .finished:
                Constants.printToConsole("Finished")
            }
        } receiveValue: { [weak self] model in
            guard let weakSelf = self else { return }
            weakSelf.characters = model
        }.store(in: &cancellables)

    }
}
