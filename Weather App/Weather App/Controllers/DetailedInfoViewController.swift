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
    var contextForecast = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let WEATHER_FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast"
    let APP_ID = "af1207b2373e5a3fbdef6c0151ad03af"
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var upperViewContainer: UIView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var detailSectionView: UIView!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpWeatherDetailView()
        loadForecast()
        updateForecast()
    }
    
    //MARK: - Setting Up Weather Detail View
    /***************************************************************/
    
    func setUpWeatherDetailView() {
        cityLabel.text = selectedCity?.city
        descriptionLabel.text = selectedCity?.descript
        humidityLabel.text = String(selectedCity!.humidity) + "%"
        windLabel.text = String(selectedCity!.wind) + " km/h"
        tempLabel.text = String(selectedCity!.temperature) + "°"
        addBottomLayerToView(view: detailSectionView)
        detailSectionView.backgroundColor = .clear
        upperViewContainer.backgroundColor = .clear
        forecastCollectionView.backgroundColor = .clear
        if let backgroundImage = UIImage(named: "cityListBackground.jpg") {
            self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
    }
    
    func addBottomLayerToView(view: UIView) {
        let bottomBorder = CALayer()
        
        bottomBorder.frame = CGRectMake(0, view.frame.height, view.frame.width, 0.6)
        bottomBorder.backgroundColor = UIColor.white.cgColor
        view.layer.addSublayer(bottomBorder)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func updateWeatherIcon(condition: Int) -> String {
        switch (condition) {
            case 0...300:
                return "tstorm1"
            case 301...500:
                return "light_rain"
            case 501...600:
                return "shower3"
            case 601...700:
                return "snow4"
            case 701...771:
                return "fog"
            case 772...799:
                return "tstorm3"
            case 800:
                return "sunny"
            case 801...804:
                return "cloudy2"
            case 900...903, 905...1000:
                return "tstorm3"
            case 903:
                return "snow5"
            case 904:
                return "sunny"
            default:
                return "dunno"
        }
    }
    
    //MARK: - Loading, Updating and Saving the Forecast Information
    /***************************************************************/
    
    func loadForecast(with requestForecast: NSFetchRequest<WeatherForecast> = WeatherForecast
        .fetchRequest()) {
        let cityPredicate = NSPredicate(format: "parentCity.city MATCHES %@", selectedCity!.city!)
        
        requestForecast.predicate = cityPredicate
        do {
            forecastArray = try contextForecast.fetch(requestForecast)
        } catch {
            print("Error fetching data from contextForecast \(error)")
        }
        forecastCollectionView.reloadData()
    }
    
    func updateForecast() {
        if let city = selectedCity {
            let params : [String : String] = ["q" : city.city!, "appid" : APP_ID]
            
            getWeatherForecast(url: WEATHER_FORECAST_URL, parameters: params, cityWeatherInfo: city)
        }
    }
    
    func getWeatherForecast(url: String, parameters: [String: String], cityWeatherInfo: WeatherDataModel) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                let weatherJSON: JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJSON, with: cityWeatherInfo)
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    func updateWeatherData(json: JSON, with cityWeatherInfo: WeatherDataModel) {
        var dayForecast: Int = 0
        
        for eachThreeHours in stride(from: 0, to: 17, by: 8) {
            var forecast: WeatherForecast
            forecast = (cityWeatherInfo.forecastDataAvailable == false) ? WeatherForecast(context: self.contextForecast) : (forecastArray?[dayForecast])!
            forecast.parentCity = cityWeatherInfo
            forecast.temperature = Int32(json["list"][eachThreeHours]["main"]["temp"].doubleValue - 273.15)
            forecast.condition = json["list"][eachThreeHours]["weather"][0]["id"].int32Value
            forecast.dayOfWeek = self.getDayOfWeek(increaseDayBy: dayForecast + 1)
            dayForecast = dayForecast + 1
            if (cityWeatherInfo.forecastDataAvailable == false) {
                forecastArray?.append(forecast)
            }
        }
        cityWeatherInfo.forecastDataAvailable = true
        saveForecastInfo()
    }
    
    func getDayOfWeek(increaseDayBy: Int) -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        var dateComponents = DateComponents()
        var dayOfWeekString: String = ""
        
        dateFormatter.dateFormat = "dd"
        dateFormatter.dateFormat = "EEEE"
        dateComponents.setValue(increaseDayBy, for: .day)
        if let date = Calendar.current.date(byAdding: dateComponents, to: now) {
            dayOfWeekString = dateFormatter.string(from: date)
        }
        return dayOfWeekString
    }
    
    func saveForecastInfo() {
        do {
            try contextForecast.save()
        } catch {
            print("Error saving context \(error)")
        }
        forecastCollectionView.reloadData()
    }
    
    //MARK: - Collection View Methods
    /***************************************************************/

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count: Int = 0
        
        if let existingArray = forecastArray {
            count = existingArray.count
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = forecastCollectionView.dequeueReusableCell(withReuseIdentifier: "customForecastCell", for: indexPath) as! CustomForecastCell
        
        cell.backgroundColor = .clear
        if let forecastItem = forecastArray?[indexPath.row] {
            cell.temperatureLabel.text = String(forecastItem.temperature) + "°"
            cell.weatherIcon.image = UIImage(named: updateWeatherIcon(condition: Int(forecastItem.condition)))
            cell.dayOfWeek.text = forecastItem.dayOfWeek
        }
        return cell
    }
}
