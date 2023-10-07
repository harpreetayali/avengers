//
//  ComicsViewModel.swift
//  Avengers
//
//  Created by Harpreet Singh on 06/10/23.
//

import Foundation
import Combine
import Alamofire
import CryptoKit

class ComicsViewModel {
    
    private var cancellables = Set<AnyCancellable>()

    func getComics(limit:String,offset:String,dates:String)-> AnyPublisher<ComicsModel,Error>{

        return Future<ComicsModel,Error> { promise in
            var params:[String:Any] = [String:Any]()
            params["limit"] = limit
            params["offset"] = offset
            if !dates.isEmpty{
                params["dateRange"] = dates
            }
            let result = APIService.shared.sendRequest(endPoint: APIEndpoint.comicsList.url,
                                                       method: .get,
                                                       encoding: URLEncoding.queryString,
                                                       params: params,
                                                       type: ComicsModel.self)
            
            
            result.sink { completion in
                switch completion{
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    Constants.printToConsole("Finished")
                }
            } receiveValue: { [weak self] model in
                guard let weakSelf = self else { return }
                promise(.success(model))
            }.store(in: &self.cancellables)
        }.eraseToAnyPublisher()
        
    }
}
