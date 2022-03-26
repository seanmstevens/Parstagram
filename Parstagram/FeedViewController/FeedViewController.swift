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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        retrievePosts()

        // Do any additional setup after loading the view.
    }
    
    private func retrievePosts() {
        let query = Post.query()!
        query.includeKey("author")
        query.order(byDescending: "createdAt")
        query.limit = postsToRetrieve
        
        query.findObjectsInBackground { posts, error in
            if let error = error {
                print("Error retrieving posts: \(error.localizedDescription)")
            } else if let posts = posts as? [Post] {
                self.posts = posts
                self.applySnapshot()
            }
        }
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
    }
    
    private func configureLayout() -> UICollectionViewLayout {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: config)
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
