//
//  ExChatConversation.swift
//  SIMChatExample
//
//  Created by sagesse on 2/3/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import SIMChat

class Unknow: SIMChatContentProtocol {
}

class ExChatConversation: SIMChatBaseConversation {

    
    func makeTestData() {
        
        let path = NSBundle.mainBundle().pathForResource("t1", ofType: "jpg")!
        
        for i in 0 ..< 20 {
            let o = (i % 2 == 0) ? receiver : sender!
            let s = (i % 2 == 0) ? sender!  : receiver 
            if true {
                let c = SIMChatBaseContent.Text(content: "this is a tips\nThis is a very long long long long long long long long the tips")
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (i % 2 == 0)
                m.status = .Sending
                messages.append(m)
            }
            if true {
                let c = SIMChatBaseContent.Image(remote: path, size: CGSizeMake(640, 480))
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (i % 2 == 0)
                m.status = .Receiving
                messages.append(m)
            }
            if true {
                let c = SIMChatBaseContent.Audio(remote: path, duration: 6.2 * Double(i + 1))
                let m = SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s)
                m.option = [.ContactShow]
                m.isSelf = (i % 2 == 0)
                m.status = .Error
                messages.append(m)
            }
            if true {
                let c = SIMChatBaseContent.Date(content: NSDate())
                messages.append(SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s))
            }
            if true {
                let c = SIMChatBaseContent.Tips(content: "this is a tips\nThis is a very long long long long long long long long the tips")
                messages.append(SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s))
            }
            if true {
                let c = Unknow()
                messages.append(SIMChatBaseMessage.messageWithContent(c, receiver: o, sender: s))
            }
        }
    }
    
    var allLoaded = false
}

//extension SDChatConversation {
//    override func queryMessages(total: Int, last: SIMChatMessage?, _ finish: ([SIMChatMessage] -> Void)?, _ fail: SIMChatFailBlock?) {
//        super.queryMessages(total, last: last, { [weak self] ms in
//            // 己经完成了
//            guard ms.count < total && !(self?.allLoaded ?? true) else {
//                finish?(ms)
//                return
//            }
//            SIMLog.trace("finish")
//            // 并没有
//            finish?(ms)
//        }, fail)
//    }
//    override func sendMessage(m: SIMChatMessage, isResend: Bool, _ finish: SIMChatFinishBlock?, _ fail: SIMChatFailBlock?) {
//        super.sendMessage(m, isResend: isResend, {
//            // 1秒后完成
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
//                SIMLog.trace("finish")
//                
//                m.status = rand() % 20 == 0 ? .Error : .Sent
//                m.statusChanged()
//                
//                finish?()
//                
//            }
//            // 2秒后收到一条新消息
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue()) {
//                let nm = SIMChatMessage(m.content)
//                
//                nm.sender = self.receiver
//                nm.sentTime = m.sentTime
//                nm.receiver = self.receiver
//                nm.receiveTime = .now
//                nm.status = .Unread
//                
//                self.reciveMessageForRemote(nm)
//            }
//        }, fail)
//        
//    }
//}