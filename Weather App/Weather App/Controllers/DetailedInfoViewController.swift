//
//  DetailedInfoViewController.swift
//  Weather App
//
//  Created by Anastasia Veremiichyk on 10/28/18.
//  Copyright © 2018 Anastasia Veremiichyk. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

class DetailedInfoViewController: UIViewController {
    
    var selectedCity : WeatherDataModel?
    var forecastArray : [WeatherForecast]?
    let contextForecast = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let WEATHER_FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast"
    let APP_ID = "af1207b2373e5a3fbdef6c0151ad03af"

    @IBOutlet weak var tempLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadForecast()
        updateForecast()
        
     //   print(selectedCity!.city)
      //  print()
        
        
    /*    if let city = selectedCity {
       //     self.title = city.city
        //    if let
            tempLabel.text = String(city.temperature) + "°"
            
            loadForecast()
        }*/
        
    }
    
    func updateForecast() {
        
        if let city = selectedCity {
            let params : [String : String] = ["q" : city.city!, "appid" : APP_ID]
                getWeatherForecast(url: WEATHER_FORECAST_URL, parameters: params, cityWeatherInfo: city)
            
        }
    }
    
    func getWeatherForecast(url: String, parameters: [String: String], cityWeatherInfo: WeatherDataModel) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON : JSON =  JSON(response.result.value!)
                if cityWeatherInfo.forecastDataAvailable == false {
                    self.createWeatherForecast(json: weatherJSON, with: cityWeatherInfo)
                    cityWeatherInfo.forecastDataAvailable = true
                    
                }
                else {
                    self.updateWeatherForecast(json: weatherJSON, with: cityWeatherInfo)
                }
            } else {
                print("Error \(String(describing: response.result.error))")
              //  self.cellInfo.cityLabel.text = "Connection Issues"
            }
    }
    }
    
    func createWeatherForecast(json : JSON, with cityWeatherInfo : WeatherDataModel) {
        
        
        for eachThreeHours in stride(from: 0, to: 17, by: 8)  {
            
            let forecast = WeatherForecast(context: self.contextForecast)
            
            forecast.parentCity = cityWeatherInfo
            forecast.temperature = Int32(json["list"][eachThreeHours]["main"]["temp"].double! - 273.15)
            forecast.condition = Int32(json["list"][eachThreeHours]["weather"][0]["id"].intValue)
            
            print(forecast.parentCity?.city)
            print(forecast.temperature)
            print(forecast.condition)
            
            forecastArray?.append(forecast)
            
            
            
        }
        saveForecastInfo()
    }
    
    func updateWeatherForecast(json : JSON, with cityWeatherInfo : WeatherDataModel) {
        
        var dayForecast: Int = 0
        
        
        for eachThreeHours in stride(from: 0, to: 17, by: 8)  {
            

            forecastArray?[dayForecast].temperature = Int32(json["list"][eachThreeHours]["main"]["temp"].double! - 273.15)
            forecastArray?[dayForecast].condition = Int32(json["list"][eachThreeHours]["weather"][0]["id"].intValue)
            
            dayForecast = dayForecast + 1
            
   //         print(forecast.parentCity?.city)
   //         print(forecast.temperature)
     //       print(forecast.condition)
            
     //       forecastArray?.append(forecast)
            
           
            
        }
         saveForecastInfo()
        /*      cityWeatherInfo.dayOneTemp = Int32(json["list"][0]["main"]["temp"].double! - 273.15)
         cityWeatherInfo.dayOneCond = Int32(json["list"][0]["weather"][0]["id"].intValue)
         cityWeatherInfo.dayTwoTemp = Int32(json["list"][8]["main"]["temp"].double! - 273.15)
         cityWeatherInfo.dayTwoCond = Int32(json["list"][8]["weather"][0]["id"].intValue)
         cityWeatherInfo.dayThreeTemp = Int32(json["list"][16]["main"]["temp"].double! - 273.15)
         cityWeatherInfo.dayThreeCond = Int32(json["list"][16]["weather"][0]["id"].intValue)
         
         print(cityWeatherInfo.dayOneTemp)
         print(cityWeatherInfo.dayOneCond)
         print(cityWeatherInfo.dayTwoTemp)
         print(cityWeatherInfo.dayTwoCond)
         print(cityWeatherInfo.dayTwoTemp)
         print(cityWeatherInfo.dayTwoCond)*/
        
        /*
         else {
         //  cellInfo.cityLabel.text = "Weather Unavailable"
         }*/
    }
    
    
    func updateView() {
        print("TEMPERATURE:  \(selectedCity?.temperature)")
        print("CITY: \(selectedCity?.city)")
        print("TEMP1: \(forecastArray![0].temperature)")
        print("TEMP2: \(forecastArray![1].temperature)")
        print("TEMP3: \(forecastArray![2].temperature)")
        
        
    }
        
        
        func saveForecastInfo() {
            
            do {
                try contextForecast.save()
            } catch {
                print("Error saving context \(error)")
            }
            
            updateView()
            
        }
        
        
        func loadForecast() {
            
                
                let requestForecast : NSFetchRequest<WeatherForecast> = WeatherForecast.fetchRequest()
                do {
                    forecastArray = try contextForecast.fetch(requestForecast)
                } catch {
                    print("Error fetching data from contextForecast \(error)")
                }
            
            updateView()
         /*   let request : NSFetchRequest<WeatherDataModel> = WeatherDataModel.fetchRequest()
            do {
                citiesArray = try context.fetch(request)
            } catch {
                print("Error fetching data from context \(error)")
            }*/
        }

    
    
    
    

    

}
