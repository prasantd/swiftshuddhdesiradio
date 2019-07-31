//
//  LeftViewController.swift
//  Shuddh Desi Radio
//
//  Created by AtlantaLoaner2 on 6/20/19.
//  Copyright © 2019 Shuddh Desi Radio. All rights reserved.
//

import UIKit


class LeftViewController: UIViewController {

    @IBOutlet weak var VersionLabel: UILabel!
    @IBAction func CloseWindow(_ sender: Any) {
        // Access an instance of AppDelegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Reference drawerContainer object declared inside of AppDelegate and call toggleDrawerSide function on it
        appDelegate.drawerController?.closeDrawer(animated: true, completion: nil
        )
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        printVersion()

        // Do any additional setup after loading the view.
    }
    
    func printVersion()
    {
        let version : String! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build : String! = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        VersionLabel.text = "Version: " + build + "(" + version + ")"
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
