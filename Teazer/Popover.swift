//
//  Popover.swift
//  Teazer
//
//  Created by Faraz Habib on 16/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import UIKit

class Popover {
    
    func showPopoverReportTypesListViewController(_ dataSource:[ReportType], controller:UIViewController, completionBlock: @escaping (ReportType) -> Void) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
            let popoverContent = storyboard.instantiateViewController(withIdentifier: "ReportListViewController") as! ReportListViewController
            popoverContent.reportTypesList = dataSource
            //popoverContent.reportTypeSelectedBlock = completionBlock
            
            let nav = UINavigationController(rootViewController: popoverContent)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .popover
            
            let popover = nav.popoverPresentationController!
            popoverContent.preferredContentSize = CGSize(width: 300, height: 300)
            popover.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
            popover.sourceView = controller.view
            popover.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
            
            controller.present(nav, animated: true, completion: nil)
        }
    }
    
}
