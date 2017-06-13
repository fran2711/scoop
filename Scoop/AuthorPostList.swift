//
//  AuthorPostList.swift
//  Scoop
//
//  Created by Fran Lucena on 13/6/17.
//  Copyright © 2017 Fran Lucena. All rights reserved.
//

import UIKit
import Firebase

class AuthorPostList: UITableViewController {

    //MARK: - Properties
    let cellIdentifier = "cellId"
    
    var model: [Posts] = []
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(hadleRefresh(_:)), for: UIControlEvents.valueChanged)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Se recupera el usuario logado y se crean dos observers para los post del usuario y por si alguno de ellos es eliminado
        if let userId = FIRAuth.auth()?.currentUser?.uid {
            PostsModel.recoverUserPost(event: .value, userId: userId, completion: { (posts) in
                self.model = posts
                self.tableView.reloadData()
            })
            PostsModel.recoverUserPost(event: .childRemoved, userId: userId, completion: { (posts) in
                self.model = posts
                self.tableView.reloadData()
            })
        }
    }
    
    //MARK: - Funcions
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let post = model[indexPath.row]
        cell.textLabel?.text = post.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let post = self.model[indexPath.row] as Posts
        

        let publish = UITableViewRowAction(style: .normal, title: "Publish") { (action, indexPath) in
            posts.removeAllObservers()
            
            PostsModel.publishPost(postId: post.cloudRef!, completion: { (result) in
                print(result.description)
                
        })
            
            if let userId = FIRAuth.auth()?.currentUser?.uid {
                PostsModel.recoverUserPost(event: .value, userId: userId, completion: { (posts) in
                    self.model = posts
                    self.tableView.reloadData()
                })
                PostsModel.recoverUserPost(event: .childRemoved, userId: userId, completion: { (posts) in
                    self.model = posts
                    self.tableView.reloadData()
                })
            }
            
            
        }
        publish.backgroundColor = UIColor.green
        
        let deleteRow = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            PostsModel.deletePost(post: post, completion: { (result) in
                print(result.description)
            
            })
        }
        return [publish, deleteRow]
    }

}
