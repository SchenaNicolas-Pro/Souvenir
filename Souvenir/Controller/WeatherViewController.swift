//
//  WeatherViewController.swift
//  Souvenir
//
//  Created by Nicolas Schena on 18/08/2022.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Icon Dictionnary
    private let iconDictionnary = ["01d": UIImage(systemName: "sun.max.fill"),
                                   "01n": UIImage(systemName: "moon.stars.fill"),
                                   "02d": UIImage(systemName: "cloud.sun.fill"),
                                   "02n": UIImage(systemName: "cloud.moon.fill"),
                                   "03d": UIImage(systemName: "cloud.fill"),
                                   "03n": UIImage(systemName: "cloud.fill"),
                                   "04d": UIImage(systemName: "cloud.fill"),
                                   "04n": UIImage(systemName: "cloud.fill"),
                                   "09d": UIImage(systemName: "cloud.drizzle.fill"),
                                   "09n": UIImage(systemName: "cloud.drizzle.fill"),
                                   "10d": UIImage(systemName: "cloud.rain.fill"),
                                   "10n": UIImage(systemName: "cloud.rain.fill"),
                                   "11d": UIImage(systemName: "cloud.bolt.rain.fill"),
                                   "11n": UIImage(systemName: "cloud.bolt.rain.fill"),
                                   "13d": UIImage(systemName: "cloud.snow.fill"),
                                   "13n": UIImage(systemName: "cloud.snow.fill"),
                                   "50d": UIImage(systemName: "cloud.fog.fill"),
                                   "50n": UIImage(systemName: "cloud.fog.fill")]
    
    // MARK: - CLlocation
    private var locationManager: CLLocationManager?
    
    private let service = WeatherService()
    
    @IBOutlet weak var citySearchTextField: UITextField!
    @IBOutlet weak var search: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - New York IBOutlet
    @IBOutlet weak var autoLocationStackView: UIStackView!
    @IBOutlet weak var autoLocationcityLabel: UILabel!
    @IBOutlet weak var autoLocationStateLabel: UILabel!
    @IBOutlet weak var autoLocationImageView: UIImageView!
    @IBOutlet weak var autoLocationTemp: UILabel!
    @IBOutlet weak var autoLocationDescription: UILabel!
    @IBOutlet weak var autoLocationMin: UILabel!
    @IBOutlet weak var autoLocationMax: UILabel!
    
    // MARK: - City IBOutlet
    @IBOutlet weak var cityStackView: UIStackView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var cityImageView: UIImageView!
    @IBOutlet weak var cityTemp: UILabel!
    @IBOutlet weak var cityDescription: UILabel!
    @IBOutlet weak var cityMin: UILabel!
    @IBOutlet weak var cityMax: UILabel!
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        addRoundCorner()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.requestAlwaysAuthorization()
            
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager?.startUpdatingLocation()
        }
    }
    
    // MARK: - IBAction
    @IBAction func searchButton(_ sender: Any) {
        activityIndicator.isHidden = false
        getCityCoordinate()
        activityIndicator.isHidden = true
    }
    
    // MARK: - CLLocationManager function
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        getAutoLocationCityAndState(lat: latitude, lon: longitude)
    }
    
    // MARK: - Service's functions
    private func getCityCoordinate() {
        guard let city = citySearchTextField.text, citySearchTextField.hasText else {
            presentAlert("No city in the search")
            return
        }
        service.getGeoCoordinate(city: city) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(coordinate):
                    self?.cityLabel.text = coordinate.city
                    self?.stateLabel.text = coordinate.state
                    self?.getCityWeather(lat: coordinate.lat, lon: coordinate.lon)
                case .failure(_):
                    self?.presentAlert("Incorrect request")
                }
            }
        }
    }
    
    private func getCityWeather(lat: Double, lon: Double) {
        service.getWeather(lat: lat, lon: lon) { [weak self] cityWeather in
            DispatchQueue.main.async {
                switch cityWeather {
                case let .success(weather):
                    self?.cityTemp.text = weather.temp
                    self?.cityDescription.text = weather.description
                    self?.cityMin.text = weather.tempMin
                    self?.cityMax.text = weather.tempMax
                    self?.cityImageView.image = self?.updateIcon(weather.iconID)
                    self?.activityIndicator.isHidden = true
                case let .failure(error):
                    self?.presentAlert(error.rawValue)
                }
            }
        }
    }
    
    private func getAutoLocationCityAndState(lat: Double, lon: Double) {
        service.getGeoCity(lat: lat, lon: lon) { [weak self] cityAndState in
            DispatchQueue.main.async {
                switch cityAndState {
                case let .success(cityName):
                    self?.autoLocationcityLabel.text = cityName.city
                    self?.autoLocationStateLabel.text = cityName.state
                    self?.getAutoLocationWeather(lat: lat, lon: lon)
                case let .failure(error):
                    self?.presentAlert(error.rawValue)
                }
            }
        }
    }
    
    private func getAutoLocationWeather(lat: Double, lon: Double) {
        service.getWeather(lat: lat, lon: lon) { [weak self] weather in
            DispatchQueue.main.async {
                switch weather {
                case let .success(weather):
                    self?.autoLocationTemp.text = weather.temp
                    self?.autoLocationDescription.text = weather.description
                    self?.autoLocationMin.text = weather.tempMin
                    self?.autoLocationMax.text = weather.tempMax
                    self?.autoLocationImageView.image = self?.updateIcon(weather.iconID)
                case let .failure(error):
                    self?.presentAlert(error.rawValue)
                }
            }
        }
    }
    
    private func updateIcon(_ iconID: String) -> UIImage? {
        guard let weatherIcon = iconDictionnary[iconID] else {
            return nil
        }
        return weatherIcon
    }
}

// MARK: - Round Corner
extension WeatherViewController {
    private func roundCornered(_ stackView: UIStackView) {
        stackView.layer.masksToBounds = true
        stackView.layer.cornerRadius = 8.0
    }
    
    /// Method to add round corners to specified label
    private func addRoundCorner() {
        roundCornered(cityStackView)
        roundCornered(autoLocationStackView)
    }
}

// MARK: - Dismiss Keyboard
extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        citySearchTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
