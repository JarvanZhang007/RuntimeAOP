//
//  JXAuthorityManagement.swift
//  RuntimeAOP
//
//  Created by JarvanZhang on 2017/8/23.
//  Copyright © 2017年 JarvanZhang. All rights reserved.
//

import UIKit

class JXAuthorityManagement: NSObject {

    //单例
    static let shareInstance = JXAuthorityManagement()
    
    var isShowAlert:Bool = false
    
    //保存事件传递
    var btnSelector:Selector? = nil
    var btnTarget:(Any)? = nil
    var btnEvent:UIEvent? = nil
    var btnControl:UIControl? = nil
    
    //安全码 🔐需要输入的时间段 10*60为10分钟，测试我们用 10s
    fileprivate let interval:TimeInterval = 5
    
    fileprivate var lastDate:Date?
    
    private override init() {
//       1, 交互 sendAction方法 UIButton UISwitch UITextField 等继承UIControl控件有效
//       2，必须有对应的事件才用效果 比如Button必须有点击事件，UISwitch必须有switchValueChanged事件
//       3，截拦的时间点在于你所提供的事件执行时间点，比如UITextField 你只有EditingDidEnd事件，则在输入完成后执行，如果你有监听UIControlEventEditingDidBegin 则第一次点击编辑的时候就会执行截拦
        swizzling(UIControl.self,#selector(UIControl.sendAction(_:to:for:)),#selector(UIControl.JXsendAction(_:to:for:)))
        
        //手势 的权限管理可以交互如下方法:UIView.gestureRecognizerShouldBegin 这里不做演示
        //swizzling(UIView.self,#selector(UIView.gestureRecognizerShouldBegin(_:)),#selector(UIView.JXgestureRecognizerShouldBegin(_:)))
        
    }
    
    //验证是否通过
    fileprivate func  isVerified() -> Bool {
        var pass = false
        if let last = lastDate{
            //判断时间差
            if Date().timeIntervalSince(last) < interval {
                pass = true
            }
        }
        return pass
    }
    
    // 弹出对话框
    fileprivate func popupAlertView() {
        isShowAlert = true
        let alertController = UIAlertController(title: "请输入权限密码", message: "输入1234", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: { (action) in
            
          self.isShowAlert = false
            
        })
        let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
            
            self.isShowAlert = false
            
            if let textFields = alertController.textFields{
                if textFields[0].text == "1234"{
                    //保存输入密码的时间，用于计算时间差
                    self.lastDate = Date()
                    self.btnControl?.JXsendAction(self.btnSelector!, to: self.btnTarget, for: self.btnEvent)
                }else{
                //使用HUD 提示
                    print("密码输入错误，事件不会执行")
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        alertController.addTextField {
            (textField: UITextField!) -> Void in
            textField.placeholder = "密码"
            textField.isSecureTextEntry = true
        }
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}

//MARK: - UIControl 交互方法

extension UIControl{
    
    open  func JXsendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        
        var overlook = true
        
        if self.needPermission == true {

            let manager = JXAuthorityManagement.shareInstance
            
            manager.btnSelector = action
            manager.btnTarget = target
            manager.btnEvent = event
            manager.btnControl = self
            
            if manager.isShowAlert {
                overlook = false
            }else{
                if manager.isVerified() {
                    overlook = true
                }else{
                    if let switchControl = self as? UISwitch {
                        switchControl.isOn = !switchControl.isOn
                    }
                    overlook = false
                    manager.popupAlertView()
                }
            }
        }
        
        if overlook {
            self.JXsendAction(action, to: target, for: event)
        }
    }
}



//MARK: - 交互方法Swift版
public let swizzling: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
    let originalMethod = class_getInstanceMethod(forClass, originalSelector)
    let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)
    method_exchangeImplementations(originalMethod, swizzledMethod)
}


private var NeedPermissionRawPointer: UInt8 = 0
//MARK: - 扩展UIView 属性Xib可见
//属性可以使用Xib
@IBDesignable
extension UIView{
    //属性可以使用Xib  默认未false 不需要权限管理
    @IBInspectable var needPermission: Bool {
//        get set 方法 调用 Runtime 的API动态获取
        get {
            if let associated = objc_getAssociatedObject(self, &NeedPermissionRawPointer)
                as? Bool
            {
                return associated
            }else{
                return false
            }
        }
        set(newValue) {
            objc_setAssociatedObject(self, &NeedPermissionRawPointer, newValue,.OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
