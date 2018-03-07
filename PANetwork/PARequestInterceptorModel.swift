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
        let dict = ["version":"1.1.1","time":"2016.1.1"]
        //请求拦截
        if request.requestMethod == .post {
            if !dict.isEmpty && request.requestParams == nil {
                request.requestParams = [:]
            }
            for (key,value) in dict {
                request.requestParams?.updateValue(key, forKey: value)
            }
        }else {
            //添加到url上
            var requestUrl:String = request.requestUrl ?? ""
            var array:[String] = []
            for (key,value) in dict {
                array.append("\(encode(key: key))=\(encode(key: value))")
            }
            let compStr = array.joined(separator: "&")
            
            if !requestUrl.isEmpty {
                if let url = URL(string: requestUrl),url.scheme != nil ,url.host != nil {
                    //添加到requesturl上
                    print(url.absoluteString)
                }else {
                    //baseurl + requesturl
                    if let renativeUrl = URL(string: requestUrl, relativeTo: URL(string: PANetworkConfig.default.baseUrl ?? "")) {
                        requestUrl = renativeUrl.absoluteString
                    }
                }
            }else {
                requestUrl = PANetworkConfig.default.baseUrl ?? ""
            }
            var component = URLComponents(string: requestUrl)
            if let query = component?.query {
                component?.query = "\(query)&\(compStr)"
            }else {
                component?.query = compStr
            }
            request.requestUrl = component?.url?.absoluteString ?? ""
        }
    }
    
    func encode(key:String)->String {
        return key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
    }
}
