//
//  ViewController.swift
//  Where Weather
//
//  Created by Alex Brown on 12/20/17.
//  Copyright © 2017 Alex Brown. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate ,WeatherDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    class CustomPointAnnotation: MKPointAnnotation {
        var imageName: String!
        var placedTime = Date()
    }
    
    let locationManager = CLLocationManager()
    let weatherData = WeatherData()
    var currentAnnotation = CustomPointAnnotation()
    
    var initialZoomIn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        weatherData.delegate = self
        mapView.delegate = self
        
        Timer.scheduledTimer(withTimeInterval: 55, repeats: true) { (_) in
            self.popOldPins()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func popOldPins(){       
        mapView.annotations.forEach { (annotation) in
            let pin = annotation as? CustomPointAnnotation
            if let placedTime = pin?.placedTime {
                let timeDifference = Date().timeIntervalSinceNow - placedTime.timeIntervalSinceNow
                if timeDifference > 600 { // 10 minutes
                    mapView.removeAnnotation(annotation)
                }
            }
        }
    }
    
    func getLocation(){
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 250
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func mapLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchLocation = sender.location(in: mapView)
            let mapLocation = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            
            UIImpactFeedbackGenerator().impactOccurred()
            
            weatherData.getWeatherData(latitude: mapLocation.latitude, longitude: mapLocation.longitude, isUserLocation: false)
        }
    }
    
    @IBAction func btnClearMap(_ sender: Any) {
        mapView.annotations.forEach { (_) in
            mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[locations.count - 1]
        weatherData.getWeatherData(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, isUserLocation: true)
        
        if initialZoomIn {
            initialZoomIn = false
            mapView.selectAnnotation(mapView.userLocation, animated: true)
            let currentLocation = locations[0]
            let viewRegion = MKCoordinateRegion.init(center: currentLocation.coordinate, latitudinalMeters: 100_000, longitudinalMeters: 100_000)
            self.mapView.setRegion(viewRegion, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        initialZoomIn = false
    }
    
    func reportWeatherLookupError() {
        DispatchQueue.main.sync {
            let alert = UIAlertController(title: "Failed to Get the Weather", message: "Unable to look up the weather. Try checking your internet connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func weatherResults(data: WeatherDetails, isUserLocation: Bool) {
        DispatchQueue.main.sync {
            let roundedTempF: Int = Int(round(data.main.temp))
            
            if isUserLocation {
                mapView.userLocation.title = "\(data.weather[0].main), \(roundedTempF)°F"
                mapView.userLocation.subtitle = "\(data.name) "
                
                if data.sys.country != nil {
                    for country in data.sys.country!.unicodeScalars {
                        mapView.userLocation.subtitle?.unicodeScalars.append(UnicodeScalar(127397 + country.value)!)
                    }
                }
                
                if mapView.userLocation.subtitle == " " {
                    mapView.userLocation.subtitle = ""
                }
                
            } else {
                let annotationPoint = CustomPointAnnotation()
                
                annotationPoint.coordinate = CLLocationCoordinate2D(latitude: data.coord.lat, longitude: data.coord.lon)
                annotationPoint.title = "\(data.weather[0].main), \(roundedTempF)°F"
                
                annotationPoint.subtitle = "\(data.name) "
                
                if data.sys.country != nil {
                    for country in data.sys.country!.unicodeScalars {
                        annotationPoint.subtitle?.unicodeScalars.append(UnicodeScalar(127397 + country.value)!)
                    }
                }
                
                if annotationPoint.subtitle == " " {
                    annotationPoint.subtitle = ""
                }
                
                annotationPoint.imageName = "\(data.weather[0].icon).png"
                
                currentAnnotation = annotationPoint
                
                self.mapView.addAnnotation(annotationPoint)
            }
        }
        
        func addNameAndTitle(){
            
        }
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "WhereWeather")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "WhereWeather")
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPointAnnotation
        annotationView?.image = UIImage(named: customPointAnnotation.imageName)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        mapView.selectAnnotation(currentAnnotation, animated: true)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        getLocation()
    }
}

