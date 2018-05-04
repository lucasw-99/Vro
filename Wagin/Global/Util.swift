import UIKit

class Util {
    static func makeOKAlert(alertTitle: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }

    static func displaySpinner(onView: UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }

        return spinnerView
    }

    static func removeSpinner(_ spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }

    static func toggleButton(button: UIButton, isEnabled: Bool) {
        button.isEnabled = isEnabled
        button.alpha = isEnabled ? 1.0 : 0.5
    }

    static func makeImageCircular(image: UIImageView) {
        image.layer.cornerRadius = image.frame.size.width / 2
        image.clipsToBounds = true
    }

    static func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    static func initializeTabViewControllers(tabBar: UITabBarController, storyBoard: UIStoryboard) {
//        let newsFeedController = storyBoard.instantiateViewController(withIdentifier: "NewsFeed")
        let newsFeedController = NewsFeedViewController()
        newsFeedController.title = "News Feed"
        newsFeedController.tabBarItem = UITabBarItem(title: "News Feed", image: #imageLiteral(resourceName: "people"), tag: 0)

        let manageProfileController = storyBoard.instantiateViewController(withIdentifier: "ManageProfile")
        manageProfileController.title = "Manage Profile"
        manageProfileController.tabBarItem = UITabBarItem(title: "Manage Profile", image: #imageLiteral(resourceName: "settings"), tag: 1)

        let nearYouController = storyBoard.instantiateViewController(withIdentifier: "NearYou")
        nearYouController.title = "Near You"
        nearYouController.tabBarItem = UITabBarItem(title: "Near You", image: #imageLiteral(resourceName: "map_marker"), tag: 2)

        let newEventController = NewEventDummyViewController()
        newEventController.title = "New Event"
        newEventController.tabBarItem = UITabBarItem(title: "New Event", image: #imageLiteral(resourceName: "create_new"), tag: 3)

        let tabBarItems = [newsFeedController, manageProfileController, nearYouController, newEventController]

        tabBar.viewControllers = tabBarItems 
    }

    static func currentDate(date: Date) {
        let calendar = Calendar.current

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)


    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the amount of nanoseconds from another date
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        if nanoseconds(from: date) > 0 { return "\(nanoseconds(from: date))ns" }
        return ""
    }
}
