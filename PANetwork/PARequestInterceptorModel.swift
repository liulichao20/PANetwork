//
//  PARequestInterceptorModel.swift
//  PANetwork
//
//  Created by lichao_liu on 2018/3/5.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit

class PARequestInterceptorModel: PARequestInterceptor {
    func requestInterceptor(request: PARequest) {
         //请求拦截
        if request.requestMethod == .post {
            
        }else {
            //添加到url上
            
        }
    }
}
