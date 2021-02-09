//
//  FeedViewController.swift
//  parstagram
//
//  Created by Saul Fernandez on 2/8/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.row]
        let user  = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.photoView.af_setImage(withURL: url)
        
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    var posts = [PFObject]()
    @IBOutlet weak var tableView: UITableView!
    let myRefreshControll = UIRefreshControl()
    var numOfPosts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        myRefreshControll.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = myRefreshControll
        // Do any additional setup after loading the view.
    }
    
    @objc func loadPosts() {
        let query = PFQuery(className:"Posts")
        query.includeKey("author")
        query.limit = numOfPosts
        query.findObjectsInBackground{ (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.posts.reverse()
                self.tableView.reloadData()
                self.myRefreshControll.endRefreshing()
            }
        }
    }
    
    @objc func loadMorePosts() {
        let query = PFQuery(className:"Posts")
        query.includeKey("author")
        numOfPosts = numOfPosts + 20
        query.limit = numOfPosts
        query.findObjectsInBackground{ (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.posts.reverse()
                self.tableView.reloadData()
                self.myRefreshControll.endRefreshing()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row+1 == posts.count {
            loadMorePosts()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadMorePosts()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
