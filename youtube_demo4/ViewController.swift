//
//  ViewController.swift
//  youtube_demo4
//
//  Created by Brian Voong on 2/17/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate  {

    let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(20)
        label.textAlignment = .Center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let showFriendsButton: UIButton = {
        let button = UIButton(type: .System)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show Friends", forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(12)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.translucent = false
        
        view.backgroundColor = UIColor.whiteColor()
        navigationItem.title = "Facebook Login"
        
        setupSubviews()
        
        if let _ = FBSDKAccessToken.currentAccessToken() {
            fetchProfile()
        }
    }
    
    func setupSubviews() {
        view.addSubview(loginButton)
        view.addSubview(userImageView)
        view.addSubview(nameLabel)
        view.addSubview(showFriendsButton)
        
        showFriendsButton.addTarget(self, action: "showFriends", forControlEvents: .TouchUpInside)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": userImageView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": nameLabel]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-80-[v0]-80-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": showFriendsButton]))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-80-[v0]-80-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": loginButton]))
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-8-[v0(100)]-8-[v1(30)]-8-[v2(50)]-8-[v3(44)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": userImageView, "v1": nameLabel, "v2": loginButton, "v3": showFriendsButton]))
        
        loginButton.delegate = self
    }
    
    func showFriends() {
        let parameters = ["fields": "name,picture.type(normal),gender"]
        FBSDKGraphRequest(graphPath: "me/taggable_friends", parameters: parameters).startWithCompletionHandler({ (connection, user, requestError) -> Void in
            if requestError != nil {
                print(requestError)
                return
            }
            
            var friends = [Friend]()
            for friendDictionary in user["data"] as! [NSDictionary] {
                let name = friendDictionary["name"] as? String
                if let picture = friendDictionary["picture"]?["data"]?!["url"] as? String {
                    let friend = Friend(name: name, picture: picture)
                    friends.append(friend)
                }
            }
            
            let friendsController = FriendsController(collectionViewLayout: UICollectionViewFlowLayout())
            friendsController.friends = friends
            self.navigationController?.pushViewController(friendsController, animated: true)
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        })
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        fetchProfile()
    }
    
    func fetchProfile() {
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, user, requestError) -> Void in
            
            if requestError != nil {
                print(requestError)
                return
            }
            
            var _ = user["email"] as? String
            let firstName = user["first_name"] as? String
            let lastName = user["last_name"] as? String
            
            self.nameLabel.text = "\(firstName!) \(lastName!)"
            
            var pictureUrl = ""
            
            if let picture = user["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary, url = data["url"] as? String {
                pictureUrl = url
            }
            
            let url = NSURL(string: pictureUrl)
            NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
                if error != nil {
                    print(error)
                    return
                }
                
                let image = UIImage(data: data!)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.userImageView.image = image
                })
                
            }).resume()
            
        })
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
}

struct Friend {
    var name, picture: String?
}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerate() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
