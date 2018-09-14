//
//  iPadAdminViewController.swift
//  imIn
//
//  Created by Domenic Conversa on 6/14/17.
//  Copyright © 2017 versaTech. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class iPadAdminViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var ref:DatabaseReference!
    var databaseHandle:DatabaseHandle!
    
    //var eventCount = 0
    var userID = ""
    var durString = ""
    var durations = ["---", "1 hr", "2 hrs", "3 hrs", "4 hrs", "5 hrs", "6 hrs", "7 hrs", "8 hrs", "9 hrs", "10 hrs", "11 hrs", "12 hrs"]

    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var teamTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var durationPickerView: UIPickerView!
    
    @IBAction func createEventPressed(_ sender: Any) {
        print("create event")
        //countSetUp()
        var stop = false
        
        self.databaseHandle = self.ref?.child("AAAUSERS").child(self.userID).child("School").observe(.value, with: { (snapshot) in
            
            let school = snapshot.value as? String
            
            if let actualSchool = school {
                
                self.databaseHandle = self.ref?.child(actualSchool).child("EVENTS").child(self.dateTextField.text!).child("Count").observe(.value, with: { (snapshot) in
                    
                    let count = snapshot.value as? String
                    
                    if let actualCount = count {
                        
                        if stop == false {
                        
                            let newCount = Int(actualCount)! + 1
                            
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        userID = (Auth.auth().currentUser?.uid)!
        
        durationPickerView.delegate = self
        durationPickerView.dataSource = self
        
        
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
