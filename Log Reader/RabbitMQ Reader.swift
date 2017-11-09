//
//  rabbitMQ Reader.swift
//  Log Reader
//
//  Created by Marc Shearer on 09/11/2017.
//  Copyright © 2017 Marc Shearer. All rights reserved.
//

import Foundation
import RMQClient

public class RabbitMQReader {

    private weak var connection: RMQConnection!
    private weak var channel: RMQChannel!
    private weak var queue: RMQQueue!
    private weak var exchange: RMQExchange!
    private var rabbitMQUri: String = Config.rabbitMQUri
    private var _queueUUID: String!
    public var queueUUID: String! {
        get {
            return _queueUUID
        }
    }

    init(queueUUID: String, handler: @escaping (String?, String?, String)->()) {
        self._queueUUID = queueUUID
        self.connection = RMQConnection(uri: self.rabbitMQUri, delegate: RMQConnectionDelegateLogger())
        connection.start()
        self.channel = self.connection.createChannel()
        self.queue = self.channel.queue("", options: .exclusive)
        self.exchange = self.channel.fanout(queueUUID)
        self.queue.bind(self.exchange)
        self.queue.subscribe({ (_ message: RMQMessage) -> Void in
            Utility.mainThread {
                do {
                    let propertyList: [String : Any?] = try JSONSerialization.jsonObject(with: message.body, options: []) as! [String : Any]
                    let deviceName = propertyList["fromDeviceName"] as? String
                    if let content = propertyList["content"] as? [String : String] {
                        let timestamp = content["timestamp"]
                        if let message = content["message"] {
                            handler(deviceName, timestamp, message)
                        }
                    }
                } catch {
                    // Ignore errors
                }
                
            }
        })
    }
}
