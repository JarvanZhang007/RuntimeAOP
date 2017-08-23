//
//  ViewController.swift
//  RuntimeAOP
//
//  Created by JarvanZhang on 2017/8/23.
//  Copyright © 2017年 JarvanZhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func click1(_ sender: Any) {
        print("密码输入通过")
    }

    @IBAction func click2(_ sender: Any) {
        print("不做额外设定，不需要权限管理")
    }
    
    
//    @IBAction func textFieldEditingDidEnd(_ sender: UITextField) {
//        print("输入完成")
//    }

    
    @IBAction func textFieldEditingDidBegin(_ sender: Any) {
        print("开始输入")
    }
    
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        print("Switch value changed")
    }
    
    
//    MARK: - 点击空白区域隐藏键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
}

