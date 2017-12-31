//
//  WeatherData.swift
//  Where Weather
//
//  Created by Alex Brown on 12/29/17.
//  Copyright © 2017 Alex Brown. All rights reserved.
//
import UIKit

protocol WeatherDelegate {
    func weatherResults(data : WeatherDetails)
}

struct WeatherDetails: Codable {

    let name: String
    let weather: [Weather]
    let main: Main
    let coord: Coord
    
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
}

class WeatherData{
    var delegate: WeatherDelegate? = nil
    init(){
    }

    func getWeatherData(latitude: Double, longitude: Double) {
        let apiKey = valueForAPIKey(named: "OPEN_WEATHER_MAP")
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                let result = try? JSONDecoder().decode(WeatherDetails.self, from: data) {
                self.delegate?.weatherResults(data: result)
            }
        }.resume()
    }
    
    //Just want to hide my keys, Xcode...
    //Code lifted straight from http://dev.iachieved.it/iachievedit/using-property-lists-for-api-keys-in-swift-applications/
    func valueForAPIKey(named keyname:String) -> String {
        // Credit to the original source for this technique at
        // http://blog.lazerwalker.com/blog/2014/05/14/handling-private-api-keys-in-open-source-ios-apps
        let filePath = Bundle.main.path(forResource: "ApiKeys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let value = plist?.object(forKey: keyname) as! String
        return value
    }
}
