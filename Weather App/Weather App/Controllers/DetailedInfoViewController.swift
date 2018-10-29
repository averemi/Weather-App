//
//  DetailedInfoViewController.swift
//  Weather App
//
//  Created by Anastasia Veremiichyk on 10/28/18.
//  Copyright © 2018 Anastasia Veremiichyk. All rights reserved.
//

import UIKit
import CoreData

class DetailedInfoViewController: UIViewController {
    
    var selectedCity : WeatherDataModel?

    @IBOutlet weak var tempLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let city = selectedCity {
       //     self.title = city.city
        //    if let
            tempLabel.text = String(city.temperature) + "°"
        }

    }
    
    
    
    

    

}
