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
 
        PARequest.start(method: .get, requestUrl: "https://httpbin.org/get", hudBlock: { (flag) in
            if flag {
                print("show hud")
            }else {
                print("hide hud")
            }
        }) { (response) in
            print(response.responseObject!)
        }
    }
}

