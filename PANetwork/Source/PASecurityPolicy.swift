//
//  PASecurityPolicy.swift
//  PANetwork
//
//  Created by lichao_liu on 2018/2/27.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit

class PASecurityPolicy {
    public static let `default` = PASecurityPolicy()
    
    // 是否允许不信任的证书，默认为false
    public var allowInvalidCertificates: Bool = false
    
    // 是否验证域名证书的CN(common name)字段，默认为true
    public var validatesDomainName: Bool = true
    //ca发布的证书本地数据
    public var useCertificate:Data?
}
