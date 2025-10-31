import Foundation
import CoreLocation
import Combine

// MARK: - Location Service
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled = false
    @Published var locationError: LocationError?
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
    }
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            locationError = .permissionDenied
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            break
        }
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
        isLocationEnabled = true
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isLocationEnabled = false
    }
    
    func getCurrentLocation() -> CLLocation? {
        return currentLocation
    }
    
    func getLocationName(for location: CLLocation, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(nil)
                return
            }
            
            var locationName = ""
            if let locality = placemark.locality {
                locationName += locality
            }
            if let administrativeArea = placemark.administrativeArea {
                if !locationName.isEmpty {
                    locationName += ", "
                }
                locationName += administrativeArea
            }
            if let country = placemark.country {
                if !locationName.isEmpty {
                    locationName += ", "
                }
                locationName += country
            }
            
            completion(locationName.isEmpty ? nil : locationName)
        }
    }
    
    func calculateDistance(from: CLLocation, to: CLLocation) -> CLLocationDistance {
        return from.distance(from: to)
    }
    
    func isLocationNearBeach(_ location: CLLocation) -> Bool {
        // This would check if location is near a beach
        // For now, we'll use a simple coastal check
        return location.coordinate.latitude > 33.0 && location.coordinate.latitude < 35.0 &&
               location.coordinate.longitude > -119.0 && location.coordinate.longitude < -117.0
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationError = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = .permissionDenied
            case .locationUnknown:
                locationError = .locationUnknown
            case .network:
                locationError = .networkError
            default:
                locationError = .unknown
            }
        } else {
            locationError = .unknown
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            isLocationEnabled = false
            locationError = .permissionDenied
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}

// MARK: - Location Errors
enum LocationError: Error, LocalizedError {
    case permissionDenied
    case locationUnknown
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied"
        case .locationUnknown:
            return "Location could not be determined"
        case .networkError:
            return "Network error while getting location"
        case .unknown:
            return "Unknown location error"
        }
    }
}
