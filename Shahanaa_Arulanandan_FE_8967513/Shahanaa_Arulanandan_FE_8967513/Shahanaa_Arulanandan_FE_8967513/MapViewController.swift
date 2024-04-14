//
//  MapViewController.swift
//  Shahanaa_Arulanandan_FE_8967513
//
//  Created by user239837 on 4/8/24.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate , MKMapViewDelegate{
     
    //connecting the map
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
          var startAnnotation: MKPointAnnotation?
          var endAnnotation: MKPointAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
              locationManager.requestWhenInUseAuthorization()
              locationManager.desiredAccuracy = kCLLocationAccuracyBest
              locationManager.startUpdatingLocation()
                     mapView.delegate = self
                     mapView.showsUserLocation = true
    }
    enum TransportMode {
           case automobile
           case walking
           case transit // for bus
           case cycling
       }
      // connecting the buttons
       @IBAction func carButton(_ sender: Any) {
      
        showRoute(transportMode: .automobile)
       }
      
       @IBAction func bikeButton(_ sender: Any) {
          showRoute(transportMode: .cycling)
       }
      
       @IBAction func walkButton(_ sender: Any) {
       showRoute(transportMode: .walking)
       }
      
       @IBAction func busButton(_ sender: Any) {
        showRoute(transportMode: .transit)
       }
      
      
      
      //code for the Zooming with the slider and connecting the slider
       @IBAction func zoomChangeSlider(_ sender: UISlider) {
           let spanValue = max(0.005, 0.05 - (CGFloat(sender.value) * 0.005))
              
              let region = MKCoordinateRegion(center: mapView.centerCoordinate, span: MKCoordinateSpan(latitudeDelta: spanValue, longitudeDelta: spanValue))
              mapView.setRegion(region, animated: true)
       }
    //changing the location
       @IBAction func changeButton(_ sender: Any) {
           promptForLocations()
       }
       func promptForLocations() {
           //create alert controller
              let alert = UIAlertController(title: "Where would you like to go?", message: "Enter your Destination", preferredStyle: .alert)

              alert.addTextField { textField in
                  textField.placeholder = "Start location"
              }
          
              alert.addTextField { textField in
                  textField.placeholder = "End location"
              }
          
              alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
              alert.addAction(UIAlertAction(title: "Directions", style: .default) { [unowned self] _ in
                  let startTextField = alert.textFields![0]
                  let endTextField = alert.textFields![1]
                  //getting the start location and end location through the alert controller
                  if let startLocationName = startTextField.text, !startLocationName.isEmpty,
                     let endLocationName = endTextField.text, !endLocationName.isEmpty {
                      self.geocodeAddress(startLocationName, isStartLocation: true)
                      self.geocodeAddress(endLocationName, isStartLocation: false)
                  }
              })

              present(alert, animated: true)
          }
    // Geocodes an address string into a coordinate and marks it on the map.
    func geocodeAddress(_ address: String, isStartLocation: Bool) {
        CLGeocoder().geocodeAddressString(address) { [weak self] placemarks, error in
            guard let self = self, let placemark = placemarks?.first, let location = placemark.location else { return }
            DispatchQueue.main.async {
                if isStartLocation {
                    self.addAnnotation(at: location.coordinate, title: "Start Location", isStart: true)
                } else {
                    self.addAnnotation(at: location.coordinate, title: "End Location", isStart: false)
                }

                if let startAnnotation = self.startAnnotation, let endAnnotation = self.endAnnotation {
                    if startAnnotation.coordinate.latitude != 0, endAnnotation.coordinate.latitude != 0 {
                        self.showRoute(transportMode: .automobile) // Default to automobile for initial route
                    }
                }
            }
        }
    }
    // Adds an annotation to the map view at a specified coordinate with a given title.
          func addAnnotation(at coordinate: CLLocationCoordinate2D, title: String, isStart: Bool) {
              let annotation = MKPointAnnotation()
              annotation.coordinate = coordinate
              annotation.title = title

              if isStart {
                  if let existingAnnotation = startAnnotation {
                      mapView.removeAnnotation(existingAnnotation)
                  }
                  startAnnotation = annotation
              } else {
                  if let existingAnnotation = endAnnotation {
                      mapView.removeAnnotation(existingAnnotation)
                  }
                  endAnnotation = annotation
              }

              mapView.addAnnotation(annotation)
          }
    //changeing the mode of travelling 
          func showRoute(transportMode: TransportMode) {
              guard let startCoordinate = startAnnotation?.coordinate, let endCoordinate = endAnnotation?.coordinate else { return }

              let startPlacemark = MKPlacemark(coordinate: startCoordinate)
              let endPlacemark = MKPlacemark(coordinate: endCoordinate)

              let directionRequest = MKDirections.Request()
              directionRequest.source = MKMapItem(placemark: startPlacemark)
              directionRequest.destination = MKMapItem(placemark: endPlacemark)

              switch transportMode {
              case .automobile:
                  directionRequest.transportType = .automobile
              case .walking:
                  directionRequest.transportType = .walking
              case .transit:
                  directionRequest.transportType = .transit
              case .cycling:
                  // Note: MKDirections does not support cycling directly
                  directionRequest.transportType = .walking
              }

              let directions = MKDirections(request: directionRequest)
              directions.calculate { [weak self] (response, error) in
                  guard let self = self, let route = response?.routes.first else { return }
                  self.mapView.removeOverlays(self.mapView.overlays)
                  self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                  let rect = route.polyline.boundingMapRect
                  self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
              }
          }

          func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
              if let polyline = overlay as? MKPolyline {
                  let renderer = MKPolylineRenderer(polyline: polyline)
                  renderer.strokeColor = UIColor.blue
                  renderer.lineWidth = 5.0
                  return renderer
              }
              return MKOverlayRenderer()
          }

       func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           guard let location = locations.first else { return }
          
           // Set an initial location if none is set
           if startAnnotation == nil {
               addAnnotation(at: location.coordinate, title: "Current Location", isStart: true)
               let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
               mapView.setRegion(region, animated: true)
               mapView.showsUserLocation = true  // Optionally show also the blue dot for current location
           }
       }

       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           if status == .authorizedWhenInUse || status == .authorizedAlways {
               locationManager.startUpdatingLocation()
           } else {
               // Handle the case where location permissions are not granted
               print("Location permission not granted")
           }
       }
    ///
    //    /*
    //    // MARK: - Navigation
    //
    //    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        // Get the new view controller using segue.destination.
    //        // Pass the selected object to the new view controller.
    //    }
    //    */
    //
    //}
    }
