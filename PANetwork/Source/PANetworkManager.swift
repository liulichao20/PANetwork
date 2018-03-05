//
//  PANetworkManager.swift
//  PANetwork
//
//  Created by lichao_liu on 2018/2/27.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit
import AFNetworking

class PANetworkManager {
    
    var manager:AFHTTPSessionManager!
    static let `default`:PANetworkManager = {
        let manager:PANetworkManager = PANetworkManager()
        return manager
    }()
    var lock:NSRecursiveLock = NSRecursiveLock()
    var requestRecords:[Int:PARequest] = [:]
    var allStatusCodes:IndexSet = IndexSet(integersIn: Range(NSMakeRange(100, 500))!)
    let networkConfig = PANetworkConfig.default
    
    init() {
        let config = URLSessionConfiguration()
        config.timeoutIntervalForRequest = networkConfig.requestTimeoutInterval
        config.httpAdditionalHeaders = networkConfig.defaultHTTPHeaders
        
        var policy:AFSecurityPolicy
        if let data = networkConfig.securityPolicy.useCertificate,let set = NSSet.init(object: data) as? Set<Data>{
            policy = AFSecurityPolicy(pinningMode: .certificate, withPinnedCertificates: set)
        }else {
            policy = AFSecurityPolicy()
        }
        policy.allowInvalidCertificates = networkConfig.securityPolicy.allowInvalidCertificates
        policy.validatesDomainName = networkConfig.securityPolicy.validatesDomainName
        
        manager = AFHTTPSessionManager(sessionConfiguration: config)
        manager.securityPolicy = policy
        manager.responseSerializer = AFJSONResponseSerializer()
        manager.responseSerializer.acceptableStatusCodes = allStatusCodes
        manager.completionQueue = DispatchQueue(label: "com.pa.network", qos: .default, attributes: .concurrent)
    }
    
    func buildRequestUrl(request:PARequest) ->String {
        var requestInterceptor:PARequestInterceptor? = nil
        if let receptor = request.requestInterceptor,request.needRequestInterceptor{
            requestInterceptor = receptor
        }else if let receptor = networkConfig.requestInterceptor,request.needRequestInterceptor{
            requestInterceptor = receptor
        }
        if let receptor = requestInterceptor {
        receptor.requestInterceptor(request: request)
        }
        //已对请求连接处理
        if let requestUrl = request.requestUrl {
            if let url = URL(string: requestUrl),url.scheme != nil ,url.host != nil{
                return requestUrl
            }else {
                if let baseUrl = networkConfig.baseUrl {
               return  URL(string: requestUrl, relativeTo: URL.init(string: baseUrl)!)?.absoluteString ?? ""
                }
                return ""
            }
        }else {
            return networkConfig.baseUrl ?? ""
        }
    }
    
    func addRequest(request:PARequest) {
        request.requestTask = sessionTaskForRequest(request: request)
        if request.requestTask == nil {
            return
        }
        
        switch request.requestPriority {
        case .priorityDefault:
            request.requestTask?.priority = URLSessionTask.defaultPriority
        case .priorityLow:
            request.requestTask?.priority = URLSessionTask.lowPriority
        case .priorityHigh:
            request.requestTask?.priority = URLSessionTask.highPriority
        }
        addRequestToRecord(request: request)
        request.requestTask?.resume()
    }
    
    func sessionTaskForRequest(request:PARequest) -> URLSessionTask? {
        let requestSerializer = requestSerializerForRequest(request: request)
        var url:String = buildRequestUrl(request: request)
        let method = request.requestMethod
        
        if request.shouldAutoEncodeUrl {
            url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        }
        
        switch method {
        case .get:
            return dataTask(request:request,httpMethod: method, requestSerializer: requestSerializer, urlString: url, parameters: request.requestParams)
        case .delete,.patch,.head,.put:
            return dataTask(request:request,httpMethod: method, requestSerializer: requestSerializer, urlString: url, parameters: request.requestParams)
        case .post:
            return dataTask(request:request,httpMethod: method, requestSerializer: requestSerializer, urlString: url, parameters: request.requestParams, constructBodyBlock: request.constructingBodyBlock)
        }
    }
    
    func addRequestToRecord(request:PARequest) {
        lock.lock()
        if let task = request.requestTask {
            requestRecords[task.taskIdentifier] = request
        }
        lock.unlock()
    }
    
    func removeRequestFromRecord(request:PARequest) {
        lock.lock()
        if let task = request.requestTask {
            requestRecords.removeValue(forKey: task.taskIdentifier)
        }
        lock.unlock()
    }
    
    func requestSerializerForRequest(request:PARequest)->AFHTTPRequestSerializer {
        let requestSerializer:AFHTTPRequestSerializer = request.requestSerial == .http ?
            AFHTTPRequestSerializer() :  AFJSONRequestSerializer()
        if let timeout = request.requestTimeOut {
            requestSerializer.timeoutInterval = timeout
        }
        if let authorizationHeader = request.requestAuthorizationHeaderField {
            requestSerializer.setAuthorizationHeaderFieldWithUsername(authorizationHeader.username, password: authorizationHeader.password)
        }
        if let httpHeaderField = request.requestHttpHeaderFields {
            for (key,value) in httpHeaderField {
                requestSerializer.setValue(value, forHTTPHeaderField: key)
            }
        }
        return requestSerializer
    }
    
    func dataTask(request:PARequest,
                  httpMethod:PARequestMethod,
                  requestSerializer:AFHTTPRequestSerializer,
                  urlString:String,
                  parameters:[String:Any]?,
                  constructBodyBlock:PARequest.PAConstructingBodyBlock? = nil)->URLSessionTask? {
        var urlRequest:NSMutableURLRequest
        var error:NSError? = nil
        if let block = constructBodyBlock {
            urlRequest = requestSerializer.multipartFormRequest(withMethod: httpMethod.rawValue, urlString: urlString, parameters: parameters, constructingBodyWith: block, error: &error)
        }else {
            urlRequest = requestSerializer.request(withMethod: httpMethod.rawValue, urlString: urlString, parameters: parameters, error: &error)
        }
        if let error = error {
            requestDidFail(request: request, error: error)
            return nil
        }
        
        var dataTask:URLSessionDataTask? = nil
        dataTask = manager.dataTask(with: urlRequest as URLRequest) { [weak self,weak dataTask](response, responseObject, resultError) in
            self?.handleRequestResult(task:dataTask ,response: response, responseObject: responseObject, error: resultError)
        }
        return dataTask
    }
    
    func handleRequestResult(task:URLSessionDataTask? , response:URLResponse,responseObject:Any?,error:Error?) {
        var sRequest:PARequest?
        lock.lock()
        if let task = task {
            sRequest = requestRecords[task.taskIdentifier]
        }
        lock.unlock()
        
        guard let request = sRequest else {
            return
        }
        let responseModel:PAResponse = PAResponse(urlResponse: response, responseObject: responseObject, error: error)
        responseModel.isRequestSuccess = true 
        
        if let responseInterceptor = request.responseInterceptor {
            responseInterceptor.responseInterceptor(response: responseModel)
        }else if let responseInterceptor = networkConfig.responseInterceptor {
            responseInterceptor.responseInterceptor(response: responseModel)
        }
        
        DispatchQueue.main.async {
            if let block = request.completionBlock {
                block(responseModel)
            }
            if let delegate = request.delegate {
                if responseModel.isResponseSuccess {
                    delegate.requestFinished(request, response: responseModel)
                }else {
                    delegate.requestFailured(request, response: responseModel)
                }
            }
            self.removeRequestFromRecord(request: request)
            request.clearCompletionBlock()
            request.isShowHud(showFlag: false)
        }
    }
    
    func requestDidFail(request:PARequest,error:NSError) {
        let response = PAResponse()
        response.error = PAError(errorMessage: PAError.commonErrorMessage)
        DispatchQueue.main.async {
            request.delegate?.requestFailured(request, response: response)
            if let block = request.completionBlock {
                block(response)
            }
            request.clearCompletionBlock()
            request.isShowHud(showFlag: false)
        }
    }
    
    func cancelRequest(request:PARequest) {
        request.requestTask?.cancel()
        request.delegate = nil
        removeRequestFromRecord(request: request)
        request.clearCompletionBlock()
        request.isShowHud(showFlag: false)
    }
    
    func cancelAllRequests() {
        lock.lock()
        let allKeys = requestRecords.keys
        lock.unlock()
        if allKeys.count > 0 {
            for key in allKeys{
                lock.lock()
                let request = requestRecords[key]
                lock.unlock()
                request?.stop()
            }
        }
    }
}
