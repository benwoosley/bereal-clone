//
//  FeedViewController.swift
//  bereal-clone
//
//  Created by Benjamin Woosley on 3/24/23.
//

import UIKit
import ParseSwift

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var posts = [Post]() {
        didSet {
            // Reload the table view any time the posts variable gets updated.
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        // Create a button and set its title
        let button = UIButton(type: .system)
        button.setTitle("Post a photo", for: .normal)
        button.addTarget(self, action: #selector(myButtonTapped(_:)), for: .touchUpInside)
    
        view.addSubview(button)
        
        // Add the button to the table view's header view
        tableView.tableHeaderView = button
        
        // Set the height of the header view
        tableView.tableHeaderView?.frame.size.height = 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        queryPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func myButtonTapped(_ sender: UIButton) {
        // Handle button tap
        performSegue(withIdentifier: "PostSegue", sender: nil)
    }
    
    private func queryPosts() {
        
        // https://github.com/parse-community/Parse-Swift/blob/3d4bb13acd7496a49b259e541928ad493219d363/ParseSwift.playground/Pages/2%20-%20Finding%20Objects.xcplaygroundpage/Contents.swift#L66
        // Get the date for yesterday. Adding (-1) day is equivalent to subtracting a day.
        // NOTE: `Date()` is the date and time of "right now".
        let yesterdayDate = Calendar.current.date(byAdding: .day, value: (-1), to: Date())!

        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])
            .where("createdAt" >= yesterdayDate) // <- Only include results created yesterday onwards
            .limit(10) // <- Limit max number of returned posts to 10
        
        // Fetch objects (posts) defined in query (async)
        query.find { [weak self] result in
            switch result {
            case .success(let posts):
                // Update local posts property with fetched posts
                self?.posts = posts
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }
    }
        
    @IBAction func onLogOutTapped(_ sender: Any) {
       showConfirmLogoutAlert()
    }
    
    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(title: "Log out of your account?", message: nil, preferredStyle: .alert)
        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
            
            // MARK: unsub notifs
            // Get the shared instance of the notification center
            let center = UNUserNotificationCenter.current()

            // Remove all pending notification requests
            center.removeAllPendingNotificationRequests()

            // Remove all delivered notifications from notification center
            center.removeAllDeliveredNotifications()

            // Unregister for all remote notifications
            UIApplication.shared.unregisterForRemoteNotifications()

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
    
extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        cell.configure(with: posts[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true) // NOT SURE THIS IS NEEDED
        return cell
    }
}

extension FeedViewController: UITableViewDelegate { }
