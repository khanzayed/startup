 //
//  BaseViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 14/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (User().getAuthToken() != nil) ? launchHomePage() : launchBaseLoginPage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func launchHomePage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabbarCntrlr = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        tabbarCntrlr.selectedIndex = TabbarControllerIndex.kHomeVCIndex.rawValue
        self.navigationController?.pushViewController(tabbarCntrlr, animated: true)
    }

    func launchBaseLoginPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let baseLoginVC = storyboard.instantiateViewController(withIdentifier: "BaseLoginViewController") as! BaseLoginViewController
        self.navigationController?.pushViewController(baseLoginVC, animated: true)
    }
    
}
