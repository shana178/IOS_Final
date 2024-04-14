//
//  SearchHistory.swift
//  Shahanaa_Arulanandan_FE_8967513
//
//  Created by user239837 on 4/12/24.
//

import Foundation

enum InteractionType: String {
    case home = "Home"
    case news = "News"
    case weather = "WeatherInfo"
    case map = "Map"
}

struct SearchHistory {
    var city: String
    var source: InteractionType
    var newsContent: String? // Used only if type is news
    var weatherData: (date: Date, temperature: Double, humidity: Double, windSpeed: Double)?
    var mapData: (startPoint: String, endPoint: String, travelMode: String, distance: Double)?
}

