//
//  NewsTableViewController.swift
//  Shahanaa_Arulanandan_FE_8967513
//
//  Created by user239837 on 4/8/24.
//

import UIKit
import CoreLocation

class NewsTableViewController: UITableViewController,CLLocationManagerDelegate {
    
    var articles = [Article]()
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()  // Declare the geocoder here
  

        override func viewDidLoad() {
            super.viewDidLoad()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation() // Fetch initial data
            self.tableView.dataSource = self
            self.tableView.delegate = self
            

        }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("Location permission not granted")
        }
    }
     
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation() // Stop updates after the first location
            fetchCityAndNews(for: location)
        }
    }
    func fetchCityAndNews(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let placemark = placemarks?.first, let cityName = placemark.locality {
                print("Found city: \(cityName), updating news...")
                self?.fetchNewsForCity(cityName: cityName) { articles, error in
                    DispatchQueue.main.async {
                        if let articles = articles {
                            self?.articles = articles
                            self?.tableView.reloadData()
                        } else if let error = error {
                            print("Error fetching news: \(error)")
                        }
                    }
                }
            } else if let error = error {
                print("Error in reverse geocoding: \(error)")
            }
        }
    }

        // MARK: - Table view data source
        override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return articles.count
        }

        
        // MARK: - Fetching News
    func fetchNewsForCity(cityName: String, completion: @escaping ([Article]?, Error?) -> Void) {
        let apiKey = "85bae30ddc0740a5a3eb1d5dddfda59c"
        let urlString = "https://newsapi.org/v2/everything?q=\(cityName)&apiKey=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }

        // URLSession network request
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "Data not found", code: -2, userInfo: nil))
                return
            }
            
            // Parsing JSON Data
            do {
                let decoder = JSONDecoder()
                let newsResponse = try decoder.decode(News.self, from: data)
                completion(newsResponse.articles, nil)
            } catch let parsingError {
                completion(nil, parsingError)
            }
        }
        task.resume()
    }


        // MARK: - Change City
    
    @IBAction func changeCityButtonTapped(_ sender: Any) {
        // Define the `alert` within the scope of this function
           let alert = UIAlertController(title: "Where would you like to go", message: "Enter your new destination here", preferredStyle: .alert)

           // Add a text field to the alert for the city name
           alert.addTextField { textField in
               textField.placeholder = "City name"
           }
        // Your existing implementation of showing alert ...
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, unowned alert] _ in
            if let cityName = alert.textFields?.first?.text, !cityName.isEmpty {
                self?.fetchNewsForCity(cityName: cityName) { articles, error in
                    DispatchQueue.main.async {
                        if let articles = articles {
                            self?.articles = articles
                            self?.tableView.reloadData()
                        } else if let error = error {
                            print("Error: \(error)")
                            // Handle the error, perhaps show an alert to the user
                        }
                    }
                }
            }
        }
        alert.addAction(submitAction)
        present(alert, animated: true)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue a reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
        
        let article = articles[indexPath.row]
                cell.titleLabel.text = article.title
        //print("description",Optional(article.description)!);
        cell.descriptionField.text = article.description;
        // cell.descriptionField.sizeToFit()
               cell.authorLabel.text = article.author
      
             cell.sourceLabel.text = article.source.name// Assuming your Article model has these properties
           
           return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            // Return the desired height for the cells
            return 150 // Adjust this value according to your requirements
        }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
