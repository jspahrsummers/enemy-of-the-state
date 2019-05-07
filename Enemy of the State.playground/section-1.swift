import UIKit

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
p.scale(factor: 2)

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

class MyViewController: UITableViewController {
	var items: [String] = []

	@IBAction func addBlankRow(sender: AnyObject) {
		self.items.append("")

		let indexPath = IndexPath(row: self.items.count, section: 0)
		self.tableView.insertRows(at: [ indexPath ], with: .automatic)
	}
}

func formattedCurrentTime() -> String {
	let now = Date()

	let formatter = DateFormatter()
	formatter.timeStyle = .medium

	return formatter.string(from: now)
}

formattedCurrentTime()

func formattedTimeFromDate(date: Date) -> String {
	let formatter = DateFormatter()
	formatter.timeStyle = .medium

	return formatter.string(from: date)
}

formattedTimeFromDate(date: Date())
