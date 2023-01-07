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
    var updatingLocationStatus : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // mapの準備
        mainMapView.delegate = self
        mainMapView.userTrackingMode = .follow
        
        // locationManagerの準備
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        
        // 位置情報の許可を求める
        requestAlwaysAuthorization()
        
        // ボタンのアイコン見た目を設定
        changeButtonIcon(updatingLocationStatus: false)
    }
    
    @IBOutlet weak var centerButtonOutlet: UIButton!
    //centerButtonの見た目をStartとStopの切り替えをするためのメソッド
    func changeButtonIcon(updatingLocationStatus:Bool){
        self.updatingLocationStatus = updatingLocationStatus
        var imageIcon = updatingLocationStatus ? UIImage(systemName: "stop.circle.fill") : UIImage(systemName: "play.circle.fill")
        imageIcon = resize(image: imageIcon!, width: imageIcon!.size.width * 5)
        imageIcon = updatingLocationStatus ? imageIcon!.withTintColor(.red) : imageIcon!.withTintColor(.blue)
        centerButtonOutlet.setImage(imageIcon, for: .normal)
    }
    func resize(image: UIImage, width: Double) -> UIImage {
        // オリジナル画像のサイズからアスペクト比を計算
        let aspectScale = image.size.height / image.size.width
        // widthからアスペクト比を元にリサイズ後のサイズを取得
        let resizedSize = CGSize(width: width, height: width * Double(aspectScale))
        // リサイズ後のUIImageを生成して返却
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    @IBAction func centerButtonAction(_ sender: Any) {
        if !self.updatingLocationStatus {
            startAction()
        }else{
            stopAction()
        }
        changeButtonIcon(updatingLocationStatus: !self.updatingLocationStatus)
    }

    func startAction() {
        //描画したMapの線を削除
        mainMapView.removeOverlays(mainMapView.overlays)

        //taskIdの払い出し
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let now = Date()
        let taskId = Int64(formatter.string(from: now))!
        UserDefaults.standard.set(taskId, forKey: "taskId")
        
        //ActivityEntityの登録
        let entity = ActivityEntity.new(taskId: taskId)
        entity.setStartDate(startDate: now)
        CoreDataRepository.add(entity)
        CoreDataRepository.save()
        
        // 位置情報取得の設定
        let isAuthorizedAlways = locationManager!.authorizationStatus == .authorizedAlways
        locationManager!.allowsBackgroundLocationUpdates = isAuthorizedAlways
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.distanceFilter = 10
        locationManager!.activityType = .other // 備考 typeに応じて道とかにいい感じに沿わせてくれる

        // 位置情報取得開始
        locationManager!.startUpdatingLocation()
    }
    
    func stopAction() {
        // 位置情報取得終了
        locationManager!.stopUpdatingLocation()
        
        // taskIdの取得
        let taskId = Int64(UserDefaults.standard.integer(forKey: "taskId"))
        
        // ActivityEntityの更新
        let activityEntityList: [ActivityEntity] = CoreDataRepository.array(
            predicate: "taskId = \(taskId)")
        let now = Date()
        activityEntityList[0].setEndDate(endDate: now)
        CoreDataRepository.save()
        
        //取得した位置情報データの取得
        let locationEntityList: [LocationEntity] = CoreDataRepository.array(
            predicate: "taskId = \(taskId)",
            sortKey: "timestamp")
        
        //取得したデータをMapに描画
        var coordinates: [CLLocationCoordinate2D] = []
        locationEntityList.forEach{
            coordinates.append(CLLocationCoordinate2D(
                latitude: $0.latitude,
                longitude: $0.longitude))
        }
        let polyLine = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mainMapView.addOverlay(polyLine)
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
    //位置情報取得時に呼び出されるメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {return}
        let taskId = Int64(UserDefaults.standard.integer(forKey: "taskId"))
        let entity = LocationEntity.new(
            taskId: taskId,
            latitude: newLocation.coordinate.latitude,
            longitude: newLocation.coordinate.longitude,
            timestamp: newLocation.timestamp)
        CoreDataRepository.add(entity)
        CoreDataRepository.save()
        
        // 地図を表示するための領域を再構築
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2DMake(
                newLocation.coordinate.latitude,
                newLocation.coordinate.longitude),
            latitudinalMeters: 1000.0,
            longitudinalMeters: 1000.0
        )
        mainMapView.setRegion(region, animated: true)
    }
}

extension ViewController: MKMapViewDelegate {
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

//https://qiita.com/eito_2/items/7e7d0b658f2bcda3897e 基本的に位置情報の取得で最も参考にした
//https://swiswiswift.com/2021-03-05/ Mapに線を引く
//https://stackoverflow.com/questions/50372633/remove-polylines-at-swift Mapの線を削除する
//https://program-life.com/1431 バックグラウンドで位置情報を取得する際の注意事項
//https://qiita.com/uhooi/items/429cac9b798b9c0937ae UserDefaultの使い方
//https://qiita.com/Sossiii/items/7f8dc9e0ed0d87d2a2aa モーダルの追加

//https://stackoverflow.com/questions/37772411/how-to-add-system-icons-for-a-uibutton-programmatically システムイメージをアイコンに使用
//https://program-life.com/497 アイコンのリサイズ
//https://stackoverflow.com/questions/58256044/how-to-change-sf-symbol-icon-color-in-uikit アイコンの色替え

//https://icooon-mono.com/15443-%E5%86%8D%E7%94%9F%E3%83%9C%E3%82%BF%E3%83%B3/ 再生ボタン
//https://icooon-mono.com/15452-%e5%86%8d%e7%94%9f%e5%81%9c%e6%ad%a2%e3%83%9c%e3%82%bf%e3%83%b3/ 停止ボタン

//https://softmoco.com/basics/how-to-implement-table-view-navigation.php 履歴画面の構成と画面遷移

//https://grandbig.github.io/blog/2017/06/04/put-annotation-2/ mapに画像を配置
//https://stackoverflow.com/questions/1553573/get-map-image-from-mkmapview mapを画像に変換
