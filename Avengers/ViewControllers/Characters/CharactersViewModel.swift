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

    func getCharacters(limit:String,offset:String,query:String = "") -> AnyPublisher<CharactersModel,Error>{

        return Future<CharactersModel,Error> { promise in
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
                    promise(.failure(error))
                case .finished:
                    Constants.printToConsole("Finished")
                }
            } receiveValue: { model in
                promise(.success(model))
            }.store(in: &self.cancellables)
        }.eraseToAnyPublisher()
            
    }
}
