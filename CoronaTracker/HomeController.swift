//
//  HomeController.swift
//  CoronaTracker
//
//  Created by Swapnanil Dhol on 3/22/20.
//  Copyright © 2020 Swapnanil Dhol. All rights reserved.
//

import UIKit

class HomeController: UITableViewController, UISearchResultsUpdating
 {
    
    var coronaData = [Location]()
    let activityView = UIActivityIndicatorView(style: .large)
    let fadeView = UIView()
    let searchController = UISearchController()
    var filteredLocation = [Location]()
    let feedbackGen = UIImpactFeedbackGenerator()
    var cases = 0
    var deaths = 0
    var recovered = 0
    let pullToRefresh = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Countries"
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        pullToRefresh.addTarget(self, action: #selector(apiRequest), for: .allEvents)
        self.tableView.refreshControl = pullToRefresh
        
        addActivity()
        apiRequest()
    }
    
    fileprivate func addActivity() {
        
        fadeView.frame = self.view.frame
        fadeView.backgroundColor = .systemBackground
        fadeView.alpha = 1.0
        self.view.addSubview(fadeView)
        
        self.view.addSubview(activityView)
        activityView.hidesWhenStopped = true
        activityView.center = self.view.center
        activityView.startAnimating()
    }
    
    
    
    @objc fileprivate func apiRequest() {
        
        guard let url = URL(string: "https://coronavirus-tracker-api.herokuapp.com/v2/locations") else {return}
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do
            {
                let newData = try JSONDecoder().decode(CoronaModel.self, from: data!)
                
                self.deaths = newData.latest.deaths
                self.cases = newData.latest.confirmed
                self.recovered = newData.latest.recovered
                
                for locations in newData.locations {
                    
                    self.coronaData.append(locations)
                }
                
            }
            catch {
                print("Error ho gaya", error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.feedbackGen.impactOccurred(intensity: 0.7)
                self.tableView.reloadData()
                self.pullToRefresh.endRefreshing()
                self.fadeView.removeFromSuperview()
                self.activityView.stopAnimating()
            }
            
        
        }.resume()
    }
    
    
    
    func flag(from country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.uppercased().unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
    
}

extension HomeController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering() {
            return 1
        }
        else {
            return 2
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        
        switch section {
            
        case 0:
            if isFiltering() {
                
                return filteredLocation.count
            }
            else {
                return 1
            }
        case 1:
            if isFiltering() {
                return 0
            }
            else {
               return self.coronaData.count
            }
        default:
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CoronaCell
        
        
        if !isFiltering() {
        
        if indexPath.section == 1
        {
            let acro: Location
        if isFiltering() {
            acro = filteredLocation[indexPath.row]
        } else {
            acro = coronaData[indexPath.row]
        }
        
        let countryEmoji = flag(from: acro.country_code)
        cell.countryName.text = countryEmoji + " " + acro.country + acro.province
        cell.totalCases.text = "  👾 \(acro.latest.confirmed)  "
        cell.totalDeaths.text = "  💔 \(acro.latest.deaths)  "
        cell.recovered.text = "  💚 \(acro.latest.recovered)  "

        
        cell.totalCases.layer.masksToBounds = true
        cell.totalDeaths.layer.masksToBounds = true
        cell.recovered.layer.masksToBounds = true
        
        cell.totalCases.layer.cornerRadius = 4
        cell.totalDeaths.layer.cornerRadius = 4
        cell.recovered.layer.cornerRadius = 4
            
            }
        else {
                
            cell.countryName.text = " 🌍 Mother Earth"
            cell.totalCases.text = "  👾 \(self.deaths)  "
            cell.totalDeaths.text = "  💔 \(self.deaths)  "
            cell.recovered.text = "  💚 \(self.recovered)  "

                
                cell.totalCases.layer.masksToBounds = true
                cell.totalDeaths.layer.masksToBounds = true
                cell.recovered.layer.masksToBounds = true
                
                cell.totalCases.layer.cornerRadius = 4
                cell.totalDeaths.layer.cornerRadius = 4
                cell.recovered.layer.cornerRadius = 4
            }
        
        return cell
    }
        else {
            
            if indexPath.section == 0
            {
                let acro: Location
            if isFiltering() {
                acro = filteredLocation[indexPath.row]
            } else {
                acro = coronaData[indexPath.row]
            }
            
            let countryEmoji = flag(from: acro.country_code)
            cell.countryName.text = countryEmoji + " " + acro.country
            cell.totalCases.text = "  👾 \(acro.latest.confirmed)  "
            cell.totalDeaths.text = "  💔 \(acro.latest.deaths)  "
            cell.recovered.text = "  💚 \(acro.latest.recovered)  "

            
            cell.totalCases.layer.masksToBounds = true
            cell.totalDeaths.layer.masksToBounds = true
            cell.recovered.layer.masksToBounds = true
            
            cell.totalCases.layer.cornerRadius = 4
            cell.totalDeaths.layer.cornerRadius = 4
            cell.recovered.layer.cornerRadius = 4
                
            }
            return cell
        }
    }
        
    
    func updateSearchResults(for searchController: UISearchController) {
           filterContentForSearchText(searchController.searchBar.text!)
       }
       
       func searchBarIsEmpty() -> Bool {
           return searchController.searchBar.text?.isEmpty ?? true
       }
       
       func filterContentForSearchText(_ searchText: String, scope: String = "All") {
           filteredLocation = coronaData.filter({( allColor : Location) -> Bool in
               return allColor.country.lowercased().contains(searchText.lowercased())
           })
           
           tableView.reloadData()
       }
       func isFiltering() -> Bool {
           return searchController.isActive && !searchBarIsEmpty()
       }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            if isFiltering() {
                return nil
            }
            else {
                return "World-Wide Cases"
            }
        case 1:
            if isFiltering() {
                return nil
            }
            else {
                return "Cases by countries"
            }
        default:
            return nil
        }
    }
}


class CoronaCell: UITableViewCell {
    
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var totalCases: UILabel!
    @IBOutlet weak var totalDeaths: UILabel!
    @IBOutlet weak var recovered: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

