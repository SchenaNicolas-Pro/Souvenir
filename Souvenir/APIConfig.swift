//
//  APIConfig.swift
//  Souvenir
//
//  Created by Nicolas Schena on 08/12/2022.
//

import Foundation

struct APIConfig {
    static var ninjasAPIKey: String {
        Bundle.main.infoDictionary?["NINJAS_API_KEY"] as? String ?? ""
    }

    static var fixerAPIKey: String {
        Bundle.main.infoDictionary?["FIXER_API_KEY"] as? String ?? ""
    }

    static var openWeatherAPIKey: String {
        Bundle.main.infoDictionary?["OPENWEATHER_API_KEY"] as? String ?? ""
    }

    static var deeplAPIKey: String {
        Bundle.main.infoDictionary?["DEEPL_API_KEY"] as? String ?? ""
    }
}
