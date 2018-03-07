//
//  PAResponseInterceptorModel.swift
//  PANetwork
//
//  Created by lichao_liu on 2018/3/2.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit

class PAResponseInterceptorModel: PAResponseInterceptor {
    func responseInterceptor(response: PAResponse) {
        if response.isRequestSuccess {
            //通用的拦截
            //解析model
            if let _ = response.responseObject {
                if let _ = response.responseDic {
                    response.isResponseSuccess = true
                }
            }
        }
    }
}
