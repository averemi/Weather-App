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

class DetailedInfoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    

    
    
    var selectedCity : WeatherDataModel?
    var forecastArray : [WeatherForecast]?
    let contextForecast = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let WEATHER_FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast"
    let APP_ID = "af1207b2373e5a3fbdef6c0151ad03af"

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var windLabel: UILabel!
    
    @IBOutlet weak var detailSectionView: UIView!
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityLabel.text = selectedCity?.city
        descriptionLabel.text = selectedCity?.descript
      //  String(cityItem.temperature) + "°"
        humidityLabel.text = String(selectedCity!.humidity) + "%"
        windLabel.text = String(selectedCity!.wind) + " km/h"
        tempLabel.text = String(selectedCity!.temperature) + "°"
        
       
     //   print("Current date is \(currentDateString)")
        
      //  let tomorrow = Date()
      //  Calendar.current.date(byAdding: day, to: <#T##Date#>)
        
        loadForecast()
        updateForecast()
        
        
        
        
     /*   let upperBorder = CALayer()
        let bottomBorder = CALayer()
        
        bottomBorder.frame = CGRectMake(0, forecastCollectionView.frame.height, forecastCollectionView.frame.width, 0.6)
        
        bottomBorder.backgroundColor = UIColor.white.cgColor

        
        upperBorder.frame = CGRectMake(0, 0, forecastCollectionView.frame.width, 0.6)
        
        upperBorder.backgroundColor = UIColor.white.cgColor
        forecastCollectionView.layer.addSublayer(upperBorder)
        forecastCollectionView.layer.upperBorder.addSublayer(bottomBorder)*/
        addUpperLayerToTheCollectionView(view: forecastCollectionView)
     //   addBottomLayerToTheView(view: detailSectionView)
    //    detailSectionView.layer.addSublayer(upperBorder)
        detailSectionView.backgroundColor = .clear
      //  forecastCollectionView.layer.borderColor = UIColor.black.cgColor
     //   forecastCollectionView.attribut
      //  forecastCollectionView.layer.borderWidth = 1
       // cell?.layer.borderColor = UIColor.blue.cgColor
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cityListBackground.jpg")!)
        forecastCollectionView.backgroundColor = .clear
        

        
    }
    
    func addUpperLayerToTheCollectionView(view: UICollectionView)
    {
        let bottomBorder = CALayer()
        
        bottomBorder.frame = CGRectMake(0, 0, view.frame.width, 0.6)
        
        bottomBorder.backgroundColor = UIColor.white.cgColor
        
        view.layer.addSublayer(bottomBorder)
    }
    
    
    func getDayOfWeek(increaseDayBy: Int) -> String {
        
        var dateComponents = DateComponents()
        dateComponents.setValue(increaseDayBy, for: .day); // +1 day
        
        let now = Date() // Current date
        let date = Calendar.current.date(byAdding: dateComponents, to: now)  // Add the DateComponents
        
      //  let date = getDayOfWeek(increaseDayBy: 1)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        
        dateFormatter.dateFormat = "EEEE"// + 1
        let dayOfWeekString: String = dateFormatter.string(from: date!)
        
        return dayOfWeekString
    }


    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (forecastArray?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = forecastCollectionView.dequeueReusableCell(withReuseIdentifier: "customForecastCell", for: indexPath) as! CustomForecastCell
        let forecastItem = forecastArray![indexPath.row]
        // tableView.backgroundColor = .clear
        cell.backgroundColor = .clear
        
        /*   if let color = FlatWhite().darken(byPercentage: CGFloat(indexPath.row) / CGFloat(citiesArray.count)) {
         cell.backgroundColor = color
         cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
         }*/
        
       //    cell.textLabel?.text = fore[indexPath.row]
        cell.temperatureLabel.text = String(forecastItem.temperature) + "°"
        cell.weatherIcon.image = UIImage(named: updateWeatherIcon(condition: Int(forecastItem.condition)))
        cell.dayOfWeek.text = forecastItem.dayOfWeek
      //  cell.temperatureLabel.text = String(cityItem.temperature) + "°"
        
        //       cell.weatherIcon.image = UIImage(named: citiesArray[indexPath.row].weatherIconName)
        
        return cell
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
        
        var dayForecast: Int = 0
        
        for eachThreeHours in stride(from: 0, to: 17, by: 8)  {
            
            let forecast = WeatherForecast(context: self.contextForecast)
            
            forecast.parentCity = cityWeatherInfo
            forecast.temperature = Int32(json["list"][eachThreeHours]["main"]["temp"].double! - 273.15)
            forecast.condition = Int32(json["list"][eachThreeHours]["weather"][0]["id"].intValue)
            
            
            
            forecastArray?[dayForecast].dayOfWeek = self.getDayOfWeek(increaseDayBy: dayForecast + 1)
           
            dayForecast = dayForecast + 1
            
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
            
            forecastArray?[dayForecast].dayOfWeek = self.getDayOfWeek(increaseDayBy: dayForecast + 1)
            
            dayForecast = dayForecast + 1
            
           
            
        }
         saveForecastInfo()

    }
    
    
  /*  func updateView() {
      //  print("TEMPERATURE:  \(selectedCity?.temperature)")
      //  print("CITY: \(selectedCity?.city)")
        /*print("TEMP1: \(forecastArray![0].temperature)")
        print("TEMP2: \(forecastArray![1].temperature)")
        print("TEMP3: \(forecastArray![2].temperature)")*/
        
        
    }*/
        
        
        func saveForecastInfo() {
            
            do {
                try contextForecast.save()
            } catch {
                print("Error saving context \(error)")
            }
            
            forecastCollectionView.reloadData()
            
        }
        
        
        func loadForecast() {
            
                
                let requestForecast : NSFetchRequest<WeatherForecast> = WeatherForecast.fetchRequest()
                do {
                    forecastArray = try contextForecast.fetch(requestForecast)
                } catch {
                    print("Error fetching data from contextForecast \(error)")
                }
            
            forecastCollectionView.reloadData()
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
