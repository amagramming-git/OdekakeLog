//
//  HistoryViewController.swift
//  OdekakeLog
//
//  Created by 神戸悟 on 2023/01/07.
//

import UIKit
import MapKit
import CoreLocation

class HistoryViewController: UIViewController {
    
    
    @IBOutlet var historyTableView: UITableView!
    let systemIcons = ["archivebox","trash","tray","folder","doc","archivebox","trash","tray","folder","doc","archivebox","trash","tray","folder","doc","archivebox","trash","tray","folder","doc","archivebox","trash","tray","folder","doc","archivebox","trash","tray","folder","doc","archivebox","trash","tray","folder","doc","archivebox","trash","tray","folder","doc","archivebox","trash","tray","folder","doc","archivebox","trash","tray","folder","doc","archivebox","trash","tray","folder","doc"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TableViewnの準備
        historyTableView.dataSource = self
        historyTableView.delegate = self
    }
}
extension HistoryViewController: UITableViewDelegate {
    
}
extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return systemIcons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath)
        
        cell.textLabel?.text = systemIcons[indexPath.row]
        cell.imageView?.image = UIImage(systemName: systemIcons[indexPath.row])
        
        return cell
    }
    
    
}

//https://softmoco.com/basics/how-to-use-table-view.php
