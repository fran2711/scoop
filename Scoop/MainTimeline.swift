//
//  ViewController.swift
//  Scoop
//
//  Created by Fran Lucena on 7/6/17.
//  Copyright © 2017 Fran Lucena. All rights reserved.
//

import UIKit
import Firebase

class MainTimeline: UITableViewController {

    //MARK: - Properties
    var model : [Posts] = []
    let cellIdentier = "cellId"
    
    //MARK: - Outlets
    @IBOutlet weak var addPost: UIBarButtonItem!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
        
        self.refreshControl?.addTarget(self, action: #selector(hadleRefresh(_:)), for: UIControlEvents.valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        PostsModel.recoverPost(event: .value) { (posts) in
            self.model = posts
            self.tableView.reloadData()
        }
        
        if let _ = FIRAuth.auth()?.currentUser {
            addPost.isEnabled = true
        } else {
            addPost.isEnabled = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Functions
    func hadleRefresh(_ refreshControl: UIRefreshControl) {
        
        refreshControl.endRefreshing()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentier)
        
        let post: Posts = model[indexPath.row]
        
        cell.textLabel?.text = post.title
        
        var averageRating : Float = 0
        if post.cumulativeRating > 0 {
            averageRating = Float(String(format: "%.2f", Float(post.cumulativeRating) / Float(post.numRatings)))!
        }
        
        
        if post.photo != "" {
            do {
                let data = try getFileFrom(urlString: post.photo.replacingOccurrences(of: "/Post%2F", with: "/Post%2Fthumb_"))
                if data != nil {
                    cell.imageView?.imageFromServerURLThumb(urlString: post.photo.replacingOccurrences(of: "/Post%2F", with: "/Post%2Fthumb_"))
                }
            } catch {
                cell.imageView?.imageFromServerUrl(urlString: post.photo)
            }
        } else {
            cell.imageView?.imageFromServerUrl(urlString: post.photo)
        }
        
        cell.detailTextLabel?.text = post.userName + " -- " + "Rating: " + averageRating.description
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowRatingPost", sender: indexPath)
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRatingPost" {
            let vc = segue.destination as! PostReview
            let lastSelectedIndex = self.tableView.indexPathForSelectedRow?.last
            vc.post = model[lastSelectedIndex!]
        }
    }
}

