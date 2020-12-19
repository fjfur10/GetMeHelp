//
//  ManLocationViewController.swift
//  GetMeHelp
//
//  Created by Emily Cooper on 12/19/20.
//

import UIKit

protocol DataEnteredDelegate:AnyObject{
    func userDidEnterInformation(info:[String:String])
}

class ManLocationViewController: UIViewController {
    
    @IBOutlet weak var SL1: UITextField!
    @IBOutlet weak var SL2: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zip: UITextField!
    @IBOutlet weak var popUp: UIView!
    @IBOutlet weak var gobutton: UIButton!
    
    var manualadd = [String:String]()
    
    weak var delegate: DataEnteredDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUp.layer.cornerRadius = 20
        popUp.clipsToBounds = true
       
        gobutton.layer.cornerRadius = 20
        gobutton.clipsToBounds = true;

    }
    
    
    @IBAction func dismisspopUp(_ sender: UIButton) {
        dismiss(animated:true, completion: nil)
    }
  
    @IBAction func sendtextBackButton(sender:AnyObject){
        //let mystring = "Street Line 1: \(SL1.text!) \nStreet Line 2: \(SL2.text!) \nCity: \(city.text!) \nState: \(state.text!) \nZip: \(zip.text!) "
        
        manualadd = ["street1":SL1.text!.lowercased(),
                     "street2":SL2.text!.lowercased(),
                     "city":city.text!.lowercased(),
                     "state":state.text!.lowercased(),
                     "zip":zip.text!]
        
        delegate?.userDidEnterInformation(info: manualadd)
        dismiss(animated: true, completion: nil)
    }
}
