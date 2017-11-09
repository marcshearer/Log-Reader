//
//  Log Reader ViewController.swift
//  Log Reader
//
//  Created by Marc Shearer on 09/11/2017.
//  Copyright © 2017 Marc Shearer. All rights reserved.
//

import UIKit

class LogReaderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var reader: RabbitMQReader!
    
    var entries: [Entry] = []
    var filteredEntries: [Entry]!
    var searchText = ""
    
    // MARK: - IB Outlets ============================================================================== -
    
    @IBOutlet weak var naviagationItem: UINavigationItem!
    @IBOutlet private weak var messagesTableView: UITableView!
    
    // MARK: - View Overrides ========================================================================== -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reader = RabbitMQReader(queueUUID: Config.rabbitMQLogQueue, handler: self.didReceiveMessage)
        filteredEntries = entries
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TableView Overrides ===================================================================== -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEntries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (entries[indexPath.row].expanded ? 80 : 24)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: LogReaderCell
        
        cell = tableView.dequeueReusableCell(withIdentifier: "Log Reader Cell", for: indexPath) as! LogReaderCell
        if let deviceName = filteredEntries[indexPath.row].deviceName {
            cell.deviceName.text = deviceName
        } else {
            cell.deviceName.text = "Unknown"
        }
        if let timestamp = filteredEntries[indexPath.row].timestamp {
            cell.timestamp.text = timestamp
        } else {
            cell.timestamp.text = "Unknown"
        }
        cell.message.text = filteredEntries[indexPath.row].message
        
        return cell as UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        filteredEntries[indexPath.row].expanded = !filteredEntries[indexPath.row].expanded
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: - Data Handlers ========================================================================= -

    func didReceiveMessage(deviceName: String?, timestamp: String?, message: String) {
        let entry = Entry(deviceName: deviceName, timestamp: timestamp, message: message)
        if match(entry: entry) {
            let indexPath = IndexPath(row: entries.count, section: 0)
            messagesTableView.beginUpdates()
            entries.append(entry)
            filteredEntries.append(entry)
            messagesTableView.insertRows(at: [indexPath], with: .automatic)
            messagesTableView.endUpdates()
            messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        filteredEntries = entries.filter(self.match)
        messagesTableView.reloadData()
    }
    
    func match(entry: Entry) -> Bool {
        if self.searchText == "" {
            return true
        } else {
            var combined: String
            if let deviceName = entry.deviceName {
                combined = deviceName + " " + entry.message
            } else {
                combined = entry.message
            }
            return (combined.lowercased().contains(searchText.lowercased()))
        }
    }
}

class LogReaderCell: UITableViewCell {
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var message: UILabel!
}

class Entry {
    var deviceName: String?
    var timestamp: String?
    var message: String
    var expanded = false
    
    init(deviceName: String?, timestamp: String?, message:String) {
        self.deviceName = deviceName
        self.timestamp = timestamp
        self.message = message
    }
}
