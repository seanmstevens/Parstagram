//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Sean Stevens on 3/25/22.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UICollectionViewDelegate {
    
    enum Section {
        case main
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Post>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Post>
    
    private lazy var dataSource = createDataSource()
    var posts = [Post]()
    var postsToRetrieve = 20
    var requestTimestamp: Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshFeed()
    }
    
    private func createDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, post in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCell.reuseIdentifier, for: indexPath) as? PostCell
            
            cell?.postImageView.layer.cornerRadius = 8
            cell?.post = post
            return cell
        }
        
        return dataSource
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(posts)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func configureCollectionView() {
        collectionView.collectionViewLayout = configureLayout()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func configureLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item >= (dataSource.snapshot().numberOfItems / 2) {
            retrievePosts(until: posts.last?.createdAt)
        }
    }
}

extension FeedViewController {
    @objc func refreshFeed() {
        retrievePosts(since: posts.first?.createdAt)
    }
    
    private func retrievePosts(
        since minTime: Date? = nil,
        until maxTime: Date? = nil,
        animatingDifferences: Bool = true
    ) {
        guard requestTimestamp == nil else { return }
        
        let query = Post.query()!
        query.includeKey("author")
        query.order(byDescending: "createdAt")
        query.limit = postsToRetrieve
        
        if let minTime = minTime {
            query.whereKey("createdAt", greaterThan: minTime)
        } else if let maxTime = maxTime {
            query.whereKey("createdAt", lessThan: maxTime)
        }
        
        requestTimestamp = Date()
        query.findObjectsInBackground { posts, error in
            if let error = error {
                print("Error retrieving posts: \(error.localizedDescription)")
            } else if let posts = posts as? [Post] {
                var insertionPoint = 0
                
                for post in posts {
                    if minTime != nil {
                        self.posts.insert(post, at: insertionPoint)
                        insertionPoint += 1
                    } else {
                        self.posts.append(post)
                    }
                }
                
                self.applySnapshot()
                self.requestTimestamp = nil
                self.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
}
