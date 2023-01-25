//
//  vcMapView.swift
//  favoritePlaces_rishivarma_c0880853
//
//  Created by RISHI VARMA on 2023-01-24.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class vcMapView :UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var zoomIn: UIButton!
    
    @IBOutlet weak var zoomOut: UIButton!
    
    @IBOutlet weak var search: UITextField!
    
    @IBOutlet weak var display: UILabel!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var locationManager: CLLocationManager!
    var destination1: CLLocationCoordinate2D!
    let geocoder = CLGeocoder()
    var selectedAnnotation: MKPointAnnotation?
    var pinnedAnnotations: Int = 0
    var delegate: ViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        map.delegate = self
        map.isZoomEnabled = false
        doubletap()
    }
    @IBAction func searchAddress(_ sender: UIButton) {
        let address = search.text!
        search.resignFirstResponder()
        let searchTerm = search.text!
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTerm
        request.region = map.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error != nil {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
            } else if response?.mapItems.count == 0 {
                print("No results found")
            } else {
                let firstResult = response!.mapItems[0]
                let annotation = MKPointAnnotation()
                annotation.coordinate = firstResult.placemark.coordinate
                annotation.title = firstResult.name
                self.map.addAnnotation(annotation)
                self.map.showAnnotations([annotation], animated: true)
            }
        }
    }
    
    @IBAction func zoomIn(_ sender: Any) {
        let span = MKCoordinateSpan(latitudeDelta: map.region.span.latitudeDelta*0.5, longitudeDelta: map.region.span.longitudeDelta*0.5)
        let region = MKCoordinateRegion(center: map.region.center, span: span)
        map.setRegion(region, animated: true)
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        let span = MKCoordinateSpan(latitudeDelta: map.region.span.latitudeDelta*2, longitudeDelta: map.region.span.longitudeDelta*2)
        let region = MKCoordinateRegion(center: map.region.center, span: span)
        map.setRegion(region, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0]
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        displayLocation(latitude: latitude, longitude: longitude)
    }
    
    func displayLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let latdelta: CLLocationDegrees = 0.05
        let lngdelta: CLLocationDegrees = 0.05
        let span = MKCoordinateSpan(latitudeDelta: latdelta, longitudeDelta: lngdelta)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer){
        pinnedAnnotations = map.annotations.count
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude), completionHandler: {(placemarks, error) in
            if self.pinnedAnnotations >= 1 {
                self.removePin()
            } else {
                DispatchQueue.main.async {
                    if let placeMark = placemarks?[0] {
                        if placeMark.locality != nil {
                            let place = Location(title:"",coordinate: coordinate)
                            if self.pinnedAnnotations < 1 {
                                self.map.addAnnotation(place)
                                self.addToFavorites(annotation: MKPointAnnotation())
                            }
                        }
                    }
                }
            }
        })
    }

    @objc func addToFavorites(annotation: MKPointAnnotation) {
            let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
                if error != nil {
                    print(error!)
                } else {
                    if let placemark = placemarks?[0] {
                        annotation.title = placemark.name
                        self.map.addAnnotation(annotation)
                    }
                }
            }
        }

    func getAddress(for location: CLLocationCoordinate2D) -> String? {
        let geocoder = CLGeocoder()
        var address: String?
        geocoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?.first {
                    address = self.getFormattedAddress(from: placemark)
                }
            } else {
                print("Error getting address: \(error!)")
            }
        }
        return address
    }
    func getFormattedAddress(from placemark: CLPlacemark) -> String {
        var address = ""
        if let street = placemark.thoroughfare {
            address += street + ", "
        }
        if let city = placemark.locality {
            address += city + ", "
        }
        if let state = placemark.administrativeArea {
            address += state + " "
        }
        if let postalCode = placemark.postalCode {
            address += postalCode + ", "
        }
        if let country = placemark.country {
            address += country
        }
        print(address)
        return address
        
    }

    func doubletap(){
        let double = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        double.numberOfTapsRequired = 2
        map.addGestureRecognizer(double)
    }
    
    @objc func removePin() {
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
    }

    @objc func removeAnnotation(point: UITapGestureRecognizer) {
        let pointTouched: CGPoint = point.location(in: map)
        let coordinate =  map.convert(pointTouched, toCoordinateFrom: map)
        let location: CLLocationCoordinate2D = coordinate
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), completionHandler: { (placemarks, error) in
            if error != nil {
                print(error!)
            }
        })
    }
}

extension vcMapView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let alert = UIAlertController(title: "Add to favorites", message: "Do you want to add this location to your favorites?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.selectedAnnotation = view.annotation as? MKPointAnnotation
            let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                let address = self?.getAddress(for: view.annotation!.coordinate)
                UserDefaults.standard.set(address, forKey: "favorite_address")
                self?.navigationController?.popViewController(animated: true)
            }
            alert.addAction(saveAction)
            present(alert, animated: true, completion: nil)
        }
    }
}
