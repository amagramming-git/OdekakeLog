//
//  ViewController.swift
//  OdekakeLog
//
//  Created by 神戸悟 on 2023/01/04.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var mainMapView: MKMapView!
    //位置情報マネージャー
    var locationManager : CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // locationManagerの準備
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        
        // 位置情報の許可を求める
        requestAlwaysAuthorization()
    }
    
    @IBAction func mainButtonAction(_ sender: Any) {
        //taskIdの払い出し
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let now = Date()
        UserDefaults.standard.set(Int64(formatter.string(from: now)), forKey: "taskId")
        
        // 位置情報取得の設定
        let isAuthorizedAlways = locationManager!.authorizationStatus == .authorizedAlways
        locationManager!.allowsBackgroundLocationUpdates = isAuthorizedAlways
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.distanceFilter = 10
        locationManager!.activityType = .other // 備考 typeに応じて道とかにいい感じに沿わせてくれる

        // 位置情報取得開始
        locationManager!.startUpdatingLocation()
    }
    
    @IBAction func subButtonAction(_ sender: Any) {
        locationManager!.stopUpdatingLocation()
    }

    func requestAlwaysAuthorization(){
        let status = locationManager!.authorizationStatus
        print(status.rawValue)
        switch status {
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            break
        case .notDetermined, .restricted, .denied:
            locationManager!.requestAlwaysAuthorization()
        default:
            locationManager!.requestAlwaysAuthorization()
            break
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {return}
        let taskId = Int64(UserDefaults.standard.integer(forKey: "taskId"))
        let entity = LocationEntity.new(
            taskId: taskId,
            latitude: newLocation.coordinate.latitude,
            longitude: newLocation.coordinate.longitude,
            timestamp: newLocation.timestamp)
    }
}


//https://qiita.com/eito_2/items/7e7d0b658f2bcda3897e 基本的に位置情報の取得で最も参考にした
//https://swiswiswift.com/2021-03-05/ Mapに線を引く
//https://program-life.com/1431 バックグラウンドで位置情報を取得する際の注意事項
//https://qiita.com/uhooi/items/429cac9b798b9c0937ae UserDefaultの使い方
