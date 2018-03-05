//
//  PANetworkConfig.swift
//  PANetwork
//
//  Created by lichao_liu on 2018/2/27.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit

class PANetworkConfig: NSObject {
    var baseUrl:String?//基本url
    var requestTimeoutInterval:TimeInterval = 60//超时时间
    var defaultHTTPHeaders:[String:String] = {//请求头
        let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
            }.joined(separator: ", ")
        // Example: `iOS Example/1.0 ; build:1; iOS 10.0.0)`
        let userAgent: String = {
            if let info = Bundle.main.infoDictionary {
                let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
                let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
                let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
                
                let osNameVersion: String = {
                    let version = ProcessInfo.processInfo.operatingSystemVersion
                    let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
                    let osName: String = "iOS"
                    return "\(osName) \(versionString)"
                }()
                return "\(executable)/\(appVersion); build:\(appBuild); \(osNameVersion))"
            }
            return "newwork"
        }()
        return [
            "Accept-Language": acceptLanguage,
            "User-Agent": userAgent
        ]
    }()
    
    var securityPolicy = PASecurityPolicy()//安全策略
    var requestInterceptor:PARequestInterceptor?//请求拦截器 统一处理
    var responseInterceptor:PAResponseInterceptor?//响应拦截器 统一处理
    
    static let `default`:PANetworkConfig = {
       let config = PANetworkConfig()
        return config
    }()
}

protocol PARequestInterceptor {
    func requestInterceptor(request:PARequest)//对请求进行处理
}

protocol PAResponseInterceptor {
    func responseInterceptor(response:PAResponse)//对响应的结果进行处理
}
