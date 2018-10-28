//
//  ViewController.swift
//  Weather App
//
//  Created by Anastasia Veremiichyk on 10/26/18.
//  Copyright © 2018 Anastasia Veremiichyk. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class DisplayCitiesViewController: UITableViewController, AddCityDelegate {
    
    var citiesArray : [WeatherDataModel] = [WeatherDataModel]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "af1207b2373e5a3fbdef6c0151ad03af"
    let cellInfo = CustomCityCell()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: "customCityCell")
  //      createInitialCitiesList()
        loadCityInfo()
        
    }

/*
    func createInitialCitiesList() {
        for city in itemArray {
            let params : [String : String] = ["q" : city, "appid" : APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }*/
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cellInfo.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {
        
        if let tempResult = json["main"]["temp"].double {
            
            
            
            let cityWeatherInfo = WeatherDataModel(context: self.context)
            
            cityWeatherInfo.temperature = Int32(tempResult - 273.15)
            
            cityWeatherInfo.city = json["name"].stringValue
            
            cityWeatherInfo.condition = Int32(json["weather"][0]["id"].intValue)
            
            cityWeatherInfo.weatherIconName = ""
            
      //      cityWeatherInfo.weatherIconName = cityWeatherInfo.updateWeatherIcon(condition: cityWeatherInfo.condition)
            
            citiesArray.append(cityWeatherInfo)
            saveCityInfo()
        }
        else {
            cellInfo.cityLabel.text = "Weather Unavailable"
        }
    }
    
    func saveCityInfo() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    func loadCityInfo() {
        let request : NSFetchRequest<WeatherDataModel> = WeatherDataModel.fetchRequest()
        do {
            citiesArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    func userAddedANewCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)

    }
    
    
    // MARK - TableView DataSource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCityCell", for: indexPath) as! CustomCityCell
        let cityItem = citiesArray[indexPath.row]
        
     //   cell.textLabel?.text = itemArray[indexPath.row]
        cell.cityLabel.text = cityItem.city
        cell.temperatureLabel.text = String(cityItem.temperature) + "°"
        
 //       cell.weatherIcon.image = UIImage(named: citiesArray[indexPath.row].weatherIconName)
        
        return cell
    }
    
    // MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(itemArray[indexPath.row])
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK - Add New Cities
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addCitySegue" {
            
            let destinationVC = segue.destination as! AddCityViewController
            
            destinationVC.delegate = self
            
        }
    }
    
    func updateWeatherIcon(condition: Int) -> String {
        
        switch (condition) {
            
        case 0...300 :
            return "tstorm1"
            
        case 301...500 :
            return "light_rain"
            
        case 501...600 :
            return "shower3"
            
        case 601...700 :
            return "snow4"
            
        case 701...771 :
            return "fog"
            
        case 772...799 :
            return "tstorm3"
            
        case 800 :
            return "sunny"
            
        case 801...804 :
            return "cloudy2"
            
        case 900...903, 905...1000  :
            return "tstorm3"
            
        case 903 :
            return "snow5"
            
        case 904 :
            return "sunny"
            
        default :
            return "dunno"
        }
    }
    
    
}

