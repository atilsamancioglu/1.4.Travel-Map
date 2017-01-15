//
//  InitialVC.swift
//  Travel Map
//
//  Created by Atıl Samancıoğlu on 12/12/2016.
//  Copyright © 2016 Atıl Samancıoğlu. All rights reserved.
//

import UIKit
import CoreData

class InitialVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var titleArray = [String]()
    var subtitleArray = [String]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    
    var currentTitle = ""
    var currentSubtitle = ""
    var currentLatitude : Double = 0
    var currentLongitude : Double = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        fetchData()
    
    }
    
    func fetchData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Locations")
        request.returnsObjectsAsFaults = false
        
        do {
            
            let results = try context.fetch(request)
            
            if results.count > 0 {
                
                self.titleArray.removeAll(keepingCapacity: false)
                self.subtitleArray.removeAll(keepingCapacity: false)
                self.latitudeArray.removeAll(keepingCapacity: false)
                self.longitudeArray.removeAll(keepingCapacity: false)
                
                for result in results as! [NSManagedObject] {
                    
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    
                    if let subtitle = result.value(forKey: "subtitle") as? String {
                        self.subtitleArray.append(subtitle)
                    }
                    
                    if let latitude = result.value(forKey: "latitude") as? Double {
                        self.latitudeArray.append(latitude)
                    }
                    
                    if let longitude = result.value(forKey: "longitude") as? Double {
                        self.longitudeArray.append(longitude)
                    }
                    
                 self.tableView.reloadData()
                    
                }
            }
            
        } catch {
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentTitle = self.titleArray[indexPath.row]
        self.currentSubtitle = self.subtitleArray[indexPath.row]
        self.currentLatitude = self.latitudeArray[indexPath.row]
        self.currentLongitude = self.longitudeArray[indexPath.row]
        
        performSegue(withIdentifier: "toMapSegue", sender: nil)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapSegue" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.transmittedTitle = self.currentTitle
            destinationVC.transmittedSubtitle = self.currentSubtitle
            destinationVC.transmittedLatitude = self.currentLatitude
            destinationVC.transmittedLongitude = self.currentLongitude
        }
    }

    @IBAction func addButtonClicked(_ sender: Any) {
        
        performSegue(withIdentifier: "toMapSegue", sender: nil)
        
    }
    
}
