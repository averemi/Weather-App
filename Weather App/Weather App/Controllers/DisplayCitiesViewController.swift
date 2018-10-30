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
    var forecastArray : [WeatherForecast] = [WeatherForecast]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "af1207b2373e5a3fbdef6c0151ad03af"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: "customCityCell")
        configureTableView()
        loadCityInfo()
        updateInitialCitiesInfo()
    }
    
    func configureTableView() {
        if let backgroundImage = UIImage(named: "cityListBackground.jpg") {
            self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        tableView.rowHeight = 100.0
    }
    
    //MARK: - Loading, Updating and Saving the Information
    /***************************************************************/
    
    func loadCityInfo() {
        let requestCurrentWeather: NSFetchRequest<WeatherDataModel> = WeatherDataModel.fetchRequest()
        
        do {
            citiesArray = try context.fetch(requestCurrentWeather)
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    func updateInitialCitiesInfo() {
        for cityWeather in citiesArray {
            if let cityName = cityWeather.city {
                let params: [String : String] = ["q": cityName, "appid": APP_ID]
                
                getWeatherData(url: WEATHER_URL, parameters: params, cityWeatherInfo: cityWeather, isNewCity: false)
            }
        }
    }
    
    func getWeatherData(url: String, parameters: [String: String], cityWeatherInfo: WeatherDataModel, isNewCity: Bool) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                let weatherJSON: JSON =  JSON(response.result.value!)

                if (!isNewCity) {
                    self.updateWeatherData(json: weatherJSON, with: cityWeatherInfo, with: isNewCity)
                } else {
                    let cityID = weatherJSON["id"].intValue
                    
                    if (self.filterCities(with: cityID)) {
                        let newCity = WeatherDataModel(context: self.context)
                        
                        self.updateWeatherData(json: weatherJSON, with: newCity, with: isNewCity)
                    }
                }
            } else {
                self.processErrors(errorMessage: "Internet connection problem")
            }
        }
    }
    
    func filterCities(with cityID: Int) -> Bool {
        for city in citiesArray {
            if city.id == cityID {
                return false
            }
        }
        return true
    }
    
    func processErrors(errorMessage: String) {
        let myAlert = UIAlertController(title: "Alert", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func updateWeatherData(json: JSON, with cityWeatherInfo: WeatherDataModel, with isNewCity: Bool) {
        let city = json["name"].stringValue
        
        if city != "" {
            let tempResult = json["main"]["temp"].doubleValue

            cityWeatherInfo.temperature = Int32(tempResult - 273.15)
            cityWeatherInfo.city = city
            cityWeatherInfo.humidity = json["main"]["humidity"].int32Value
            cityWeatherInfo.wind = json["wind"]["speed"].int32Value
            cityWeatherInfo.id = json["id"].int64Value
            cityWeatherInfo.descript = json["weather"][0]["description"].stringValue
            if (isNewCity) {
                cityWeatherInfo.forecastDataAvailable = false
                citiesArray.append(cityWeatherInfo)
            }
            saveCityInfo()
        } else {
            processErrors(errorMessage: "city not found")
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
    
    //MARK: - Performing Segues
    /***************************************************************/
    
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
            }
        }
    }
    
    //MARK: - Adding New City
    /***************************************************************/
    
    func userAddedANewCityName(city: String) {
        let newCity = WeatherDataModel()
        let params: [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params, cityWeatherInfo: newCity, isNewCity: true)
    }
    
    //MARK: - TableView Methods
    /***************************************************************/

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCityCell", for: indexPath) as! CustomCityCell
        let cityItem = citiesArray[indexPath.row]
        
        cell.backgroundColor = .clear
        cell.cityLabel.text = cityItem.city
        cell.temperatureLabel.text = String(cityItem.temperature) + "°"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDetailedInfo", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            context.delete(citiesArray[indexPath.row])
            citiesArray.remove(at: indexPath.row)
            saveCityInfo()
        }
    }
}
