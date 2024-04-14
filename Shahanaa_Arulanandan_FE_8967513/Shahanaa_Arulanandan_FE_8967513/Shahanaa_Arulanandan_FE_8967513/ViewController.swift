//
//  ViewController.swift
//  Shahanaa_Arulanandan_FE_8967513
//
//  Created by user239837 on 4/7/24.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    let locationManager = CLLocationManager()

    let apiKey = "53fad73944d454da8c0506e5244d51c6"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Create UIImageView instance
            let backgroundImageView = UIImageView(frame: view.bounds)
            backgroundImageView.image = UIImage(named: "Background")
            
            // Set content mode
            backgroundImageView.contentMode = .scaleAspectFill  // Or .scaleToFill as required

            // Add the image view to the view and send it to the back
            view.addSubview(backgroundImageView)
            view.sendSubviewToBack(backgroundImageView)
            
            // Add constraints (if using Auto Layout programmatically)
            backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
                backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])

               locationManager.delegate = self

               locationManager.requestWhenInUseAuthorization()

               locationManager.desiredAccuracy = kCLLocationAccuracyBest

               locationManager.startUpdatingLocation()

               

               mapView.delegate = self

               mapView.showsUserLocation = true

               mapView.userTrackingMode = .follow
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else {
                return
            }
            fetchWeatherData(for: location.coordinate)
        }
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to get user location: \(error.localizedDescription)")
        }
     
        func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
            guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)") else {
                return
            }
            let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                if let error = error {
                    print("Weather request error: \(error.localizedDescription)")
                    return
                }
                guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Invalid response or data")
                    return
                }
                self?.parseWeatherData(data)
            }
            task.resume()
        }
        func parseWeatherData(_ data: Data) {
            do {
                let decoder = JSONDecoder()
                let weatherData = try decoder.decode(Weather.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: weatherData)
                }
            } catch {
                print("Error decoding weather data: \(error)")
            }
        }
     
        func updateUI(with weatherData: Weather) {
            temperatureLabel.text = "\(Int(weatherData.main.temp - 273.15))°C"
            humidityLabel.text = "Humidity: \(weatherData.main.humidity)%"
            windLabel.text = "Wind: \(Int(weatherData.wind.speed)) m/s"
            guard let iconCode = weatherData.weather.first?.icon else { return }
            fetchWeatherIcon(with: iconCode) { image in
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
        func fetchWeatherIcon(with iconCode: String, completion: @escaping (UIImage?) -> Void) {
            let imageUrlString = "https://openweathermap.org/img/wn/\(iconCode).png"
            guard let url = URL(string: imageUrlString) else {
                completion(nil)
                return
            }
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil, let image = UIImage(data: data) else {
                    completion(nil)
                    return
                }
                completion(image)
            }
            task.resume()
        }
      }
    func fetchWeatherData() -> [Weather] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WeatherInfo")
        
        do {
            let weatherEntities = try context.fetch(fetchRequest)
            return weatherEntities.map { entity in
                // You need to construct your Weather model here
                let temp = entity.value(forKey: "temperature") as! Double
                let name = entity.value(forKey: "cityName") as! String

                // Assuming default values for other properties for simplicity
                return Weather(coord: Coord(lon: 0.0, lat: 0.0),
                               weather: [],
                               base: "",
                               main: Main(temp: temp, feelsLike: temp, tempMin: temp, tempMax: temp, pressure: 0, humidity: 0),
                               visibility: 0,
                               wind: Wind(speed: 0, deg: 0),
                               clouds: Clouds(all: 0),
                               dt: 0,
                               sys: Sys(type: 0, id: 0, country: "", sunrise: 0, sunset: 0),
                               timezone: 0, id: 0,
                               name: name,
                               cod: 0)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }


