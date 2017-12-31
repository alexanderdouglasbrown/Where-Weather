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
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    class CustomPointAnnotation: MKPointAnnotation {
        var imageName: String!
    }
    
    let locationManager = CLLocationManager()
    let weatherData = WeatherData()
    
    var initialZoomIn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        weatherData.delegate = self
        mapView.delegate = self
        
        infoViewBottomConstraint.constant = infoView.frame.height
        infoView.layer.cornerRadius = 15
        infoView.layer.masksToBounds = true
        getLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func getLocation(){
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 250
        locationManager.startUpdatingLocation()
        
    }
    @IBAction func tapGesture(_ sender: Any) {
        closeInfoPane()
    }
    
    @IBAction func mapLongPress(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == .began){
            let touchLocation = sender.location(in: mapView)
            let mapLocation = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            
            UIImpactFeedbackGenerator().impactOccurred()
            
            weatherData.getWeatherData(latitude: mapLocation.latitude, longitude: mapLocation.longitude)
        }
    }
    
    func openInfoPane(){
        DispatchQueue.main.async {
            self.infoViewBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func closeInfoPane(){
        infoViewBottomConstraint.constant = infoView.frame.height
        UIView.animate(withDuration: 0.4 , animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (initialZoomIn){
            initialZoomIn = false
            //Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) {_ in
            let currentLocation = locations[locations.count - 1]
            let viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 100_000, 100_000)
            self.mapView.setRegion(viewRegion, animated: false)
            
            //self.weatherData.getWeatherData(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            //   }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        initialZoomIn = false
    }
    
    func weatherResults(data: WeatherDetails) {
        DispatchQueue.main.async {
            let tempK: Double = data.main.temp
            let tempF: Double = ((9.0/5.0)*(tempK - 273.0) + 32.0)
            let roundedTempF: Int = Int(round(tempF))
            
//            self.cityLabel.text = data.name
//            self.conditionLabel.text = data.weather[0].main
//            self.tempLabel.text = "\(roundedTempF)"
            
            let annotationPoint = CustomPointAnnotation()
            
            annotationPoint.coordinate = CLLocationCoordinate2D(latitude: data.coord.lat, longitude: data.coord.lon)
            annotationPoint.title = "\(data.weather[0].main), \(roundedTempF)°F"
            annotationPoint.subtitle = "\(data.name)"
            annotationPoint.imageName = "\(data.weather[0].icon).png"
            
            self.mapView.addAnnotation(annotationPoint)
            
            //self.openInfoPane()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation){
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "WhereWeather")
        if (annotationView == nil){
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
        mapView.selectAnnotation(mapView.annotations[mapView.annotations.endIndex - 1], animated: true)
    }
    
}

