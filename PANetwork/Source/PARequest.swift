//
//  PARequest.swift
//  PANetwork
//
//  Created by lichao_liu on 2018/2/27.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit
import AFNetworking

enum PARequestMethod:String {
    case get = "GET"
    case post = "POST"
    case head = "HEAD"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
}

enum PARequestSerializerType:Int {
    case http,json
}

enum PAResponseSerializerType:Int {
    case http,json
}
enum PARequestPriorityType {
    case priorityHigh,priorityLow,priorityDefault
}

class PARequest {
    typealias PARequestCompletionBlock = (_ response: PAResponse) -> Void//成功或者失败block
    typealias PAConstructingBodyBlock = (_ formData: AFMultipartFormData) -> Void//文件上传block
    typealias PAHudBlock = (_ isShowHud:Bool)->Void
    
    var requestUrl:String?//可以是相对地址，也可以是绝对地址
    var requestTimeOut:TimeInterval?//每次请求超时时间 默认是config配置的60s
    var requestParams:[String:Any]?
    var requestMethod:PARequestMethod = .post
    var requestSerial:PARequestSerializerType = .http
    var requestTask:URLSessionTask?
    var completionBlock:PARequestCompletionBlock?
    var delegate:PARequestDelegate?
    var constructingBodyBlock:PAConstructingBodyBlock?
    var hudBlock:PAHudBlock?
    var requestPriority:PARequestPriorityType = .priorityDefault
    var requestAuthorizationHeaderField:(username:String,password:String)?
    var requestHttpHeaderFields:[String:String]?
    var needRequestInterceptor:Bool = true
    var needResponseInterceptor:Bool = true
    var shouldAutoEncodeUrl:Bool = false
    
    var requestInterceptor:PARequestInterceptor?//请求拦截器
    var responseInterceptor:PAResponseInterceptor?//响应拦截器
    
    func start() {
        isShowHud(showFlag: true)
        PANetworkManager.default.addRequest(request: self)
    }
    
    func isShowHud(showFlag:Bool) {
        if let block = hudBlock {
            block(showFlag)
        }
    }
    
    func setConstructingBodyBlock(image:UIImage,quality:CGFloat = 0.5) {
        let data = UIImageJPEGRepresentation(image, quality)
        self.constructingBodyBlock = {
            formData in
            formData.appendPart(withFileData: data!, name: "image", fileName: "image", mimeType: "image/jpeg")
        }
    }
    
    func stop() {
        PANetworkManager.default.cancelRequest(request: self)
    }
    
    func clearCompletionBlock() {
        completionBlock = nil
        constructingBodyBlock = nil
        delegate = nil
    }
}

extension PARequest {
    @discardableResult
    class func start(method:PARequestMethod = .post,requestUrl:String?,image:UIImage? = nil,quality:CGFloat = 0.5,requestParams:[String:Any]? = nil,hudBlock:PAHudBlock? = nil,completionBlock:PARequestCompletionBlock? = nil)->PARequest {
        let request = PARequest()
        request.requestParams = requestParams
        request.requestUrl = requestUrl
        request.requestMethod = method
        request.hudBlock = hudBlock
        request.completionBlock = completionBlock
        if image != nil {
            request.setConstructingBodyBlock(image: image!, quality: quality)
        }
        request.start()
        return request
    }
}


protocol PARequestDelegate {
    func requestFinished(_ request:PARequest,response:PAResponse)
    func requestFailured(_ request:PARequest,response:PAResponse)
}
