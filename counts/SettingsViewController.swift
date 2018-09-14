//
//  SettingsViewController.swift
//  imIn
//
//  Created by Domenic Conversa on 6/14/17.
//  Copyright © 2017 versaTech. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class SettingsViewController: UIViewController, UITextFieldDelegate/*, UIPickerViewDelegate, UIPickerViewDataSource*/ {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var schoolCodeLabel: UILabel!
    //@IBOutlet weak var schoolPickerView: UIPickerView!

    var ref:DatabaseReference!
    var databaseHandle:DatabaseHandle!
    
    var userID = ""
    //var schools = ["York Community High School"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

        userID = (Auth.auth().currentUser?.uid)!
        
        nameTextField.delegate = self
        //schoolPickerView.delegate = self
        //schoolPickerView.dataSource = self
        
        nameTextSetUp()
        
    }

    @IBAction func changeName(_ sender: Any) {
        self.ref.child("AAAUSERS").child(userID).child("Name").setValue(self.nameTextField.text!)
        textFieldShouldReturn(nameTextField)
    }
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func adminPressed(_ sender: Any) {
        
        databaseHandle = ref?.child("AAAUSERS").child(userID).child("Admin").observe(.value, with: { (snapshot) in
            
            let code = snapshot.value as? String
            
            if let actualCode = code {
                
                if actualCode == "true" {
                    self.performSegue(withIdentifier: "enterAdmin", sender: self)
                }
            } else {
                self.createAlertView(message: "You are not an administrator.")
            }
        })
        
    }
    
    func nameTextSetUp() {
        
        self.databaseHandle = self.ref?.child("AAAUSERS").child(userID).child("Name").observe(.value, with: { (snapshot) in
            
            let name = snapshot.value as? String
            
            if let actualName = name {
                
                self.nameTextField.text! = actualName
                
            }
        })
        
        self.databaseHandle = self.ref?.child("AAAUSERS").child(userID).child("School").observe(.value, with: { (snapshot) in
            
            let skool = snapshot.value as? String
            
            if let actualSkool = skool {
                
                if actualSkool == "YORK" {self.schoolCodeLabel.text! = "York Community High School (YORK123)"}
                else {self.schoolCodeLabel.text! = actualSkool}
                
            }
        })

        
    }
    
    /*func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schools.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schools[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            self.ref.child("AAAUSERS").child(userID).child("School").setValue("YORK")
        }
        else {self.ref.child("AAAUSERS").child(userID).child("School").setValue(schools[row])}
    }*/
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //hide keyboard when touch outside
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
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
