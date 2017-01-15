//
//  ViewController.swift
//  Travel Map
//
//  Created by Atıl Samancıoğlu on 12/12/2016.
//  Copyright © 2016 Atıl Samancıoğlu. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    var chosenLatitude : Double = 0
    var chosenLongitude : Double = 0
    
    var requestCLLoation = CLLocation()
    
    var transmittedTitle = ""
    var transmittedSubtitle = ""
    var transmittedLatitude : Double = 0
    var transmittedLongitude : Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.chooseLocation(gestureRecognizer:)))
        recognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(recognizer)
        
        if transmittedTitle != "" {
            
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: self.transmittedLatitude, longitude: self.transmittedLongitude)
            annotation.coordinate = coordinate
            annotation.title = self.transmittedTitle
            annotation.subtitle = self.transmittedSubtitle
            self.mapView.addAnnotation(annotation)
            
            self.titleText.text = self.transmittedTitle
            self.commentText.text = self.transmittedSubtitle
            
        }
        
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        self.mapView.setRegion(region, animated: true)
    }

    func chooseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
    
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            let chosenCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            let location = CLLocation(latitude: chosenCoordinates.latitude, longitude: chosenCoordinates.longitude)
            
            self.chosenLatitude = chosenCoordinates.latitude
            self.chosenLongitude = chosenCoordinates.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = chosenCoordinates
            annotation.title = self.titleText.text
            annotation.subtitle = self.commentText.text
            self.mapView.addAnnotation(annotation)
            
        }

    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "myAnnotation"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.pinTintColor = UIColor.red
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if self.transmittedLatitude != 0 {
            if self.transmittedLongitude != 0 {
                self.requestCLLoation = CLLocation(latitude: self.transmittedLatitude, longitude: self.transmittedLongitude)
            }
        }
     
        CLGeocoder().reverseGeocodeLocation(requestCLLoation, completionHandler: { (placemarks, error) in
            
            if let placemark = placemarks {
                if placemark.count > 0 {
                    let newPlaceMark = MKPlacemark(placemark: (placemarks?[0])!)
                    let item = MKMapItem(placemark: newPlaceMark)
                    item.name = self.transmittedTitle
                    
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                    
                }
            }
        
        })
        
        
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Locations", into: context)
        
        newLocation.setValue(self.titleText.text, forKey: "title")
        newLocation.setValue(self.commentText.text, forKey: "subtitle")
        newLocation.setValue(self.chosenLatitude, forKey: "latitude")
        newLocation.setValue(self.chosenLongitude, forKey: "longitude")
        
        do {
            
            try context.save()
            print("we saved finally!!!!")
            
        } catch {
            print("error")
        }
        
        
    }

}

