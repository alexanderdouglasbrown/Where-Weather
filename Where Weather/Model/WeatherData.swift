//
//  WeatherData.swift
//  Where Weather
//
//  Created by Alex Brown on 12/29/17.
//  Copyright © 2017 Alex Brown. All rights reserved.
//
import UIKit

protocol WeatherDelegate {
    func weatherResults(data : WeatherDetails, isUserLocation: Bool)
    func reportWeatherLookupError()
}

struct WeatherDetails: Codable {

    let name: String
    let weather: [Weather]
    let main: Main
    let coord: Coord
    let sys: Sys
    
    struct Weather: Codable {
        let main: String
        let description: String
        let icon: String
    }
    
    struct Main: Codable {
        let temp: Double
    }
    
    struct Coord: Codable {
        let lon: Double
        let lat: Double
    }
    
    struct Sys: Codable {
        let country: String?
    }
}

class WeatherData{
    var delegate: WeatherDelegate? = nil
    init(){
    }

    
/* Environment Variables article:
     https://medium.com/@derrickho_28266/xcode-custom-environment-variables-681b5b8674ec
     */
    func getWeatherData(latitude: Double, longitude: Double, isUserLocation: Bool) {
        let apiKey = ProcessInfo.processInfo.environment["OPEN_WEATHER_MAP"]!
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=imperial")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.delegate?.reportWeatherLookupError()
                return
            }
            
            if let data = data {
                if let result = try? JSONDecoder().decode(WeatherDetails.self, from: data) {
                    self.delegate?.weatherResults(data: result, isUserLocation: isUserLocation)
                } else {
                    self.delegate?.reportWeatherLookupError()
                }
            }
        }.resume()
    }
}
