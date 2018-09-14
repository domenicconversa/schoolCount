//
//  LoginViewController.swift
//  imIn
//
//  Created by Domenic Conversa on 6/7/17.
//  Copyright © 2017 versaTech. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController, UITextFieldDelegate/*, UIPickerViewDelegate, UIPickerViewDataSource*/ {
    
    var ref:DatabaseReference!
    var databaseHandle:DatabaseHandle!
    //var schools = ["--Select your school--", "York Community High School"]
    //var schoolInt = 0
    var schoolStr = ""

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var schoolCode: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    //@IBOutlet weak var schoolPickerView: UIPickerView!
    
    @IBAction func loginSignupPressed(_ sender: Any) {
        
        if schoolCode.text != "YORK123" {createAlertView(message: "Please enter valid school code.")}
        if nameText.text == "" {createAlertView(message: "Please enter your first name.")}
        
        if emailText.text != "" && passwordText.text != "" && schoolCode.text == "YORK123" && nameText.text != "" && lastNameText.text != ""{
            
            if segmentControl.selectedSegmentIndex == 0 { //login existing user
                
                Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                    
                    if user != nil {
                        //log in successful
                        self.performSegue(withIdentifier: "enterSegue", sender: self)
                        self.completeSignIn(id: user!.uid)
                        
                    } else {
                        if let myError = error?.localizedDescription {
                            print(myError)
                            self.createAlertView (message: myError)
                        } else {
                            print("Error")
                            self.createAlertView (message: "Error")
                        }
                    }
                    
                })
            } else { //sign up new user
                
                Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                    
                    if self.schoolCode.text == "YORK123" {self.schoolStr = "YORK"}
                    
                    if user != nil {
                        //sign up successful
                        self.performSegue(withIdentifier: "enterSegue", sender: self)
                        self.completeSignIn(id: user!.uid)
                        self.finishSignUp(id: user!.uid)
                        
                    } else {
                        if let myError = error?.localizedDescription {
                            print(myError)
                            self.createAlertView (message: myError)
                        } else {
                            print("Error")
                            self.createAlertView (message: "Error")
                        }
                    }
                    
                })
                
            }
            
        } else {createAlertView(message: "Please fill out all information.")}
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let keyChain = DataService().keyChain
        
        if keyChain.get("uid") != nil {
            performSegue(withIdentifier: "enterSegue", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if schoolCode.text == "YORK123" {schoolStr = "YORK"}
        
        ref = Database.database().reference()
        
        self.emailText.delegate = self
        self.passwordText.delegate = self
        self.nameText.delegate = self
        self.lastNameText.delegate = self
        self.schoolCode.delegate = self
        //schoolPickerView.delegate = self
        //schoolPickerView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { //hide keyboard when touch outside
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailText.resignFirstResponder()
        passwordText.resignFirstResponder()
        nameText.resignFirstResponder()
        lastNameText.resignFirstResponder()
        schoolCode.resignFirstResponder()
        return true
    }
    
    func completeSignIn(id: String) {
        let keyChain = DataService().keyChain
        keyChain.set(id, forKey: "uid")
    }
    func finishSignUp(id: String) {
        self.ref.child("AAAUSERS").child(id).child("ID").setValue(id)
        self.ref.child("AAAUSERS").child(id).child("Email").setValue(emailText.text!)
        self.ref.child("AAAUSERS").child(id).child("Name").setValue(nameText.text!)
        self.ref.child("AAAUSERS").child(id).child("LastName").setValue(lastNameText.text!)
        self.ref.child("AAAUSERS").child(id).child("Points").setValue("0")
        self.ref.child("AAAUSERS").child(id).child("Pending").setValue("0")
        self.ref.child("AAAUSERS").child(id).child("School").setValue(schoolStr)
    }
    
    func createAlertView (message: String) {
        
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /*func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return schools.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return schools[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        schoolInt = row
        if schoolInt == 1 {schoolStr = "YORK"}
        else {schoolStr = schools[row]}
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: schools[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
        return attributedString
    }*/
    
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
        
        let desView: ScheduleViewController = segue.destination as! ScheduleViewController
        
        desView.schoolStr = schoolStr
        
    }*/
    

}
