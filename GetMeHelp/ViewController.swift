//
//  ViewController.swift
//  GetMeHelp
//
//  Created by Francis Furnelli on 12/18/20.
//

import UIKit
import RadarSDK
class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var optionPicker: UIPickerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var pickerData = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerData = ["Chipotle", "Moe's", "Qdoba", "El Pollo Guapo"]
        titleLabel.text = "GetMeHelp!"
        titleLabel.isHidden = false
        optionPicker.dataSource = self
        optionPicker.delegate = self
        let loc = CLLocation(latitude: 42.0566201045534, longitude: -72.55247246362245)
        Radar.searchPlaces(
          near: loc,
          radius: 1000, // meters
            chains: nil,
          categories: ["medical-health"],
          groups: nil,
          limit: 10
        ) { (status, location, places) in
          // do something with places
            let placeArr = places!
            for place in placeArr {
                print(place.name)
            }
        }
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
}

