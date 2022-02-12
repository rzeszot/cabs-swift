import Foundation

struct DistanceCalculator {
    func calculateByMap(latitudeFrom: Double, longitudeFrom: Double, latitudeTo: Double, longitudeTo: Double) -> Double {
        42
    }


    func calculateByGeo(latitudeFrom: Double, longitudeFrom: Double, latitudeTo: Double, longitudeTo: Double) -> Double {
        // https://www.geeksforgeeks.org/program-distance-two-points-earth/
        // The math module contains a function
        // named toRadians which converts from
        // degrees to radians.

        let lon1 = deg2rad(longitudeFrom)
        let lon2 = deg2rad(longitudeTo)
        let lat1 = deg2rad(latitudeFrom)
        let lat2 = deg2rad(latitudeTo)

        // Haversine formula
        let dlon = lon2 - lon1;
        let dlat = lat2 - lat1;

        let a = pow(sin(dlat / 2), 2)
                + cos(lat1) * cos(lat2)
                * pow(sin(dlon / 2),2)

        let c = 2 * asin(sqrt(a));

        // Radius of earth in kilometers. Use 3956 for miles
        let r: Double = 6371

        // calculate the result
        let distanceInKMeters = c * r

        return distanceInKMeters
    }
}

func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}
