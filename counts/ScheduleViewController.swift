//
//  ScheduleViewController.swift
//  imIn
//
//  Created by Domenic Conversa on 5/30/17.
//  Copyright © 2017 versaTech. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import KeychainSwift
import SystemConfiguration
import MapKit
import CoreLocation

extension UILabel {
    func addTextSpacing() { //allowing for character spacing to be an option
        if let textString = text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSKernAttributeName, value: 2.50, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
    func setTextWithLineSpacing(text: String, lineHeightMultiply: CGFloat = 1.3) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineHeightMultiply
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        self.attributedText = attributedString
    }
}
extension Bool { //allow for string to be converted to bool value
    init?(string: String) {
        switch string {
        case "True", "true", "TRUE", "yes", "1":
            self = true
        case "False", "false", "FALSE", "no", "0":
            self = false
        default:
            return nil
        }
    }
}

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate {

    var ref:DatabaseReference!
    var databaseHandle:DatabaseHandle!
    
    @IBOutlet weak var datePickerView: UIPickerView!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var popUpViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var datePickerConstraint: NSLayoutConstraint!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var datePopUp: UIView!
    
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userPointsLabel: UILabel!
    @IBOutlet weak var userPendingLabel: UILabel!
    //@IBOutlet weak var userToGoLabel: UILabel!
    
    
    @IBAction func bringUpPressed(_ sender: Any) {
        if popUpAgain == true {
            popUpViewConstraint.constant = -15
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
            popUpAgain = false
        }
        else if popUpAgain == false {
            popUpViewConstraint.constant = -225
            
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
            popUpAgain = true
        }
    }
    @IBAction func closePopUpPressed(_ sender: Any) {
        popUpViewConstraint.constant = -225
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
        popUpAgain = true
    }
    @IBAction func openDatePickerView(_ sender: Any) {
        datePickerConstraint.constant = 50
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func closeDatePicker(_ sender: Any) {
        datePickerConstraint.constant = 270
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func signOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        DataService().keyChain.delete("uid")
        dismiss(animated: true, completion: nil)
    }
    
    //start checkin vars
    let manager = CLLocationManager()
    
    //var recheckLoc = true
    var correctLoc = Bool()
    var coordFromString = ""
    var latFromString = Double()
    var longFromString = Double()
    var userPlaceName = ""
    var userAddress = ""
    var userLat = Double()
    var userLong = Double()
    
    var eventInt = 1
    
    var checkCountInt = 0
    
    var correctLocations = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false]
    
    var currentEventsIndexes = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var currentEventsCats = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    
    var addresses = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var durations = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    var startTimes = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var endTimes = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    //end checkin vars
    
    //refresh control
    //var refresh = UIRefreshControl()
    
    //var myTimer = Timer() //uncomment if need to constantly reload tableview
    var userID = ""
    var schoolStr = ""
    var dateInt = 0
    var userPoints = 0
    var userPending = 0
    var userToGo = 0
    var popUpAgain = true
    
    var numEvents0 = 1
    var numEvents1 = 1
    var numEvents2 = 1
    var numEvents3 = 1
    var numEvents4 = 1
    var numEvents5 = 1
    var numEvents6 = 1
    var numEvents7 = 1
    var numEvents8 = 1
    var numEvents9 = 1
    
    
    var dates = [String]()
    
    //today - 30 spots max
    var addresses0 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var duration0 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var cats0 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var names0 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var counts0 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var times0 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var locs0 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var mults0 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var buttonSelection0 = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
    
    //day 1
    var addresses1 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var duration1 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var cats1 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var names1 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var counts1 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var times1 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var locs1 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var mults1 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var buttonSelection1 = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
    
    //day 2
    var addresses2 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var duration2 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var cats2 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var names2 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var counts2 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var times2 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var locs2 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var mults2 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var buttonSelection2 = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
    
    //day 3
    var addresses3 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var duration3 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var cats3 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var names3 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var counts3 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var times3 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var locs3 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var mults3 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var buttonSelection3 = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
    
    //day 4
    var addresses4 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var duration4 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var cats4 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var names4 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var counts4 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var times4 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var locs4 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var mults4 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var buttonSelection4 = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
    
    //day 5
    var addresses5 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var duration5 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var cats5 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var names5 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var counts5 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var times5 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var locs5 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var mults5 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var buttonSelection5 = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
    
    //day 6
    var addresses6 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var duration6 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var cats6 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var names6 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var counts6 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var times6 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var locs6 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var mults6 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var buttonSelection6 = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
    
    //day 7
    var addresses7 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var duration7 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var cats7 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var names7 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var counts7 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var times7 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var locs7 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var mults7 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var buttonSelection7 = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
    
    //day 8
    var addresses8 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var duration8 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var cats8 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var names8 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var counts8 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var times8 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var locs8 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var mults8 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var buttonSelection8 = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
    
    //day 9
    var addresses9 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var duration9 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var cats9 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var names9 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var counts9 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var times9 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var locs9 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var mults9 = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""]
    var buttonSelection9 = [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        //uncomment to add tableview refresh
        //refresh.addTarget(self, action: #selector(ScheduleViewController.refreshTableView), for: UIControlEvents.valueChanged)
        //scheduleTableView.addSubview(refresh)
        
        dateLabel.text = getDate(jump: 0)
        userID = (Auth.auth().currentUser?.uid)!
        
        popUpView.layer.cornerRadius = 20
        popUpView.layer.masksToBounds = true
        datePopUp.layer.cornerRadius = 20
        datePopUp.layer.masksToBounds = true
        
        //location check setup
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        schoolStringSetUp()
        nameLabelSetUp()
        schedulesSetUp()
        dateArraySetUp()
        arraysSetUp()
        pointsSetUp()
        
        //uncomment if need to constantly reload tableview
        /*self.myTimer = Timer(timeInterval: 0.25, target: self, selector: #selector(ScheduleViewController.refreshTableView), userInfo: nil, repeats: true)
        RunLoop.main.add(self.myTimer, forMode: RunLoopMode.defaultRunLoopMode)*/
    

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dates[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dateLabel.text = dates[row]
        dateInt = row
        scheduleTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dateInt == 0 {
            if cats0[0] != "" {
                noEventsLabel.text = ""
                return numEvents0
            } else {
                noEventsLabel.text = "No events scheduled for today."
                return 0
            }
        } else if dateInt == 1 {
            if cats1[0] != "" {
                noEventsLabel.text = ""
                return numEvents1
            } else {
                noEventsLabel.text = "No events scheduled for today."
                return 0
            }
        } else if dateInt == 2 {
            if cats2[0] != "" {
                noEventsLabel.text = ""
                return numEvents2
            } else {
                noEventsLabel.text = "No events scheduled for today."
                return 0
            }
        } else if dateInt == 3 {
            if cats3[0] != "" {
                noEventsLabel.text = ""
                return numEvents3
            } else {
                noEventsLabel.text = "No events scheduled for today."
                return 0
            }
        } else if dateInt == 4 {
            if cats4[0] != "" {
                noEventsLabel.text = ""
                return numEvents4
            } else {
                noEventsLabel.text = "No events scheduled for today."
                return 0
            }
        } else if dateInt == 5 {
            if cats5[0] != "" {
                noEventsLabel.text = ""
                return numEvents5
            } else {
                noEventsLabel.text = "No events scheduled for today."
                return 0
            }
        } else if dateInt == 6 {
            if cats6[0] != "" {
                noEventsLabel.text = ""
                return numEvents6
            } else {
                noEventsLabel.text = "No events scheduled for today."
                return 0
            }
        } else if dateInt == 7 {
            if cats7[0] != "" {
                noEventsLabel.text = ""
                return numEvents7
            } else {
                noEventsLabel.text = "No events scheduled for today."
                return 0
            }
        } else if dateInt == 8 {
            if cats8[0] != "" {
                noEventsLabel.text = ""
                return numEvents8
            } else {
                noEventsLabel.text = "No events scheduled for today."
                return 0
            }
        } else if dateInt == 9 {
            if cats9[0] != "" {
                noEventsLabel.text = ""
                return numEvents9
            } else {
                noEventsLabel.text = "No events scheduled for today."
                return 0
            }
        } else {
            noEventsLabel.text = "No events scheduled for today."
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ScheduleCell
        
        //cell.multiplier.text = "x2"
        
        if dateInt == 0 {
            cell.catLabel.text = cats0[(indexPath as NSIndexPath).row]
            cell.countLabel.text = counts0[(indexPath as NSIndexPath).row]
            cell.locLabel.text = locs0[(indexPath as NSIndexPath).row]
            cell.nameLabel.text = names0[(indexPath as NSIndexPath).row]
            cell.timeLabel.text = times0[(indexPath as NSIndexPath).row] //+ " - " + endTimes[(indexPath as NSIndexPath).row]
            cell.multiplier.text = mults0[(indexPath as NSIndexPath).row]
        }
        if dateInt == 1 {
            cell.catLabel.text = cats1[(indexPath as NSIndexPath).row]
            cell.countLabel.text = counts1[(indexPath as NSIndexPath).row]
            cell.locLabel.text = locs1[(indexPath as NSIndexPath).row]
            cell.nameLabel.text = names1[(indexPath as NSIndexPath).row]
            cell.timeLabel.text = times1[(indexPath as NSIndexPath).row]
            cell.multiplier.text = mults1[(indexPath as NSIndexPath).row]
        }
        if dateInt == 2 {
            cell.catLabel.text = cats2[(indexPath as NSIndexPath).row]
            cell.countLabel.text = counts2[(indexPath as NSIndexPath).row]
            cell.locLabel.text = locs2[(indexPath as NSIndexPath).row]
            cell.nameLabel.text = names2[(indexPath as NSIndexPath).row]
            cell.timeLabel.text = times2[(indexPath as NSIndexPath).row]
            cell.multiplier.text = mults2[(indexPath as NSIndexPath).row]
        }
        if dateInt == 3 {
            cell.catLabel.text = cats3[(indexPath as NSIndexPath).row]
            cell.countLabel.text = counts3[(indexPath as NSIndexPath).row]
            cell.locLabel.text = locs3[(indexPath as NSIndexPath).row]
            cell.nameLabel.text = names3[(indexPath as NSIndexPath).row]
            cell.timeLabel.text = times3[(indexPath as NSIndexPath).row]
            cell.multiplier.text = mults3[(indexPath as NSIndexPath).row]
        }
        if dateInt == 4 {
            cell.catLabel.text = cats4[(indexPath as NSIndexPath).row]
            cell.countLabel.text = counts4[(indexPath as NSIndexPath).row]
            cell.locLabel.text = locs4[(indexPath as NSIndexPath).row]
            cell.nameLabel.text = names4[(indexPath as NSIndexPath).row]
            cell.timeLabel.text = times4[(indexPath as NSIndexPath).row]
            cell.multiplier.text = mults4[(indexPath as NSIndexPath).row]
        }
        if dateInt == 5 {
            cell.catLabel.text = cats5[(indexPath as NSIndexPath).row]
            cell.countLabel.text = counts5[(indexPath as NSIndexPath).row]
            cell.locLabel.text = locs5[(indexPath as NSIndexPath).row]
            cell.nameLabel.text = names5[(indexPath as NSIndexPath).row]
            cell.timeLabel.text = times5[(indexPath as NSIndexPath).row]
            cell.multiplier.text = mults5[(indexPath as NSIndexPath).row]
        }
        if dateInt == 6 {
            cell.catLabel.text = cats6[(indexPath as NSIndexPath).row]
            cell.countLabel.text = counts6[(indexPath as NSIndexPath).row]
            cell.locLabel.text = locs6[(indexPath as NSIndexPath).row]
            cell.nameLabel.text = names6[(indexPath as NSIndexPath).row]
            cell.timeLabel.text = times6[(indexPath as NSIndexPath).row]
            cell.multiplier.text = mults6[(indexPath as NSIndexPath).row]
        }
        if dateInt == 7 {
            cell.catLabel.text = cats7[(indexPath as NSIndexPath).row]
            cell.countLabel.text = counts7[(indexPath as NSIndexPath).row]
            cell.locLabel.text = locs7[(indexPath as NSIndexPath).row]
            cell.nameLabel.text = names7[(indexPath as NSIndexPath).row]
            cell.timeLabel.text = times7[(indexPath as NSIndexPath).row]
            cell.multiplier.text = mults7[(indexPath as NSIndexPath).row]
        }
        if dateInt == 8 {
            cell.catLabel.text = cats8[(indexPath as NSIndexPath).row]
            cell.countLabel.text = counts8[(indexPath as NSIndexPath).row]
            cell.locLabel.text = locs8[(indexPath as NSIndexPath).row]
            cell.nameLabel.text = names8[(indexPath as NSIndexPath).row]
            cell.timeLabel.text = times8[(indexPath as NSIndexPath).row]
            cell.multiplier.text = mults8[(indexPath as NSIndexPath).row]
        }
        if dateInt == 9 {
            cell.catLabel.text = cats9[(indexPath as NSIndexPath).row]
            cell.countLabel.text = counts9[(indexPath as NSIndexPath).row]
            cell.locLabel.text = locs9[(indexPath as NSIndexPath).row]
            cell.nameLabel.text = names9[(indexPath as NSIndexPath).row]
            cell.timeLabel.text = times9[(indexPath as NSIndexPath).row]
            cell.multiplier.text = mults9[(indexPath as NSIndexPath).row]
        }
        
        cell.goingButton.tag = indexPath.row
        let buttonTag = indexPath.row
        cell.goingButton.addTarget(self, action: #selector(ScheduleViewController.buttonAction(sender:)), for: .touchUpInside)
        
        //disable button after check in
        self.databaseHandle = self.ref?.child("AAAUSERS").child(self.userID).child("School").observe(.value, with: { (snapshot) in
            
            let school = snapshot.value as? String
            
            if let actualSchool = school {
                
                self.schoolStr = actualSchool
                
                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event"+String(buttonTag+1)).child("USERS").child(self.userID + "DONE").observe(.value, with: { (snapshot) in
                    
                    let dis = snapshot.value as? String
                    
                    if let actualDis = dis {
                        
                        if actualDis == "true" && self.dateInt == 0 {
                            cell.goingButton.isEnabled = false
                        }
                    }
                })
            }
        })
        
        
        if !(internetConnectionCheck()){
            
            cell.goingButton.isEnabled = false
            
        } else {
            
            cell.goingButton.isEnabled = true
            cell.goingButton.isSelected = buttonSelectionChanger(tag: buttonTag) //update button selection value (true or false)
            
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let checkinAction = UITableViewRowAction(style: .default, title: "Check In") { (action, indexPath) in
            let rowInt = indexPath.row
            
            self.checkinFunc(eventNum: (rowInt+1))
            return
        }
        
        let disableAction = UITableViewRowAction(style: .default, title: "Begins " + getDate(jump: dateInt)) { (action, indexPath) in
        }
        //checkinAction.backgroundColor = UIColor(patternImage: UIImage(named: "slideout image")!)
        disableAction.backgroundColor = #colorLiteral(red: 0.581176274, green: 0.7142093357, blue: 0.7779265587, alpha: 1)
        checkinAction.backgroundColor = #colorLiteral(red: 0.3315864085, green: 0.5383416379, blue: 0.6768994331, alpha: 1)
        if dateInt == 0 {return [checkinAction]}
        else {return [disableAction]}
    }
    
    func buttonSelectionChanger(tag: Int) -> Bool{ //change selected state of cell button
        
        var selectionValue = true
        
        if dateInt == 0 {
            if buttonSelection0[tag] == false {
                // set selected
                selectionValue = true
                
            } else {
                // set deselected
                selectionValue = false
            }
        }
        if dateInt == 1 {
            if buttonSelection1[tag] == false {
                // set selected
                selectionValue = true
                
            } else {
                // set deselected
                selectionValue = false
            }
        }
        if dateInt == 2 {
            if buttonSelection2[tag] == false {
                // set selected
                selectionValue = true
                
            } else {
                // set deselected
                selectionValue = false
            }
        }
        if dateInt == 3 {
            if buttonSelection3[tag] == false {
                // set selected
                selectionValue = true
                
            } else {
                // set deselected
                selectionValue = false
            }
        }
        if dateInt == 4 {
            if buttonSelection4[tag] == false {
                // set selected
                selectionValue = true
                
            } else {
                // set deselected
                selectionValue = false
            }
        }
        if dateInt == 5 {
            if buttonSelection5[tag] == false {
                // set selected
                selectionValue = true
                
            } else {
                // set deselected
                selectionValue = false
            }
        }
        if dateInt == 6 {
            if buttonSelection6[tag] == false {
                // set selected
                selectionValue = true
                
            } else {
                // set deselected
                selectionValue = false
            }
        }
        if dateInt == 7 {
            if buttonSelection7[tag] == false {
                // set selected
                selectionValue = true
                
            } else {
                // set deselected
                selectionValue = false
            }
        }
        if dateInt == 8 {
            if buttonSelection8[tag] == false {
                // set selected
                selectionValue = true
                
            } else {
                // set deselected
                selectionValue = false
            }
        }
        if dateInt == 9 {
            if buttonSelection9[tag] == false {
                // set selected
                selectionValue = true
                
            } else {
                // set deselected
                selectionValue = false
            }
        }
        
        return selectionValue
        
    }
    
    func buttonAction(sender: UIButton) {
        
        databaseHandle = ref?.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID + "CHECKIN").observe(.value, with: { (snapshot) in
            
            let checkVal = snapshot.value as? String
            
            if let actualcheckVal = checkVal {
                //already set a checkin value
                print("Button already pressed, don't need new checkin val " + actualcheckVal)
                
            } else {
                //first time clicking button, set a checkin value
                self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: self.dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(self.userID + "CHECKIN").setValue("false")
            }
        })
        
        
        
        if dateInt == 0 {
            if buttonSelection0[sender.tag] == true {
                // set selected
                buttonSelection0[sender.tag] = false
                var countInt = Int(counts0[sender.tag])!
                countInt += 1
                let countStr = String(countInt)
                counts0[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("false") //very importante actually
                //increase pending points count
                if mults0[sender.tag] == "X2" || mults0[sender.tag] == "x2" {
                    userPending += 2
                } else {
                    userPending += 1
                }
                //
                
                
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            } else {
                // set deselected
                buttonSelection0[sender.tag] = true
                var countInt = Int(counts0[sender.tag])!
                countInt -= 1
                let countStr = String(countInt)
                counts0[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("true") //very importante actually
                //decrease pending points count
                if mults0[sender.tag] == "X2" || mults0[sender.tag] == "x2" {
                    userPending -= 2
                } else {
                    userPending -= 1
                }
                //
                
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            }
            
            updateDataCount(newCount: counts0[sender.tag], eventNum: sender.tag)
        }
        if dateInt == 1 {
            if buttonSelection1[sender.tag] == true {
                // set selected
                buttonSelection1[sender.tag] = false
                var countInt = Int(counts1[sender.tag])!
                countInt += 1
                let countStr = String(countInt)
                counts1[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("false") //very importante actually
                //increase pending points count
                if mults1[sender.tag] == "X2" || mults1[sender.tag] == "x2" {
                    userPending += 2
                } else {
                    userPending += 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            } else {
                // set deselected
                buttonSelection1[sender.tag] = true
                var countInt = Int(counts1[sender.tag])!
                countInt -= 1
                let countStr = String(countInt)
                counts1[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("true") //very importante actually
                //decrease pending points count
                if mults1[sender.tag] == "X2" || mults1[sender.tag] == "x2" {
                    userPending -= 2
                } else {
                    userPending -= 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            }
            
            updateDataCount(newCount: counts1[sender.tag], eventNum: sender.tag)
        }
        if dateInt == 2 {
            if buttonSelection2[sender.tag] == true {
                // set selected
                buttonSelection2[sender.tag] = false
                var countInt = Int(counts2[sender.tag])!
                countInt += 1
                let countStr = String(countInt)
                counts2[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("false") //very importante actually
                //increase pending points count
                if mults2[sender.tag] == "X2" || mults2[sender.tag] == "x2" {
                    userPending += 2
                } else {
                    userPending += 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            } else {
                // set deselected
                buttonSelection2[sender.tag] = true
                var countInt = Int(counts2[sender.tag])!
                countInt -= 1
                let countStr = String(countInt)
                counts2[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("true") //very importante actually
                //decrease pending points count
                if mults2[sender.tag] == "X2" || mults2[sender.tag] == "x2" {
                    userPending -= 2
                } else {
                    userPending -= 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            }
            
            updateDataCount(newCount: counts2[sender.tag], eventNum: sender.tag)
        }
        if dateInt == 3 {
            if buttonSelection3[sender.tag] == true {
                // set selected
                buttonSelection3[sender.tag] = false
                var countInt = Int(counts3[sender.tag])!
                countInt += 1
                let countStr = String(countInt)
                counts3[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("false") //very importante actually
                //increase pending points count
                if mults3[sender.tag] == "X2" || mults3[sender.tag] == "x2" {
                    userPending += 2
                } else {
                    userPending += 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            } else {
                // set deselected
                buttonSelection3[sender.tag] = true
                var countInt = Int(counts3[sender.tag])!
                countInt -= 1
                let countStr = String(countInt)
                counts3[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("true") //very importante actually
                //decrease pending points count
                if mults3[sender.tag] == "X2" || mults3[sender.tag] == "x2" {
                    userPending -= 2
                } else {
                    userPending -= 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            }
            
            updateDataCount(newCount: counts3[sender.tag], eventNum: sender.tag)
        }
        if dateInt == 4 {
            if buttonSelection4[sender.tag] == true {
                // set selected
                buttonSelection4[sender.tag] = false
                var countInt = Int(counts4[sender.tag])!
                countInt += 1
                let countStr = String(countInt)
                counts4[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("false") //very importante actually
                //increase pending points count
                if mults4[sender.tag] == "X2" || mults4[sender.tag] == "x2" {
                    userPending += 2
                } else {
                    userPending += 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            } else {
                // set deselected
                buttonSelection4[sender.tag] = true
                var countInt = Int(counts4[sender.tag])!
                countInt -= 1
                let countStr = String(countInt)
                counts4[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("true") //very importante actually
                //decrease pending points count
                if mults4[sender.tag] == "X2" || mults4[sender.tag] == "x2" {
                    userPending -= 2
                } else {
                    userPending -= 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            }
            
            updateDataCount(newCount: counts4[sender.tag], eventNum: sender.tag)
        }
        if dateInt == 5 {
            if buttonSelection5[sender.tag] == true {
                // set selected
                buttonSelection5[sender.tag] = false
                var countInt = Int(counts5[sender.tag])!
                countInt += 1
                let countStr = String(countInt)
                counts5[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("false") //very importante actually
                //increase pending points count
                if mults5[sender.tag] == "X2" || mults5[sender.tag] == "x2" {
                    userPending += 2
                } else {
                    userPending += 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            } else {
                // set deselected
                buttonSelection5[sender.tag] = true
                var countInt = Int(counts5[sender.tag])!
                countInt -= 1
                let countStr = String(countInt)
                counts5[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("true") //very importante actually
                //decrease pending points count
                if mults5[sender.tag] == "X2" || mults5[sender.tag] == "x2" {
                    userPending -= 2
                } else {
                    userPending -= 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            }
            
            updateDataCount(newCount: counts5[sender.tag], eventNum: sender.tag)
        }
        if dateInt == 6 {
            if buttonSelection6[sender.tag] == true {
                // set selected
                buttonSelection6[sender.tag] = false
                var countInt = Int(counts6[sender.tag])!
                countInt += 1
                let countStr = String(countInt)
                counts6[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("false") //very importante actually
                //increase pending points count
                if mults6[sender.tag] == "X2" || mults6[sender.tag] == "x2" {
                    userPending += 2
                } else {
                    userPending += 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            } else {
                // set deselected
                buttonSelection6[sender.tag] = true
                var countInt = Int(counts6[sender.tag])!
                countInt -= 1
                let countStr = String(countInt)
                counts6[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("true") //very importante actually
                //decrease pending points count
                if mults6[sender.tag] == "X2" || mults6[sender.tag] == "x2" {
                    userPending -= 2
                } else {
                    userPending -= 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            }
            
            updateDataCount(newCount: counts6[sender.tag], eventNum: sender.tag)
        }
        if dateInt == 7 {
            if buttonSelection7[sender.tag] == true {
                // set selected
                buttonSelection7[sender.tag] = false
                var countInt = Int(counts7[sender.tag])!
                countInt += 1
                let countStr = String(countInt)
                counts7[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("false") //very importante actually
                //increase pending points count
                if mults7[sender.tag] == "X2" || mults7[sender.tag] == "x2" {
                    userPending += 2
                } else {
                    userPending += 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            } else {
                // set deselected
                buttonSelection7[sender.tag] = true
                var countInt = Int(counts7[sender.tag])!
                countInt -= 1
                let countStr = String(countInt)
                counts7[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("true") //very importante actually
                //decrease pending points count
                if mults7[sender.tag] == "X2" || mults7[sender.tag] == "x2" {
                    userPending -= 2
                } else {
                    userPending -= 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            }
            
            updateDataCount(newCount: counts7[sender.tag], eventNum: sender.tag)
        }
        if dateInt == 8 {
            if buttonSelection8[sender.tag] == true {
                // set selected
                buttonSelection8[sender.tag] = false
                var countInt = Int(counts8[sender.tag])!
                countInt += 1
                let countStr = String(countInt)
                counts8[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("false") //very importante actually
                //increase pending points count
                if mults8[sender.tag] == "X2" || mults8[sender.tag] == "x2" {
                    userPending += 2
                } else {
                    userPending += 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            } else {
                // set deselected
                buttonSelection8[sender.tag] = true
                var countInt = Int(counts8[sender.tag])!
                countInt -= 1
                let countStr = String(countInt)
                counts8[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("true") //very importante actually
                //decrease pending points count
                if mults8[sender.tag] == "X2" || mults8[sender.tag] == "x2" {
                    userPending -= 2
                } else {
                    userPending -= 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            }
            
            updateDataCount(newCount: counts8[sender.tag], eventNum: sender.tag)
        }
        if dateInt == 9 {
            if buttonSelection9[sender.tag] == true {
                // set selected
                buttonSelection9[sender.tag] = false
                var countInt = Int(counts9[sender.tag])!
                countInt += 1
                let countStr = String(countInt)
                counts9[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("false") //very importante actually
                //increase pending points count
                if mults9[sender.tag] == "X2" || mults9[sender.tag] == "x2" {
                    userPending += 2
                } else {
                    userPending += 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            } else {
                // set deselected
                buttonSelection9[sender.tag] = true
                var countInt = Int(counts9[sender.tag])!
                countInt -= 1
                let countStr = String(countInt)
                counts9[sender.tag] = countStr
                self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(sender.tag+1)).child("USERS").child(userID).setValue("true") //very importante actually
                //decrease pending points count
                if mults9[sender.tag] == "X2" || mults9[sender.tag] == "x2" {
                    userPending -= 2
                } else {
                    userPending -= 1
                }
                //
                userPendingLabel.text = String(userPending)
                self.ref.child("AAAUSERS").child(userID).child("Pending").setValue(String(userPending))
            }
            
            updateDataCount(newCount: counts9[sender.tag], eventNum: sender.tag)
        }

    }
    
    func updateDataCount(newCount: String, eventNum: Int) {
        
        let eventNumString = String(eventNum+1)
        
        self.ref.child(self.schoolStr).child("EVENTS").child(getDate(jump: dateInt)).child("Event"+String(eventNumString)).child("Count").setValue(newCount)
        
    }
    
    func pointsSetUp() {
        
        databaseHandle = ref?.child("AAAUSERS").child(userID).child("Points").observe(.value, with: { (snapshot) in
            
            let points = snapshot.value as? String
            
            if let actualPoints = points {
                self.userPoints = Int(actualPoints)!
                //self.toGoPointSetUp(point: self.userPoints)
                self.userPointsLabel.text = String(self.userPoints)
                //self.userPointsLabel.text = actualPoints
            }
        })
        databaseHandle = ref?.child("AAAUSERS").child(userID).child("Pending").observe(.value, with: { (snapshot) in
            
            let pending = snapshot.value as? String
            
            if let actualPending = pending {
                self.userPending = Int(actualPending)!
                self.userPendingLabel.text = String(actualPending)!
                //self.userPendingLabel.text = actualPending
            }
        })
        
        self.databaseHandle = self.ref?.child("AAAUSERS").child(userID).child("School").observe(.value, with: { (snapshot) in
            
            let school = snapshot.value as? String
            
            if let actualSchool = school {
                
                self.schoolStr = actualSchool
                
                for eventNum in 1 ... 30 {
                
                    self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: -1)).child("Event" + String(eventNum)).child("USERS").child(self.userID).observe(.value, with: { (snapshot) in
                        
                        let done = snapshot.value as? String
                        
                        if let actualDone = done {
                            
                            if Bool(string:actualDone)! == false {
                                
                                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: -1)).child("Event" + String(eventNum)).child("Multiplier").observe(.value, with: { (snapshot) in
                                  
                                    let mult = snapshot.value as? String
                                    
                                    if let actualMult = mult {
                                        
                                        if actualMult == "X2" || actualMult == "x2" {
                                            self.decreaseUserPending(index: 101) //decrease two points
                                        } else {
                                            self.decreaseUserPending(index: 100) //decrease one point
                                        }
                                        
                                    }
                                    
                                    
                                })
                                
                                //self.decreaseUserPending(index: 100) //decrease one point
                                self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: -1)).child("Event"+String(eventNum)).child("USERS").child(self.userID).setValue("true")
                                
                            }
                            
                        }
                    })
                }
            }
        })
        
    }
    
    func schoolStringSetUp() {
    
        databaseHandle = ref?.child("AAAUSERS").child(userID).child("School").observe(.value, with: { (snapshot) in
            
            let school = snapshot.value as? String
            
            if let actualSchool = school {
                self.schoolStr = actualSchool
            }
        })
        
    }
    
    func schedulesSetUp() { //populate arrays for today and the next 9 days
        
        
        databaseHandle = ref?.child("AAAUSERS").child(userID).child("School").observe(.value, with: { (snapshot) in
            
            let school = snapshot.value as? String
            
            if let actualSchool = school {
                
                self.schoolStr = actualSchool
                
                // Set size of arrays for table view NEED TO KEEP
                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Count").observe(.value, with: { (snapshot) in
                    
                    let num = snapshot.value as? String
                    
                    if let actualNum = num {
                        
                        self.numEvents0 = Int(actualNum)!
                        self.scheduleTableView.reloadData()
                        
                    }
                })
                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 1)).child("Count").observe(.value, with: { (snapshot) in
                    
                    let num = snapshot.value as? String
                    
                    if let actualNum = num {
                        
                        self.numEvents1 = Int(actualNum)!
                        self.scheduleTableView.reloadData()
                        
                    }
                })
                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 2)).child("Count").observe(.value, with: { (snapshot) in
                    
                    let num = snapshot.value as? String
                    
                    if let actualNum = num {
                        
                        self.numEvents2 = Int(actualNum)!
                        self.scheduleTableView.reloadData()
                        
                    }
                })
                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 3)).child("Count").observe(.value, with: { (snapshot) in
                    
                    let num = snapshot.value as? String
                    
                    if let actualNum = num {
                        
                        self.numEvents3 = Int(actualNum)!
                        self.scheduleTableView.reloadData()
                        
                    }
                })
                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 4)).child("Count").observe(.value, with: { (snapshot) in
                    
                    let num = snapshot.value as? String
                    
                    if let actualNum = num {
                        
                        self.numEvents4 = Int(actualNum)!
                        self.scheduleTableView.reloadData()
                        
                    }
                })
                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 5)).child("Count").observe(.value, with: { (snapshot) in
                    
                    let num = snapshot.value as? String
                    
                    if let actualNum = num {
                        
                        self.numEvents5 = Int(actualNum)!
                        self.scheduleTableView.reloadData()
                        
                    }
                })
                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 6)).child("Count").observe(.value, with: { (snapshot) in
                    
                    let num = snapshot.value as? String
                    
                    if let actualNum = num {
                        
                        self.numEvents6 = Int(actualNum)!
                        self.scheduleTableView.reloadData()
                        
                    }
                })
                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 7)).child("Count").observe(.value, with: { (snapshot) in
                    
                    let num = snapshot.value as? String
                    
                    if let actualNum = num {
                        
                        self.numEvents7 = Int(actualNum)!
                        self.scheduleTableView.reloadData()
                        
                    }
                })
                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 8)).child("Count").observe(.value, with: { (snapshot) in
                    
                    let num = snapshot.value as? String
                    
                    if let actualNum = num {
                        
                        self.numEvents8 = Int(actualNum)!
                        self.scheduleTableView.reloadData()
                        
                    }
                })
                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 9)).child("Count").observe(.value, with: { (snapshot) in
                    
                    let num = snapshot.value as? String
                    
                    if let actualNum = num {
                        
                        self.numEvents9 = Int(actualNum)!
                        self.scheduleTableView.reloadData()
                        
                    }
                })
                
                for day in 0 ... 9 { //change second 0 for number of days (will be 10 in the end)
                    for event in 1 ... 30/*possibly change 10 for desired number of events per day - or maybe just do large number like 100*/ {
                        
                        let eventString = "Event" + String(event)
                        
                        if day == 0 {
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("USERS").child(self.userID).observe(.value, with: { (snapshot) in
                                
                                let selVal = snapshot.value as? String
                                
                                if let actualSelVal = selVal {
                                    
                                    self.buttonSelection0[event-1] = Bool(string: actualSelVal)!
                                    
                                } else {
                                    self.buttonSelection0[event-1] = true
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Category").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.cats0[event-1] = actualEvntName
                                    print("Events" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Count").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.counts0[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Location").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.locs0[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Name").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.names0[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Time").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.times0[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Multiplier").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.mults0[event-1] = actualEvntName
                                    print("Mults" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                        }
                        
                        if day == 1 {
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("USERS").child(self.userID).observe(.value, with: { (snapshot) in
                                
                                let selVal = snapshot.value as? String
                                
                                if let actualSelVal = selVal {
                                    
                                    self.buttonSelection1[event-1] = Bool(string: actualSelVal)!
                                    
                                } else {
                                    self.buttonSelection1[event-1] = true
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Category").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.cats1[event-1] = actualEvntName
                                    print("Events" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Count").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.counts1[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Location").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.locs1[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Name").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.names1[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Time").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.times1[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Multiplier").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.mults1[event-1] = actualEvntName
                                    print("Mults" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                        }
                        
                        if day == 2 {
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("USERS").child(self.userID).observe(.value, with: { (snapshot) in
                                
                                let selVal = snapshot.value as? String
                                
                                if let actualSelVal = selVal {
                                    
                                    self.buttonSelection2[event-1] = Bool(string: actualSelVal)!
                                    
                                } else {
                                    self.buttonSelection2[event-1] = true
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Category").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.cats2[event-1] = actualEvntName
                                    print("Events" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Count").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.counts2[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Location").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.locs2[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Name").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.names2[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Time").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.times2[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Multiplier").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.mults2[event-1] = actualEvntName
                                    print("Mults" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                        }
                        
                        if day == 3 {
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("USERS").child(self.userID).observe(.value, with: { (snapshot) in
                                
                                let selVal = snapshot.value as? String
                                
                                if let actualSelVal = selVal {
                                    
                                    self.buttonSelection3[event-1] = Bool(string: actualSelVal)!
                                    
                                } else {
                                    self.buttonSelection3[event-1] = true
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Category").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.cats3[event-1] = actualEvntName
                                    print("Events" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Count").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.counts3[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Location").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.locs3[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Name").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.names3[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Time").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.times3[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Multiplier").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.mults3[event-1] = actualEvntName
                                    print("Mults" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                        }

                        if day == 4 {
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("USERS").child(self.userID).observe(.value, with: { (snapshot) in
                                
                                let selVal = snapshot.value as? String
                                
                                if let actualSelVal = selVal {
                                    
                                    self.buttonSelection4[event-1] = Bool(string: actualSelVal)!
                                    
                                } else {
                                    self.buttonSelection4[event-1] = true
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Category").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.cats4[event-1] = actualEvntName
                                    print("Events" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Count").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.counts4[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Location").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.locs4[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Name").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.names4[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Time").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.times4[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Multiplier").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.mults4[event-1] = actualEvntName
                                    print("Mults" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                        }
                        
                        if day == 5 {
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("USERS").child(self.userID).observe(.value, with: { (snapshot) in
                                
                                let selVal = snapshot.value as? String
                                
                                if let actualSelVal = selVal {
                                    
                                    self.buttonSelection5[event-1] = Bool(string: actualSelVal)!
                                    
                                } else {
                                    self.buttonSelection5[event-1] = true
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Category").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.cats5[event-1] = actualEvntName
                                    print("Events" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Count").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.counts5[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Location").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.locs5[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Name").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.names5[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Time").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.times5[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Multiplier").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.mults5[event-1] = actualEvntName
                                    print("Mults" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                        }

                        if day == 6 {
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("USERS").child(self.userID).observe(.value, with: { (snapshot) in
                                
                                let selVal = snapshot.value as? String
                                
                                if let actualSelVal = selVal {
                                    
                                    self.buttonSelection6[event-1] = Bool(string: actualSelVal)!
                                    
                                } else {
                                    self.buttonSelection6[event-1] = true
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Category").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.cats6[event-1] = actualEvntName
                                    print("Events" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Count").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.counts6[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Location").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.locs6[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Name").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.names6[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Time").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.times6[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Multiplier").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.mults6[event-1] = actualEvntName
                                    print("Mults" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                        }

                        if day == 7 {
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("USERS").child(self.userID).observe(.value, with: { (snapshot) in
                                
                                let selVal = snapshot.value as? String
                                
                                if let actualSelVal = selVal {
                                    
                                    self.buttonSelection7[event-1] = Bool(string: actualSelVal)!
                                    
                                } else {
                                    self.buttonSelection7[event-1] = true
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Category").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.cats7[event-1] = actualEvntName
                                    print("Events" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Count").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.counts7[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Location").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.locs7[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Name").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.names7[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Time").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.times7[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Multiplier").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.mults7[event-1] = actualEvntName
                                    print("Mults" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                        }

                        if day == 8 {
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("USERS").child(self.userID).observe(.value, with: { (snapshot) in
                                
                                let selVal = snapshot.value as? String
                                
                                if let actualSelVal = selVal {
                                    
                                    self.buttonSelection8[event-1] = Bool(string: actualSelVal)!
                                    
                                } else {
                                    self.buttonSelection8[event-1] = true
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Category").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.cats8[event-1] = actualEvntName
                                    print("Events" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Count").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.counts8[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Location").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.locs8[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Name").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.names8[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Time").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.times8[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Multiplier").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.mults8[event-1] = actualEvntName
                                    print("Mults" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                        }

                        if day == 9 {
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("USERS").child(self.userID).observe(.value, with: { (snapshot) in
                                
                                let selVal = snapshot.value as? String
                                
                                if let actualSelVal = selVal {
                                    
                                    self.buttonSelection9[event-1] = Bool(string: actualSelVal)!
                                    
                                } else {
                                    self.buttonSelection9[event-1] = true
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Category").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.cats9[event-1] = actualEvntName
                                    print("Events" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Count").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.counts9[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Location").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.locs9[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Name").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.names9[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Time").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.times9[event-1] = actualEvntName
                                    print("Counts" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: day)).child(eventString).child("Multiplier").observe(.value, with: { (snapshot) in
                                
                                let evntName = snapshot.value as? String
                                
                                if let actualEvntName = evntName {
                                    
                                    self.mults9[event-1] = actualEvntName
                                    print("Mults" + String(event))
                                    self.scheduleTableView.reloadData()
                                    
                                }
                            })
                        }



                    }
                }

                
            }
        })
        
        print("schedulesSetUp RUN")

    }
    
    func nameLabelSetUp() {
        
        databaseHandle = ref?.child("AAAUSERS").child(userID).child("Name").observe(.value, with: { (snapshot) in
            
            let name = snapshot.value as? String
            
            if let actualName = name {
                
                self.nameLabel.text = actualName
                
            }
        })
        
    }
    
    func dateArraySetUp() {
        
        datePickerView.delegate = self
        datePickerView.dataSource = self
        
        for jump in 0 ... 9 {
            
            let today = Date()
            let tomorrow = Calendar.current.date(byAdding: .day, value: jump, to: today)
            let formatter = DateFormatter()
            formatter.dateFormat = "M-d-yy" // set desired date format
            let newDate = formatter.string(from: tomorrow!)
            dates.append(newDate)
        }
        
    }
    
    func getDate(jump: Int) -> String {
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: jump, to: today)
        let formatter = DateFormatter()
        formatter.dateFormat = "M-d-yy" // set desired date format
        return (formatter.string(from: tomorrow!))
    }
    
    func refreshTableView(){
        scheduleTableView.reloadData()
        //refresh.endRefreshing()
    }
    
    func internetConnectionCheck() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    
    //start checkin funcs
    func checkinFunc(eventNum: Int) {
        
        var stop = Bool()
        
        //let eventNum = eventInt//index //currentEventsIndexes[index]
        
        print("EVENT NUM: " + String(eventNum))
        
        if currentEventsIndexes[eventNum - 1] == 0 {
            createAlertView(message: "This event isn't going on right now.")
        } else if eventNum != 0 {
            
            self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("USERS").child(self.userID+"CHECKIN").observe(.value, with: { (snapshot) in
                
                let first = snapshot.value as? String
                
                if let actualFirst = first {
                    
                    if Bool(string: actualFirst)! == false { //if equals false then they haven't checked in yet
                        
                        self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("USERS").child(self.userID).observe(.value, with: { (snapshot) in
                            
                            let going = snapshot.value as? String
                            
                            if let actualGoing = going {
                                
                                if Bool(string: actualGoing)! == false { //button selected, planning on going so subtract 1 from pending
                                    
                                    self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Address").observe(.value, with: { (snapshot) in
                                        
                                        let address = snapshot.value as? String
                                        
                                        if let actualAddress = address {
                                            
                                            
                                            //self.databaseHandle = self.ref?.child("AAAUSERS").child(self.userID).child("correctLocation").observe(.value, with: { (snapshot) in
                                                
                                                //let corrLoc = snapshot.value as? String
                                                
                                                //if let actualCorrLoc = corrLoc {
                                                    
                                                    if self.correctLocations[eventNum - 1] == true /*Bool(string: actualCorrLoc)! == true *//*&& self.recheckLoc == true*/ { //in correct location
                                                        self.increaseUserPoints(index: (eventNum-1))
                                                        self.decreaseUserPending(index: (eventNum-1))
                                                        
                                                        self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Category").observe(.value, with: { (snapshot) in
                                                            
                                                            let cat = snapshot.value as? String
                                                            
                                                            if let actualCat = cat {
                                                                
                                                                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Name").observe(.value, with: { (snapshot) in
                                                                    
                                                                    let name = snapshot.value as? String
                                                                    
                                                                    if let actualName = name {
                                                                        
                                                                        self.createAlertViewWithTitle(title: "Congrats!", message: "You are checked into " + actualCat + " " + actualName + ".")
                                                                        
                                                                    }
                                                                })
                                                                
                                                                
                                                            }
                                                        })
                                                        
                                                        //self.createAlertViewWithTitle(title: "Congrats!", message: "You're checked in!")
                                                        self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("USERS").child(self.userID+"CHECKIN").setValue("true")
                                                        //set selection to true so at end of day, extra pendings aren't subtracted
                                                        self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event"+String(eventNum)).child("USERS").child(self.userID).setValue("true")
                                                        // set value so button becomes disabled
                                                        self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event"+String(eventNum)).child("USERS").child(self.userID + "DONE").setValue("true")
                                                        // reset correctLocation variable to false
                                                        //self.ref.child("AAAUSERS").child(self.userID).child("correctLocation").setValue("false")
                                                        
                                                        stop = true
                                                        return
                                                        
                                                    } else if self.correctLocations[eventNum - 1] == false /*Bool(string: actualCorrLoc)! == false */ /*&& self.recheckLoc == true*/ { //in wrong location
                                                        
                                                        self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Category").observe(.value, with: { (snapshot) in
                                                            
                                                            let cat = snapshot.value as? String
                                                            
                                                            if let actualCat = cat {
                                                                
                                                                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Name").observe(.value, with: { (snapshot) in
                                                                    
                                                                    let name = snapshot.value as? String
                                                                    
                                                                    if let actualName = name {
                                                                        
                                                                        self.createAlertView(message: "You are in the wrong location. The address for " + actualCat + " " + actualName + " is " + actualAddress + ".")
                                                                        
                                                                    }
                                                                })
                                                                
                                                                
                                                            }
                                                        })
                                                        stop = true
                                                        return
                                                        //self.createAlertView(message: "You are in the wrong location. The address for this event is " + actualAddress + ".")
                                                    }
                                                    
                                                //}
                                            //})
                                            
                                        }
                                    })
                                    
                                    
                                } else if Bool(string: actualGoing)! == true && stop != true { //tapped the button, but were no longer planning on going so don't subtract 1 from pending
                                    
                                    self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Address").observe(.value, with: { (snapshot) in
                                        
                                        let address = snapshot.value as? String
                                        
                                        if let actualAddress = address {
                                            
                                            //self.locationCheck(locName: actualAddress)
                                            
                                            //self.databaseHandle = self.ref?.child("AAAUSERS").child(self.userID).child("correctLocation").observe(.value, with: { (snapshot) in
                                                
                                                //let corrLoc = snapshot.value as? String
                                                
                                                //if let actualCorrLoc = corrLoc {
                                                    
                                                    if self.correctLocations[eventNum - 1] == true /*Bool(string: actualCorrLoc)! == true */ /*&& self.recheckLoc == true*/ { //in correct location
                                                        self.increaseUserPoints(index: (eventNum - 1))
                                                        
                                                        //add one to event count to make up for lack of planning
                                                        self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Count").setValue(String(Int(self.counts0[eventNum - 1])! + 1))
                                                        
                                                        
                                                        self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Category").observe(.value, with: { (snapshot) in
                                                            
                                                            let cat = snapshot.value as? String
                                                            
                                                            if let actualCat = cat {
                                                                
                                                                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Name").observe(.value, with: { (snapshot) in
                                                                    
                                                                    let name = snapshot.value as? String
                                                                    
                                                                    if let actualName = name {
                                                                        
                                                                        self.createAlertViewWithTitle(title: "Congrats!", message: "You are checked into " + actualCat + " " + actualName + ".")
                                                                        
                                                                    }
                                                                })
                                                                
                                                                
                                                            }
                                                        })
                                                        
                                                        //self.createAlertViewWithTitle(title: "Congrats!", message: "You're checked in!")
                                                        self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("USERS").child(self.userID+"CHECKIN").setValue("true")
                                                        //set selection to true so at end of day, extra pendings aren't subtracted
                                                        self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event"+String(eventNum)).child("USERS").child(self.userID).setValue("true")
                                                        // set value so button becomes disabled
                                                        self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event"+String(eventNum)).child("USERS").child(self.userID + "DONE").setValue("true")
                                                        // reset correctLocation variable to false
                                                        //self.ref.child("AAAUSERS").child(self.userID).child("correctLocation").setValue("false")
                                                        
                                                        stop = true
                                                        return
                                                        
                                                    } else if self.correctLocations[eventNum - 1] == false /*Bool(string: actualCorrLoc)! == false*/ /*&& self.recheckLoc == true*/ { //in wrong location
                                                        
                                                        self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Category").observe(.value, with: { (snapshot) in
                                                            
                                                            let cat = snapshot.value as? String
                                                            
                                                            if let actualCat = cat {
                                                                
                                                                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Name").observe(.value, with: { (snapshot) in
                                                                    
                                                                    let name = snapshot.value as? String
                                                                    
                                                                    if let actualName = name {
                                                                        
                                                                        self.createAlertView(message: "You are in the wrong location. The address for " + actualCat + " " + actualName + " is " + actualAddress + ".")
                                                                        
                                                                    }
                                                                })
                                                                
                                                                
                                                            }
                                                        })
                                                        stop = true
                                                        return
                                                        //self.createAlertView(message: "You are in the wrong location. The address for this event is " + actualAddress + ".")
                                                    }
                                                    
                                                //}
                                            //})
                                            
                                        }
                                    })
                                    
                                }
                            }
                        })
                        
                        
                    } else if Bool(string: actualFirst)! == true && stop != true { //if equals true then they already checked in
                        
                        self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Category").observe(.value, with: { (snapshot) in
                            
                            let cat = snapshot.value as? String
                            
                            if let actualCat = cat {
                                
                                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Name").observe(.value, with: { (snapshot) in
                                    
                                    let name = snapshot.value as? String
                                    
                                    if let actualName = name {
                                        
                                        self.createAlertViewWithTitle(title: "Sorry", message: "You already checked into " + actualCat + " " + actualName + ". You can only check into each event once.")
                                        
                                    }
                                })
                                
                                stop = true
                                return
                            }
                        })
                        
                    }
                    
                } else { //no value present - was never planning on coming but is checking in anyway
                    
                    self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("USERS").child(self.userID+"CHECKIN").setValue("true")
                    
                    self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Address").observe(.value, with: { (snapshot) in
                        
                        let address = snapshot.value as? String
                        
                        if let actualAddress = address {
                            
                            //self.locationCheck(locName: actualAddress)
                            
                            //self.databaseHandle = self.ref?.child("AAAUSERS").child(self.userID).child("correctLocation").observe(.value, with: { (snapshot) in
                                
                                //let corrLoc = snapshot.value as? String
                                
                                //if let actualCorrLoc = corrLoc {
                                    
                                    if self.correctLocations[eventNum - 1] == true /*Bool(string: actualCorrLoc)! == true */ /*&& self.recheckLoc == true*/ { //in correct location
                                        self.increaseUserPoints(index: (eventNum - 1))
                                        
                                        //add one to event count to make up for lack of planning
                                        self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Count").setValue(String(Int(self.counts0[eventNum - 1])! + 1))
                                        
                                        self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Category").observe(.value, with: { (snapshot) in
                                            
                                            let cat = snapshot.value as? String
                                            
                                            if let actualCat = cat {
                                                
                                                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Name").observe(.value, with: { (snapshot) in
                                                    
                                                    let name = snapshot.value as? String
                                                    
                                                    if let actualName = name {
                                                        
                                                        self.createAlertViewWithTitle(title: "Congrats!", message: "You are checked into " + actualCat + " " + actualName + ".")
                                                        
                                                    }
                                                })
                                                
                                                
                                            }
                                        })
                                            
                                        //self.createAlertViewWithTitle(title: "Congrats!", message: "You're checked in!")
                                        self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("USERS").child(self.userID+"CHECKIN").setValue("true")
                                        //set selection to true so at end of day, extra pendings aren't subtracted
                                        self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event"+String(eventNum)).child("USERS").child(self.userID).setValue("true")
                                        // set value so button becomes disabled
                                        self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event"+String(eventNum)).child("USERS").child(self.userID + "DONE").setValue("true")
                                        // reset correctLocation variable to false
                                        //self.ref.child("AAAUSERS").child(self.userID).child("correctLocation").setValue("false")
                                        
                                        stop = true
                                        return
                                        
                                    } else if self.correctLocations[eventNum - 1] == false /*Bool(string: actualCorrLoc)! == false */ /*&& self.recheckLoc == true*/ { //in wrong location
                                        
                                        self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Category").observe(.value, with: { (snapshot) in
                                            
                                            let cat = snapshot.value as? String
                                            
                                            if let actualCat = cat {
                                                
                                                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("Name").observe(.value, with: { (snapshot) in
                                                    
                                                    let name = snapshot.value as? String
                                                    
                                                    if let actualName = name {
                                                        
                                                        self.createAlertView(message: "You are in the wrong location. The address for " + actualCat + " " + actualName + " is " + actualAddress + ".")
                                                        
                                                    }
                                                })
                                                
                                                
                                            }
                                        })
                                        stop = true
                                        return
                                        //self.createAlertView(message: "You are in the wrong location.")
                                    }
                                    
                                //}
                            //})
                            
                        }
                    })
                    
                }
            })
            //self.ref.child("AAAUSERS").child(self.userID).child("correctLocation").setValue(String("false"))
            //self.correctLoc = true /*Bool(string: actualCorrLoc)! == true */
            return
        } else {
            return
        }
        
    }
    
    func increaseTodayEventCount(eventNumber: Int, currentCount: Int) {
        var newCount = currentCount
        
        newCount += 1
        
        self.ref.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNumber)).child("Count").setValue(String(newCount))
    }
    
    /*func toGoPointSetUp(point: Int) {
        
        var toGoPoints = 0
        
        if point < 5 {
        toGoPoints = 5 - point
        }
        else if point < 10 {
            toGoPoints = 10 - point
        }
        else if point < 15 {
            toGoPoints = 15 - point
        }
        else if point < 20 {
            toGoPoints = 20 - point
        }
        else if point < 25 {
            toGoPoints = 25 - point
        }
        else if point < 30 {
            toGoPoints = 30 - point
        }
        else if point < 35 {
            toGoPoints = 35 - point
        }
        else if point < 40 {
            toGoPoints = 40 - point
        }
        else if point < 45 {
            toGoPoints = 45 - point
        }
        else if point < 50 {
            toGoPoints = 50 - point
        }
        else {
            userToGoLabel.text = "😄"
            return
        }
        
        
        userToGoLabel.text = String(toGoPoints)
        
    }*/
    
    func increaseUserPoints(index: Int) {
        
        if dateInt == 0 {
            
            if mults0[index] == "x2" || mults0[index] == "X2" {
                self.userPoints += 2
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            } else {
                self.userPoints += 1
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            }
            
        }
        if dateInt == 1 {
            
            if mults1[index] == "x2" || mults1[index] == "X2" {
                self.userPoints += 2
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            } else {
                self.userPoints += 1
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            }
            
        }
        if dateInt == 2 {
            
            if mults2[index] == "x2" || mults2[index] == "X2" {
                self.userPoints += 2
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            } else {
                self.userPoints += 1
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            }
            
        }
        if dateInt == 3 {
            
            if mults3[index] == "x2" || mults3[index] == "X2" {
                self.userPoints += 2
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            } else {
                self.userPoints += 1
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            }
            
        }
        if dateInt == 4 {
            
            if mults4[index] == "x2" || mults4[index] == "X2" {
                self.userPoints += 2
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            } else {
                self.userPoints += 1
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            }
            
        }
        if dateInt == 5 {
            
            if mults5[index] == "x2" || mults5[index] == "X2" {
                self.userPoints += 2
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            } else {
                self.userPoints += 1
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            }
            
        }
        if dateInt == 6 {
            
            if mults6[index] == "x2" || mults6[index] == "X2" {
                self.userPoints += 2
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            } else {
                self.userPoints += 1
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            }
            
        }
        if dateInt == 7 {
            
            if mults7[index] == "x2" || mults7[index] == "X2" {
                self.userPoints += 2
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            } else {
                self.userPoints += 1
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            }
            
        }
        if dateInt == 8 {
            
            if mults8[index] == "x2" || mults8[index] == "X2" {
                self.userPoints += 2
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            } else {
                self.userPoints += 1
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            }
            
        }
        if dateInt == 9 {
            
            if mults9[index] == "x2" || mults9[index] == "X2" {
                self.userPoints += 2
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            } else {
                self.userPoints += 1
                self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                print(String(self.userPoints))
            }
            
        }
        /*self.userPoints += 1
        self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
        print(String(self.userPoints))*/
        
        
    }
    func decreaseUserPending(index: Int){
        
        if index == 100 {
            
            self.userPending -= 1
            self.ref.child("AAAUSERS").child(self.userID).child("Pending").setValue(String(self.userPending))
            print(String(self.userPending))
            
        } else if index == 101 {
            
            self.userPending -= 2
            self.ref.child("AAAUSERS").child(self.userID).child("Pending").setValue(String(self.userPending))
            print(String(self.userPending))
            
        } else {
        
            if dateInt == 0 {
                
                if mults0[index] == "x2" || mults0[index] == "X2" {
                    self.userPending -= 2
                    self.ref.child("AAAUSERS").child(self.userID).child("Pending").setValue(String(self.userPending))
                    print(String(self.userPending))
                } else {
                    self.userPending -= 1
                    self.ref.child("AAAUSERS").child(self.userID).child("Pending").setValue(String(self.userPending))
                    print(String(self.userPending))
                }
                
            }
            if dateInt == 1 {
                
                if mults1[index] == "x2" || mults1[index] == "X2" {
                    self.userPoints -= 2
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                } else {
                    self.userPoints -= 1
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                }
                
            }
            if dateInt == 2 {
                
                if mults2[index] == "x2" || mults2[index] == "X2" {
                    self.userPoints -= 2
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                } else {
                    self.userPoints -= 1
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                }
                
            }
            if dateInt == 3 {
                
                if mults3[index] == "x2" || mults3[index] == "X2" {
                    self.userPoints -= 2
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                } else {
                    self.userPoints -= 1
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                }
                
            }
            if dateInt == 4 {
                
                if mults4[index] == "x2" || mults4[index] == "X2" {
                    self.userPoints -= 2
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                } else {
                    self.userPoints -= 1
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                }
                
            }
            if dateInt == 5 {
                
                if mults5[index] == "x2" || mults5[index] == "X2" {
                    self.userPoints -= 2
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                } else {
                    self.userPoints -= 1
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                }
                
            }
            if dateInt == 6 {
                
                if mults6[index] == "x2" || mults6[index] == "X2" {
                    self.userPoints -= 2
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                } else {
                    self.userPoints -= 1
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                }
                
            }
            if dateInt == 7 {
                
                if mults7[index] == "x2" || mults7[index] == "X2" {
                    self.userPoints -= 2
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                } else {
                    self.userPoints -= 1
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                }
                
            }
            if dateInt == 8 {
                
                if mults8[index] == "x2" || mults8[index] == "X2" {
                    self.userPoints -= 2
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                } else {
                    self.userPoints -= 1
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                }
                
            }
            if dateInt == 9 {
                
                if mults9[index] == "x2" || mults9[index] == "X2" {
                    self.userPoints -= 2
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                } else {
                    self.userPoints -= 1
                    self.ref.child("AAAUSERS").child(self.userID).child("Points").setValue(String(self.userPoints))
                    print(String(self.userPoints))
                }
                
            }

            /*self.userPending -= 1
             self.ref.child("AAAUSERS").child(self.userID).child("Pending").setValue(String(self.userPending))
             print(String(self.userPending))*/
        }
    }
    
    func arraysSetUp() {
        
        databaseHandle = ref?.child("AAAUSERS").child(userID).child("School").observe(.value, with: { (snapshot) in
            
            let school = snapshot.value as? String
            
            if let actualSchool = school {
                
                self.schoolStr = actualSchool
                
                for event in 1 ... 30/*possibly change 30 for desired number of events per day - or maybe just do large number like 100*/ {
                    
                    let eventString = "Event" + String(event)
                    
                    self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child(eventString).child("Duration").observe(.value, with: { (snapshot) in
                        
                        let dur = snapshot.value as? String
                        
                        if let actualDur = dur {
                            
                            self.durations[event-1] = Int(actualDur)!
                            
                        }
                        
                    })
                    self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child(eventString).child("Time").observe(.value, with: { (snapshot) in
                        
                        let time = snapshot.value as? String
                        
                        if let actualTime = time {
                            
                            self.startTimes[event-1] = actualTime
                            
                        }
                        
                    })
                    self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child(eventString).child("Address").observe(.value, with: { (snapshot) in
                        
                        let add = snapshot.value as? String
                        
                        if let actualAdd = add {
                            
                            //print("working")
                            self.addresses[event-1] = actualAdd
                            
                            self.endTimes[event-1] = self.getEndTime(start: self.startTimes[event-1], jump: self.durations[event-1])
                            if self.timeCheck(startTime: self.startTimes[event-1], endTime: self.endTimes[event-1]) {
                                self.currentEventsIndexes[event-1/**/] = event
                                
                                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child(eventString).child("Category").observe(.value, with: { (snapshot) in
                                    
                                    let cat = snapshot.value as? String
                                    
                                    if let actualCat = cat {
                                        
                                        self.currentEventsCats[event-1/**/] = actualCat
                                        print("CURRENT EVENT: " + actualCat + " ACTUAL: " + self.currentEventsCats[event-1/**/])
                                        //self.currentEventPickerView.reloadAllComponents()
                                        
                                    }
                                })
                                
                                
                                
                            }
                            
                        }
                        
                    })
                    //NEW IMPORTANT
                    self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child(eventString).child("Address").observe(.value, with: { (snapshot) in
                        
                        let address = snapshot.value as? String
                        
                        if let actualAddress = address {
                            
                            self.locationCheck(locName: actualAddress, eventNum: event)
                            //print("LOC CHECK: "  + String(self.correctLoc))
                        }
                    })
                    
                    
                    
                }
            }
            
        })
    }
    
    func getTime(jump: Int) -> String {
        let date = Date()
        let future = Calendar.current.date(byAdding: .hour, value: jump, to: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return (dateFormatter.string(from: future!))
    }
    func getEndTime(start: String, jump: Int) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let startDateTime = dateFormatter.date(from: start)
        
        //let date = Date()
        let future = Calendar.current.date(byAdding: .hour, value: jump, to: startDateTime!)
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "h:mm a"
        return (dateFormatter.string(from: future!))
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        //coordinatesLabel.text = "Coordinates: "+String(location.coordinate.latitude)+", "+String(location.coordinate.longitude)
        
        //var latMax = location.coordinate.latitude + 10
        //addressLabel.text = String(latMax)
        
        //let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        //let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        //let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        //map.setRegion(region, animated: false)
        
        //self.map.showsUserLocation = true
        
        userLat = location.coordinate.latitude
        userLong = location.coordinate.longitude
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemark, error) in
            if error != nil{
                //there was an error
                print("there was an error")
            }/* else {
                
                if let place = placemark?[0] {
                    
                    //self.userPlaceName = place.name!
                    //self.userAddress = place.subThoroughfare! + " " + place.thoroughfare!
                    
                    
                }
                
            }*/
        }
        
        
    }
    func locationCheck(locName: String, eventNum: Int) {
        
        var latBool = Bool()
        var longBool = Bool()
        
        var lat = Double()
        var long = Double()
        
        CLGeocoder().geocodeAddressString(locName) { (placemark, error) in
            
            guard
                let placemarks = placemark,
                let location = placemarks.first?.location
                
                else {
                    // handle no location found
                    //self.createAlertView(message: "No location found.")
                    return
            }
            
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
            
            let latMin = lat - 0.0025
            let latMax = lat + 0.0025
            let longMin = long - 0.0025
            let longMax = long + 0.0025
            
            print("latMin: " + String(latMin))
            print("latMax: " + String(latMax))
            print("longMin: " + String(longMin))
            print("longMax: " + String(longMax))
            print("userLat: " + String(self.userLat))
            print("userLong: " + String(self.userLong))
            
            if self.userLat >= latMin && self.userLat <= latMax {
                latBool = true
            } else { latBool = false }
            if self.userLong >= longMin && self.userLong <= longMax {
                longBool = true
            } else { longBool = false }
            
            print("latbool " + String(latBool))
            print("longbool " + String(longBool))
            
            self.correctLoc = latBool && longBool
            
            if self.correctLoc == false {
                //create error
                self.correctLocations[eventNum - 1] = false
                print("wrong location" + String(self.correctLoc) + "ARRAY: " + String(self.correctLocations[eventNum - 1]))
                
            }
            if self.correctLoc == true {
                self.correctLocations[eventNum - 1] = true
                print("correct location" + String(self.correctLoc) + "ARRAY: " + String(self.correctLocations[eventNum - 1]))
            }
            
            
        }
        
        
    }
    func timeCheck(startTime: String, endTime: String) -> Bool {
        
        var inRange = Bool()
        
        //date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        // Get current time and format it to compare
        var currentTime = Date()
        let currentTimeStr = dateFormatter.string(from: currentTime)
        currentTime = dateFormatter.date(from: currentTimeStr)!
        
        
        let startDateTime = dateFormatter.date(from: startTime)
        let endDateTime = dateFormatter.date(from: endTime)
        
        
        if currentTime >= startDateTime! && currentTime <= endDateTime! {
            inRange = true
        } else {
            inRange = false
        }
        
        return inRange
    }
    func firstTimeCheck(eventNum: Int) -> Bool {
        var firstTime = Bool()
        
        databaseHandle = ref?.child(self.userID).child("School").observe(.value, with: { (snapshot) in
            
            let school = snapshot.value as? String
            
            if let actualSchool = school {
                
                self.schoolStr = actualSchool
                
                self.databaseHandle = self.ref?.child(self.schoolStr).child("EVENTS").child(self.getDate(jump: 0)).child("Event" + String(eventNum)).child("USERS").child(self.userID+"CHECKIN").observe(.value, with: { (snapshot) in
                    
                    let first = snapshot.value as? String
                    
                    if let actualFirst = first {
                        firstTime = Bool(string: actualFirst)!
                    }
                })
                
            }
        })
        
        return firstTime
    }
    
    func createAlertView (message: String) {
        
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    func createAlertViewWithTitle (title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    //end checkin funcs
    
    func testFunction() {
        print("TEST FUNCTION: working")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
