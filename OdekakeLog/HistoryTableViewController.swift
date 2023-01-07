//
//  HistoryViewController.swift
//  OdekakeLog
//
//  Created by 神戸悟 on 2023/01/07.
//

import UIKit
import MapKit
import CoreLocation

class HistoryTableViewController: UIViewController {
    
    
    @IBOutlet var historyTableView: UITableView!
    var activityEntityList: [ActivityEntity?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TableViewnの準備
        historyTableView.dataSource = self
        historyTableView.delegate = self
        
        // tableViewに表示するactivityEntityListの作成
        self.activityEntityList = CoreDataRepository.array(sortKey: "startDate")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //テーブルを再描画
        historyTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailSegue" {
            if let indexPath = historyTableView.indexPathForSelectedRow {
                guard let destination = segue.destination as? HistoryDetailViewController else {
                    fatalError("Failed to prepare DetailViewController.")
                }
                destination.activityEntity = activityEntityList[indexPath.row]
            }
        }
    }
}

extension HistoryTableViewController: UITableViewDelegate {
    
}

extension HistoryTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activityEntityList.count == 0{
            return 1
        }else{
            return activityEntityList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath)
        
        guard activityEntityList.count != 0 else {
            cell.textLabel?.text = "No Data"
            cell.imageView?.image = UIImage(systemName: "location.slash")
            return cell
        }

        // tableViewCellのラベルテキストの作成
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        var startDateStr = ""
        var endDateStr = ""
        
        let startDate = activityEntityList[indexPath.row]?.startDate
        if let startDate {
            startDateStr = dateFormatter.string(from: startDate)
        }else{
            let taskId = activityEntityList[indexPath.row]!.taskId
            let locationEntityList: [LocationEntity] = CoreDataRepository.array(
                predicate: "taskId = \(taskId)",
                sortKey: "timestamp")
            activityEntityList[indexPath.row]!.setEndDate(endDate: (locationEntityList.first?.timestamp)!)
            CoreDataRepository.save()
        }
        
        let endDate = activityEntityList[indexPath.row]?.endDate
        if let endDate {
            endDateStr = dateFormatter.string(from: endDate)
        }else{
            let taskId = activityEntityList[indexPath.row]!.taskId
            let locationEntityList: [LocationEntity] = CoreDataRepository.array(
                predicate: "taskId = \(taskId)",
                sortKey: "timestamp")
            activityEntityList[indexPath.row]!.setEndDate(endDate: (locationEntityList.last?.timestamp)!)
            CoreDataRepository.save()
        }

        // cellのパラメータを設定
        cell.textLabel?.text = "\(startDateStr)〜\(endDateStr)"
        cell.imageView?.image = UIImage(systemName: "location")
        return cell
    }
}

//https://softmoco.com/basics/how-to-use-table-view.php テーブルビューの基本的な作成方法
//https://naoya-ono.com/swift/tableview-reload/ 画面遷移でTableViewを再度描画
