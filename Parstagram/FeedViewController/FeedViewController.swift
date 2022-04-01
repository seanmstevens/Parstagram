//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Sean Stevens on 3/25/22.
//

import UIKit
import Parse
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, MessageInputBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private typealias DataSource = UITableViewDiffableDataSource<IdentifiablePFObject.ID, FeedItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<IdentifiablePFObject.ID, FeedItem>
    private typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<FeedItem>
    
    private lazy var dataSource = createDataSource()
    var posts = [Post]()
    var postsToRetrieve = 20
    var requestTimestamp: Date? = nil
    
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var selectedPost: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureObservers()
        configureCommentBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshFeed()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    private func createDataSource() -> DataSource {
        let dataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .post(let post):
                let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseIdentifier) as? PostCell
                
                cell?.postImageView.layer.cornerRadius = 8
                cell?.post = post
                return cell
            case .comment(let comment):
                let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.reuseIdentifier) as? CommentCell
                
                cell?.comment = comment
                return cell
            case .addComment:
                let cell = tableView.dequeueReusableCell(withIdentifier: AddCommentCell.reuseIdentifier) as? AddCommentCell
                
                return cell
            }
        }
        
        return dataSource
    }
    
    private func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections(posts.map { $0.id })
        
        for post in posts {
            snapshot.appendItems([FeedItem.post(post)], toSection: post.id)
            snapshot.appendItems(post.comments?.map { FeedItem.comment($0) } ?? [], toSection: post.id)
            snapshot.appendItems([FeedItem.addComment(post.id)], toSection: post.id)
        }
        
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.keyboardDismissMode = .interactive
        tableView.register(PostSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: PostSectionHeaderView.reuseIdentifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= (dataSource.snapshot().numberOfItems / 2) {
            retrievePosts(until: posts.last?.createdAt)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPost = posts[indexPath.section]
        
        if (indexPath.row == (selectedPost.comments?.count ?? 0) + 1) {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
        }
    }
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginViewController)
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
        query.includeKeys(["author", "comments", "comments.author"])
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
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension FeedViewController {
    private func configureObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureCommentBar() {
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
    }
    
    @objc private func keyboardWillBeHidden(notification: Notification) {
        dismissCommentBar()
    }
    
    private func dismissCommentBar() {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = Comment()
        comment.text = text
        comment.post = selectedPost
        comment.author = PFUser.current()
        
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground { success, error in
            if let error = error {
                print("Error creating comment: \(error.localizedDescription)")
            } else {
                print("Comment saved!")
            }
        }
        
        applySnapshot()
        dismissCommentBar()
    }
}
