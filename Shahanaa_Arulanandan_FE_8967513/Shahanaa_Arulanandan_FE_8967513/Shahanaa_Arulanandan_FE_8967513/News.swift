//
//  News.swift
//  Shahanaa_Arulanandan_FE_8967513
//
//  Created by user239837 on 4/8/24.
//

import Foundation
struct News: Codable {
    let articles: [Article]
}

struct Article: Codable {
    let title: String
    let description: String?
    let author: String?
    let source: Source
    let urlToImage: String?
    let publishedAt: String
    let content: String?
}

struct Source: Codable {
    let name: String
}
