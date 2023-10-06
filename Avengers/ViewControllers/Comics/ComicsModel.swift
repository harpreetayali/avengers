//
//  ComicsModel.swift
//  Avengers
//
//  Created by Harpreet Singh on 06/10/23.
//
import Foundation

// MARK: - ComicModel
struct ComicsModel: Codable {
    let data: ComicDataClass?
}

// MARK: - DataClass
struct ComicDataClass: Codable {
    let offset, limit, total, count: Int?
    let results: [ComicResult]?
}

// MARK: - Result
struct ComicResult: Codable {
    let id: Int?
    let title: String?
    let thumbnail: Thumbnail?

    enum CodingKeys: String, CodingKey {
        case id
        case title, thumbnail
    }
}
