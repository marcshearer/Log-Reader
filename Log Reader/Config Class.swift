//
//  Configuration Class.swift
//  Contract Whist Scorecard
//
//  Created by Marc Shearer on 25/09/2017.
//  Copyright © 2017 Marc Shearer. All rights reserved.
//

import Foundation

class Config {
    
    // Queue for log messages - blank to disable
    public static let rabbitMQLogQueue = "WhistLogger"

    // Choose which rabbitMQ server to use in development mode
    private static let rabbitMQUri_DevMode: RabbitMQUriDevMode = .localhost
    
    // Use descriptive rabbitMQ session/connection IDs
    public static let rabbitMQ_DescriptiveIDs = false
    
    // MARK: - Utility code - should not need to be changed ============================================== -
    
    // MARK: - Debug online games without access to iCloud - always returns invites for Jack and Emma -
    
    // MARK: - rabbitMQ URI string ======================================================================= -
    
    private enum RabbitMQUriDevMode {
        case localhost
        case myServer
        case amqpServer
    }
    
    public static var rabbitMQUri: String {
        get {
            if rabbitMQUri_DevMode == .localhost {
                return "amqp://marcshearer:jonathan@localhost/test"
            } else if rabbitMQUri_DevMode == .myServer {
                return "amqp://marcshearer:jonathan@marcs-mbp/test"
            } else {
                return "amqp://chpklnuo:B543QfEbX0Yo4P4ey2ccA9yMqczZyeh_@swan.rmq.cloudamqp.com/chpklnuo"
            }
        }
    }
}

