//
//  PAError.swift
//  PANetwork
//
//  Created by lichao_liu on 2018/2/27.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit

class PAError: Error {
    static let commonErrorMessage = "数据加载失败，请稍后重试"
    var errorCode: String = "0"
    var errorMessage: String?
    var isRequestCanceled = false
    init(statusCode: String? = "0") {
        if let statusCode = statusCode {
            self.errorCode = statusCode
        } else {
            self.errorCode = "0"
        }
    }
    
    init(statusCode: String? = "0", errorMessage: String?) {
        if let statusCode = statusCode {
            self.errorCode = statusCode
        } else {
            self.errorCode = "0"
        }
        self.errorMessage = errorMessage
    }
}
