//
//  HistoryDetailViewController.swift
//  OdekakeLog
//
//  Created by 神戸悟 on 2023/01/07.
//

import UIKit
import MapKit
import CoreLocation

class HistoryDetailViewController: UIViewController {
    
    
    @IBOutlet weak var historyDetailMapView: MKMapView!
    
    @IBOutlet weak var headNavigationItem: UINavigationItem!
    
    var activityEntity: ActivityEntity!
    var mapCenter: CLLocationCoordinate2D!
    var mapLatitudinalMeters: Double = 0.0
    var mapLongitudinalMeters: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // headNavigationItemのラベルを設定
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        dateFormatter.dateFormat = "MM/dd HH:mm"
        headNavigationItem.title = (dateFormatter.string(from: activityEntity.startDate!)) + "〜" + (dateFormatter.string(from: activityEntity.endDate!))
        
        // mapの準備
        historyDetailMapView.delegate = self
        
        //取得した位置情報データの取得
        let taskId = activityEntity.taskId
        let locationEntityList: [LocationEntity] = CoreDataRepository.array(
            predicate: "taskId = \(taskId)",
            sortKey: "timestamp")
        //取得したデータをMapに描画
        var coordinates: [CLLocationCoordinate2D] = []
        var latitudeList: [Double] = []
        var longitudeList: [Double] = []
        locationEntityList.forEach{
            coordinates.append(CLLocationCoordinate2D(
                latitude: $0.latitude,
                longitude: $0.longitude))
            
            // 描画するためのMapの中心の計算
            latitudeList.append($0.latitude)
            longitudeList.append($0.longitude)
        }
        let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
        historyDetailMapView.addOverlay(polyLine)
        
        mapCenter = CLLocationCoordinate2DMake(
            latitudeList.reduce(0.0, +) / Double(latitudeList.count),
            longitudeList.reduce(0.0, +) / Double(longitudeList.count))
        mapLatitudinalMeters = latitudeList.max()! - latitudeList.min()! + 1000.0
        mapLongitudinalMeters = longitudeList.max()! - longitudeList.min()! + 1000.0
        
        // 地図を表示するための領域を再構築
        let region = MKCoordinateRegion(
            center: mapCenter,
            latitudinalMeters: mapLatitudinalMeters,
            longitudinalMeters: mapLongitudinalMeters
        )
        historyDetailMapView.setRegion(region, animated: true)
    }
}

extension HistoryDetailViewController: MKMapViewDelegate {
    //MapのOverlay時に呼び出されるメソッド
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = .blue
            polylineRenderer.lineWidth = 10.0
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
}
