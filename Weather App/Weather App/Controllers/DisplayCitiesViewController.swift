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
import ChameleonFramework

class DisplayCitiesViewController: UITableViewController, AddCityDelegate {
    
    var citiesArray : [WeatherDataModel] = [WeatherDataModel]()
    var forecastArray : [WeatherForecast] = [WeatherForecast]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "af1207b2373e5a3fbdef6c0151ad03af"
    let cellInfo = CustomCityCell()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //    print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        tableView.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: "customCityCell")
        
        tableView.rowHeight = 100.0
        
        
     //   tableView.separatorStyle = .none
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cityListBackground.jpg")!)
        
     //   setStatusBarBackgroundColor()
        loadCityInfo()
        updateInitialCitiesInfo()
        
        
    }
    
  


    func updateInitialCitiesInfo() {
        
        for city in citiesArray {
            if let cityName = city.city {
                let params : [String : String] = ["q" : cityName, "appid" : APP_ID]
                getWeatherData(url: WEATHER_URL, parameters: params, cityWeatherInfo: city, isNewCity: false)
             //   getWeatherForecast(url: WEATHER_FORECAST_URL, parameters: params, cityWeatherInfo: city, isNewCity: false)
                
            }
        }
    }

    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url: String, parameters: [String: String], cityWeatherInfo: WeatherDataModel, isNewCity: Bool) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON : JSON =  JSON(response.result.value!)
              //  print(weatherJSON)
                if (!isNewCity) {
                    self.updateWeatherData(json: weatherJSON, with: cityWeatherInfo, with: isNewCity)
                } else {
                    let cityID = Int64(weatherJSON["id"].intValue)
                    if (self.filterCities(cityID: Int(cityID))) {
                        let cityWeatherInfo = WeatherDataModel(context: self.context)
                        self.updateWeatherData(json: weatherJSON, with: cityWeatherInfo, with: isNewCity)
                        
                }
            }
            } else {
                print("Error \(String(describing: response.result.error))")
                self.cellInfo.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    
    //Write the updateWeatherData method here:
        func updateWeatherData(json : JSON, with cityWeatherInfo : WeatherDataModel, with isNewCity: Bool) {
        
        if let tempResult = json["main"]["temp"].double {
            
            
            
        //    let cityWeatherInfo = WeatherDataModel(context: self.context)
            
            cityWeatherInfo.temperature = Int32(tempResult - 273.15)
            
            cityWeatherInfo.city = json["name"].stringValue
            
            cityWeatherInfo.condition = Int32(json["weather"][0]["id"].intValue)
            
            cityWeatherInfo.weatherIconName = ""
            
            cityWeatherInfo.humidity = Int32(json["main"]["humidity"].intValue)
            
            cityWeatherInfo.wind = Int32(json["wind"]["speed"].intValue)
            
            cityWeatherInfo.id = Int64(json["id"].intValue)
            
            cityWeatherInfo.descript = json["weather"][0]["description"].stringValue
            
            
            
            if (isNewCity) {
                cityWeatherInfo.forecastDataAvailable = false
                citiesArray.append(cityWeatherInfo)
            }
            saveCityInfo()
            
      //      cityWeatherInfo.weatherIconName = cityWeatherInfo.updateWeatherIcon(condition: cityWeatherInfo.condition)
            
        }
        else {
          //  cellInfo.cityLabel.text = "Weather Unavailable"
        }
    }
    
    func filterCities(cityID : Int) -> Bool {
        print(cityID)
        for city in citiesArray {
            if city.id == cityID {
                return false
            }
        }
        return true
        
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
        let requestCurrentWeather : NSFetchRequest<WeatherDataModel> = WeatherDataModel.fetchRequest()
        do {
            citiesArray = try context.fetch(requestCurrentWeather)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
    }
    
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    func userAddedANewCityName(city: String) {
        
        let newCity = WeatherDataModel()
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params, cityWeatherInfo: newCity, isNewCity: true)

    }
    
    
    // MARK - TableView DataSource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCityCell", for: indexPath) as! CustomCityCell
        let cityItem = citiesArray[indexPath.row]
       // tableView.backgroundColor = .clear
        cell.backgroundColor = .clear
        
     /*   if let color = FlatWhite().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(citiesArray.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }*/
        
     //   cell.textLabel?.text = itemArray[indexPath.row]
        cell.cityLabel.text = cityItem.city
        cell.temperatureLabel.text = String(cityItem.temperature) + "°"
        
 //       cell.weatherIcon.image = UIImage(named: citiesArray[indexPath.row].weatherIconName)
        
        return cell
    }
    
    // MARK: TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToDetailedInfo", sender: self)
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            context.delete(citiesArray[indexPath.row])
            citiesArray.remove(at: indexPath.row)
        //    citiesArray[indexPath.row].forecast
            saveCityInfo()
         //   for forecast in forecastArray {
         //       print(forecast)
         //   }
        }
    }
    
    // MARK - Add New Cities
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "addCitySegue" {
            
            let destinationVC = segue.destination as! AddCityViewController
            
            destinationVC.delegate = self
            
        }
        
        else if segue.identifier == "goToDetailedInfo" {
            
            let destinationVC = segue.destination as! DetailedInfoViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                
                destinationVC.selectedCity = citiesArray[indexPath.row]
            
                destinationVC.forecastArray = forecastArray
            
           //     destinationVC.delegate = self
            }
        }
    }
    
    
}

