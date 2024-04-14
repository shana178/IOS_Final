//
//  HistoryTableViewController.swift
//  Shahanaa_Arulanandan_FE_8967513
//
//  Created by user239837 on 4/12/24.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {

   /* // Sample history data
       var historyItems: [SearchHistory] = [
        SearchHistory(interactionType: .news, city: "Toronto", details: "Top story about local sports", date: Date()),
        SearchHistory(interactionType: .weather, city: "Vancouver", details: "27°C, Wind 11 km/h, Humidity 54%", date: Date()),
        SearchHistory(interactionType: .map, city: "Montreal", details: "Route from Point A to Point B - 120 km, Driving", date: nil),
        SearchHistory(interactionType: .home, city: "Calgary", details: "Accessed from Home Screen", date: nil),
        SearchHistory(interactionType: .weather, city: "Ottawa", details: "15°C, Wind 8 km/h, Humidity 30%", date: Date())
       ]
*/
       // MARK: - View Life Cycle
       override func viewDidLoad() {
           super.viewDidLoad()
           
           // Register the table view cell class and its reuse id
           tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
           
           // Set up navigation
           self.title = "Search History"
           navigationController?.navigationBar.prefersLargeTitles = true
       }

       // MARK: - Table view data source
/*
       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return historyItems.count
       }

       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
           let item = historyItems[indexPath.row]
           
           // Configure the cell
           var content = cell.defaultContentConfiguration()
           content.text = "\(item.interactionType.rawValue) - \(item.city)"
           content.secondaryText = "\(item.details)"
           if let date = item.date {
               let formatter = DateFormatter()
               formatter.dateStyle = .short
               formatter.timeStyle = .short
               content.secondaryText = "\(content.secondaryText ?? "") (\(formatter.string(from: date)))"
           }
           cell.contentConfiguration = content
           return cell
       }
       
       // Enable row deletion
       override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
       }
       
       override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               historyItems.remove(at: indexPath.row)
               tableView.deleteRows(at: [indexPath], with: .fade)
           }
       }
*/
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
