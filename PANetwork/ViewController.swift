//
//  ViewController.swift
//  PANetwork
//
//  Created by lichao_liu on 2018/2/27.
//  Copyright © 2018年 com.pa.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = PARequest()
        request.requestUrl = "https://httpbin.org/get"
        request.requestMethod = .get
        request.completionBlock = {
            response in
            print(response.responseObject)
        }
        request.start()
    }
}

