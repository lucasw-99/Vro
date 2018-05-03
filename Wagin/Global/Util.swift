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
        let newsFeedController = storyBoard.instantiateViewController(withIdentifier: "NewsFeed")
        newsFeedController.title = "News Feed"
        newsFeedController.tabBarItem = UITabBarItem(title: "News Feed", image: #imageLiteral(resourceName: "people"), tag: 0)

        let manageProfileController = storyBoard.instantiateViewController(withIdentifier: "ManageProfile")
        manageProfileController.title = "Manage Profile"
        manageProfileController.tabBarItem = UITabBarItem(title: "Manage Profile", image: #imageLiteral(resourceName: "settings"), tag: 1)

        let nearYouController = storyBoard.instantiateViewController(withIdentifier: "NearYou")
        nearYouController.title = "Near You"
        nearYouController.tabBarItem = UITabBarItem(title: "Near You", image: #imageLiteral(resourceName: "map_marker"), tag: 2)

        let newEventController = storyBoard.instantiateViewController(withIdentifier: "NewEvent")
        newEventController.title = "New Event"
        newEventController.tabBarItem = UITabBarItem(title: "New Event", image: #imageLiteral(resourceName: "create_new"), tag: 3)

        let tabBarItems = [newsFeedController, manageProfileController, nearYouController, newEventController]

        tabBar.viewControllers = tabBarItems 
    }
}
