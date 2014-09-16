struct Point {
	var x = 0.0
	var y = 0.0

	mutating func scale(factor: Double) {
		self.x *= factor
		self.y *= factor
	}
}

var p = Point(x: 5, y: 10)
let q = p

p.x = 7
p.scale(2)

q

class APIClient {
	class var sharedClient: APIClient {
		struct Singleton {
			static let instance = APIClient()
		}

		return Singleton.instance
	}
}

APIClient.sharedClient
