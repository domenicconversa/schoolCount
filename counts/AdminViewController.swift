//
//  AdminViewController.swift
//  imIn
//
//  Created by Domenic Conversa on 6/14/17.
//  Copyright © 2017 versaTech. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class AdminViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var ref:DatabaseReference!
    var databaseHandle:DatabaseHandle!
    var userID = ""
    var durString = ""
    var durations = ["---", "1 hr", "2 hrs", "3 hrs", "4 hrs", "5 hrs", "6 hrs", "7 hrs", "8 hrs", "9 hrs", "10 hrs", "11 hrs", "12 hrs"]

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var teamTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var durationPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        userID = (Auth.auth().currentUser?.uid)!
        
        durationPickerView.delegate = self
        durationPickerView.dataSource = self
        addressTextField.delegate = self
        dateTextField.delegate = self
        categoryTextField.delegate = self
        teamTextField.delegate = self
        locationTextField.delegate = self
        timeTextField.delegate = self
        
        nameLabelSetUp()
        
    }
    
    func nameLabelSetUp() {
    
        self.databaseHandle = self.ref?.child("AAAUSERS").child(userID).child("Name").observe(.value, with: { (snapshot) in
            
            let name = snapshot.value as? String
            
            if let actualName = name {
                
                self.nameLabel.text! = actualName
                
            }
        })
        
    }
    
    @IBAction func createEventPressed(_ sender: Any) {
        print("create event")
        //countSetUp()
        var stop = false
        
        if dateTextField.text! == "" || categoryTextField.text! == "" || teamTextField.text! == "" || locationTextField.text! == "" || addressTextField.text! == "" || timeTextField.text! == "" || durString == "" {
            
            createAlertView(message: "Please fill in all parts for the event.")
            
        } else {
            
            self.databaseHandle = self.ref?.child("AAAUSERS").child(self.userID).child("School").observe(.value, with: { (snapshot) in
                
                let school = snapshot.value as? String
                
                if let actualSchool = school {
                    
                    self.databaseHandle = self.ref?.child(actualSchool).child("EVENTS").child(self.dateTextField.text!).child("Count").observe(.value, with: { (snapshot) in
                        
                        let count = snapshot.value as? String
                        
                        if let actualCount = count {
                            print("test1")
                            if stop == false {
                                
                                let newCount = Int(actualCount)! + 1
                                print("test2")
                                
                                self.createNewEvent(school: actualSchool, eventNum: newCount)
                                
                                stop = true
                            }
                        } else {
                            
                            if stop == false {
                                
                                self.createNewEvent(school: actualSchool, eventNum: 1)
                                
                                stop = true
                            }
                            
                        }
                    })
                }
            })
        }
    }

    func createNewEvent(school: String, eventNum: Int) {
        
        let eventString = "Event" + String(eventNum)
        
        self.ref.child(school).child("EVENTS").child(self.dateTextField.text!).child(eventString).child("Address").setValue(self.addressTextField.text!)
        self.ref.child(school).child("EVENTS").child(self.dateTextField.text!).child(eventString).child("Category").setValue(self.categoryTextField.text!)
        self.ref.child(school).child("EVENTS").child(self.dateTextField.text!).child(eventString).child("Count").setValue("0")
        self.ref.child(school).child("EVENTS").child(self.dateTextField.text!).child(eventString).child("Duration").setValue(self.durString)
        self.ref.child(school).child("EVENTS").child(self.dateTextField.text!).child(eventString).child("Location").setValue(self.locationTextField.text!)
        self.ref.child(school).child("EVENTS").child(self.dateTextField.text!).child(eventString).child("Name").setValue(self.teamTextField.text!)
        self.ref.child(school).child("EVENTS").child(self.dateTextField.text!).child(eventString).child("Time").setValue(self.timeTextField.text!)
        
        self.ref.child(school).child("EVENTS").child(self.dateTextField.text!).child("Count").setValue(String(eventNum))
        
    }

    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return durations.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return durations[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        durString = String(row)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //hide keyboard when touch outside
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addressTextField.resignFirstResponder()
        dateTextField.resignFirstResponder()
        categoryTextField.resignFirstResponder()
        teamTextField.resignFirstResponder()
        locationTextField.resignFirstResponder()
        timeTextField.resignFirstResponder()
        return true
    }
    
    func createAlertView (message: String) {
        
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
