//
//  WeatherViewController.swift
//  Shahanaa_Arulanandan_FE_8967513
//
//  Created by user239837 on 4/7/24.
//

import UIKit
import CoreLocation
import CoreData

class WeatherViewController: UIViewController,CLLocationManagerDelegate {
    
    //connecting the lables and the image view
    @IBOutlet weak var cityTextLabel: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    //connecting the add button and creating the alert controller when it is clicked
    @IBAction func addButton(_ sender: Any) {
        let alert = UIAlertController(title: "Change City", message: "Enter the city name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "City Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak alert] (_) in
            if let textField = alert?.textFields?.first, let cityName = textField.text {
                self?.fetchweatherData(forCity: cityName)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    let apiKey = "53fad73944d454da8c0506e5244d51c6"
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    //getting the data from the openweather app
    func fetchweatherData(forCity cityName: String) {
        guard let urlEncodedCityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(urlEncodedCityName)&appid=\(apiKey)") else {
            print("Invalid city name")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("oops !!! Its an Error")
                return
            }
            
            guard let data = data else {
                return
            }
            
            self.parseWeatherData(data)
        }
        
        task.resume()
    }
    //getting the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        fetchWeatherData(for: location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("oops !!! Its an Error")
    }
    // Fetch the weather data
    func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
        guard let url = URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&exclude=hourly,daily&appid=\(self.apiKey)") else { return }
        
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching weather data: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error")
                return
            }
            guard let data = data else {
                print("Error decoding weather data:")
                return
            }
            self.parseWeatherData(data)
            
        }
        .resume()
    }
    
    //parse the weather data
    func parseWeatherData(_ data: Data) {
        do {
            let weatherData = try JSONDecoder().decode(Weather.self, from: data)
            updateUI(with: weatherData)
        } catch {
            print("Error")
        }
        
        
        
    }
    //fetch the weather Icon
    
    func fetchWeatherIcon(with iconCode: String, completion: @escaping (UIImage?) -> Void) {
        let imageUrlString = "https://api.openweathermap.org/img/w/\(iconCode).png"
        guard let url = URL(string: imageUrlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                completion(nil)
                return
            }
            
            completion(image)
        }
        
        task.resume()
    }
    //display the data through labels and image view
    func updateUI(with weatherData: Weather) {
        print("logging weather Data", weatherData);
        DispatchQueue.main.async {
            self.cityLabel.text = weatherData.name
            self.descriptionLabel.text = weatherData.weather.first?.description
            
            let temperatureInCelsius = weatherData.main.temp - 273.15
            self.temperatureLabel.text = "\(Int(temperatureInCelsius))°C"
            self.humidityLabel.text = "humidity: \(weatherData.main.humidity)%"
            self.windLabel.text = "Wind: \(Int(weatherData.wind.speed)) m/s"
            
            if let weatherIconCode = weatherData.weather.first?.icon {
                self.fetchWeatherIcon(with: weatherIconCode) {
                    image in DispatchQueue.main.async {
                        self.weatherImage.image = image
                    }
                }
            }
        }
    }
    // Function to save Data
    func saveWeatherData(weather: Weather) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "WeatherEntity", in: context)!
        let weatherObject = NSManagedObject(entity: entity, insertInto: context)
        
        weatherObject.setValue(weather.main.temp, forKey: "temperature")
        weatherObject.setValue(weather.name, forKey: "cityName")
        weatherObject.setValue(weather.wind, forKey: "wind")
        weatherObject.setValue(weather.main.humidity, forKey: "humidity")
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
   /* // Function to fetch Data
    func fetchWeatherData() -> [Weather] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WeatherEntity")
        
        do {
            let weatherObjects = try context.fetch(fetchRequest)
            return weatherObjects.map { Weather(temperature: $0.value(forKey: "temperature") as! Double, description: $0.value(forKey: "description") as! String) }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }*/
}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


