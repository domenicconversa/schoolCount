//
//  TermsConditionsViewController.swift
//  counts
//
//  Created by Domenic Conversa on 7/27/17.
//  Copyright © 2017 DomenicConversa. All rights reserved.
//

import UIKit

class TermsConditionsViewController: UIViewController {

    @IBOutlet weak var termsWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://termsfeed.com/terms-conditions/a733d8df588f680c6a6851e5f386d025")
        termsWebView.loadRequest(URLRequest(url: url!))
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
