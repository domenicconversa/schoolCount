//
//  TestViewController.swift
//  counts
//
//  Created by Domenic Conversa on 6/24/17.
//  Copyright © 2017 DomenicConversa. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var titles = ["One", "Two", "Three"]
    var images = ["Combined Shape Copy 3", "Combined Shape", "Combined Shape Copy 3"]
    var detailImages = ["Oval 6", "RightArrowWHITE", "Oval 6"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        images[1] = "Combined Shape"
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "testcell", for: indexPath) as! TestTableViewCell
        
        cell.titleLabel.text = titles[(indexPath as NSIndexPath).row]
        
        cell.backgroundImage.image = UIImage(named: images[(indexPath as NSIndexPath).row])!
        cell.detailImage.image = UIImage(named: detailImages[(indexPath as NSIndexPath).row])!
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let checkinAction = UITableViewRowAction(style: .normal, title: "                      ") { (action, indexPath) in
            return
        }
        checkinAction.backgroundColor = UIColor(patternImage: UIImage(named: "slideout image")!)
        //checkinAction.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return [checkinAction]
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
