//
//  FriendsController.swift
//  facebooknewsfeed
//
//  Created by Brian Voong on 2/16/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var friends: [Friend]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.whiteColor()

        // Register cell classes
        self.collectionView!.registerClass(FriendCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends != nil ? friends!.count : 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let friendCell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FriendCell
        
        if let friend = friends?[indexPath.item], name = friend.name, picture = friend.picture {
            friendCell.nameLabel.text = name
            
            friendCell.userImageView.image = nil
            
            if let url = NSURL(string: picture) {
                if let image = FriendsController.imageCache.objectForKey(url) as? UIImage {
                    friendCell.userImageView.image = image
//                    print("cache hit for \(name)")
                } else {
                    NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                        if error != nil {
                            print(error)
                            return
                        }
                        
                        let image = UIImage(data: data!)
                        FriendsController.imageCache.setObject(image!, forKey: url)
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            friendCell.userImageView.image = image
                        })
                        
                    }).resume()
                }
                
            }
        }
        return friendCell
    }
    
    static let imageCache = NSCache()
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.width, 50)
    }
}

class FriendCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(14)
        return label
    }()
    
    let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        return imageView
    }()
    
    func setupViews() {
        addSubview(userImageView)
        addSubview(nameLabel)
        
        addConstraintsWithFormat("H:|-8-[v0(48)]-8-[v1]|", views: userImageView, nameLabel)
        
        addConstraintsWithFormat("V:|[v0]|", views: nameLabel)
        
        addConstraintsWithFormat("V:|-8-[v0(48)]", views: userImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}