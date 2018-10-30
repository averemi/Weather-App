//
//  AddCityViewController.swift
//  Weather App
//
//  Created by Anastasia Veremiichyk on 10/26/18.
//  Copyright © 2018 Anastasia Veremiichyk. All rights reserved.
//

import UIKit

protocol AddCityDelegate {
    func userAddedANewCityName (city : String)
}


class AddCityViewController: UIViewController {
    
    var delegate : AddCityDelegate?
    
    
    @IBOutlet weak var addCityTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "cityListBackground.jpg")!)

    }
    
    
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
            
        
        if let cityName = addCityTextField.text {

            delegate?.userAddedANewCityName(city: cityName)
            print(cityName)
            
            
        }
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
        

    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
