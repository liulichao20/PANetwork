//
//  PAResponse.swift
//  PANetwork
//
//  Created by lichao_liu on 2018/2/27.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit

class PAResponse:NSObject {
    var urlResponse:URLResponse?
    var responseObject:Any?
    var error:PAError?
    var isResponseSuccess:Bool = false
    var isRequestSuccess:Bool = false
    
    init(urlResponse:URLResponse? = nil,responseObject:Any? = nil,error:Error? = nil) {
        super.init()
        self.urlResponse = urlResponse
        self.responseObject = responseObject
        if let urlResponse = urlResponse as? HTTPURLResponse  {
            if !(urlResponse.statusCode >= 200 && urlResponse.statusCode <= 299) {
                self.error = PAError(statusCode: "\(urlResponse.statusCode)", errorMessage: PAError.commonErrorMessage)
            }
        }else if error != nil {
            self.error = PAError(errorMessage: PAError.commonErrorMessage)
        }
        if self.error != nil {
            isRequestSuccess = true
        }
    }
    
    lazy var responseString: String? = {
        if let object = self.responseObject as? Data {
            return String(data: object, encoding: String.Encoding.utf8)
        }else if let str = self.responseObject as? String{
            return str
        }
        return nil
    }()
    
    lazy var responseDic: [String: Any]? = {
        guard let response = self.responseObject else {
            return nil
        }
        var responseDic: [String: Any] = [:]
        if response is Data {
            if let dict = try? JSONSerialization.jsonObject(with: response as! Data, options: .mutableContainers),dict is [String: Any] {
                if let dic = dict as? [String: Any] {
                    responseDic = dic
                }
            }
        } else if response is [String: Any] {
            if let dic = response as? [String: Any] {
                responseDic = dic
            }
        }
        return responseDic
    }()
}
