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
        
    }
    
    @IBAction func subButtonAction(_ sender: Any) {
        
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
    }
}


//https://qiita.com/eito_2/items/7e7d0b658f2bcda3897e 基本的に位置情報の取得で最も参考にした
//https://swiswiswift.com/2021-03-05/ Mapに線を引く
//https://program-life.com/1431 バックグラウンドで位置情報を取得する際の注意事項
//https://qiita.com/uhooi/items/429cac9b798b9c0937ae UserDefaultの使い方
