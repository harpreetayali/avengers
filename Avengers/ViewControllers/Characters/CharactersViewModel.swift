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
    private var limit = "10"
    private var offset = 0
    var searchHistory:[String] {
        get {UserDefaults.standard.stringArray(forKey: Constants.SEARCH_HISTORY) ?? [] }
        set{UserDefaults.standard.setValue(newValue, forKey: Constants.SEARCH_HISTORY)}
    }
    func getCharacters(limit:String,offset:String,query:String = "") -> AnyPublisher<CharactersModel,Error>{

        return Future<CharactersModel,Error> {[weak self] promise in
            guard let weakSelf = self else { return }
            var params:[String:Any] = [String:Any]()
            params["limit"] = weakSelf.limit
            params["offset"] = weakSelf.offset
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
            }.store(in: &weakSelf.cancellables)
        }.eraseToAnyPublisher()
            
    }
    
    func saveHistory(query:String){
        var newHistory = searchHistory
        if !newHistory.contains(query){
            newHistory.append(query)
            self.searchHistory = newHistory
        }
    }
}
