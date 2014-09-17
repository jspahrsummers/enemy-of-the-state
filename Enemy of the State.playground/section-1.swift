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



class MyViewController: UITableViewController {
	var items: [String] = []

	@IBAction func addBlankRow(sender: AnyObject) {
		self.items.append("")

		let indexPath = NSIndexPath(forRow: self.items.count, inSection: 0)
		self.tableView.insertRowsAtIndexPaths([ indexPath ], withRowAnimation: UITableViewRowAnimation.Automatic)
	}
}



func formattedCurrentTime() -> String {
	let now = NSDate()

	let formatter = NSDateFormatter()
	formatter.timeStyle = NSDateFormatterStyle.MediumStyle

	return formatter.stringFromDate(now)
}

formattedCurrentTime()



func formattedTimeFromDate(date: NSDate) -> String {
	let formatter = NSDateFormatter()
	formatter.timeStyle = NSDateFormatterStyle.MediumStyle

	return formatter.stringFromDate(date)
}

formattedTimeFromDate(NSDate())