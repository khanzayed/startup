//
//  ReportTypeDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 16/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Alamofire

class ReportTypeDataModal: AppDataModal {
    
    var repostTypesList:[ReportType]?
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseArr {
            repostTypesList = [ReportType]()
            for reportType in responseDict {
                var reportTypeModal = ReportType()
                reportTypeModal.reportTypeId = reportType["report_type_id"] as? Int
                reportTypeModal.title = reportType["title"] as? String
                reportTypeModal.otherReason = reportType["other_reason"] as? String
        
                if let subReports = reportType["sub_reports"] as? [[String:Any]] {
                    if subReports.count > 0 {
                        var subReportList = [SubReports]()
                        for subReport in subReports {
                            var subReportModal = SubReports()
                            subReportModal.reportTypeId = subReport["report_type_id"] as? Int
                            subReportModal.title = subReport["title"] as? String
                            subReportList.append(subReportModal)
                        }
                        reportTypeModal.subReports = subReportList
                    }
                }
                repostTypesList?.append(reportTypeModal)
            }
        }
        
    }
}

struct ReportType {
    
    var reportTypeId:Int?
    var title:String?
    var otherReason:String?
    var subReports:[SubReports]?
    
}

struct SubReports {
    
    var reportTypeId: Int?
    var title:String?
}
