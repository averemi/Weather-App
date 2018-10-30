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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    func configureView() {
        if let backgroundImage = UIImage(named: "cityListBackground.jpg") {
            self.view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        viewContainer.backgroundColor = .clear
    }
    
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        if let cityName = searchBar.text {
            delegate?.userAddedANewCityName(city: cityName)
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension  AddCityViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}
