//
//  PABatchRequest.swift
//  PANetwork
//
//  Created by lichao_liu on 2018/3/1.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit

class PABatchRequest {
    var successCount:Int = 0
    var failuredCount:Int = 0
    var requestArray:[PARequest] = []
    var lock:NSRecursiveLock = NSRecursiveLock()
    var isCancelWhileFailed:Bool = false
    var hudBlock:PARequest.PAHudBlock?
    var completionBlock:(()->Void)?
    
    func start() {
        if successCount + failuredCount > 0 {
            return
        }
        showHud(isShowHud: true)
        for request in requestArray {
            request.delegate = self
            request.start()
        }
    }
    
    func stop() {
        showHud(isShowHud: false)
        clearRequest()
    }
    
    func clearRequest() {
        for request in requestArray {
            request.stop()
        }
        completionBlock?()
    }
    
    init(requestArray:[PARequest]) {
        self.requestArray = requestArray
    }
    
    func showHud(isShowHud:Bool) {
        if let block = hudBlock {
            block(isShowHud)
        }
    }
    
    func whenRequestFinished(success:Bool) {
        lock.lock()
        if success {
            successCount += 1
        }else {
            failuredCount += 1
        }
        lock.unlock()
        if isCancelWhileFailed && failuredCount > 0 {
            completionBlock?()
            stop()
            return
        }
        if successCount + failuredCount == requestArray.count {
            showHud(isShowHud: false)
            completionBlock?()
            completionBlock = nil
        }
    }
}

extension PABatchRequest: PARequestDelegate {
    func requestFinished(_ request: PARequest, response: PAResponse) {
        whenRequestFinished(success: true)
    }
    
    func requestFailured(_ request: PARequest, response: PAResponse) {
        whenRequestFinished(success: false)
    }
    
    
}
