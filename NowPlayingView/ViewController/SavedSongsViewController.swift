//
//  SavedSongViewController.swift
//  NowPlayingView
//
//  Created by Jason Goodney on 11/13/18.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.textColor = UIColor.Theme.primary
        detailTextLabel?.textColor = UIColor.Theme.primary
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class SavedSongsViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "SavedSongsCell")
        tableView.backgroundColor = UIColor.Theme.primaryBackground
        return tableView
    }()
    
    var containerItem: SPTAppRemoteContentItem? = nil {
        didSet {
            needsReload = true
        }
    }
    var contentItems = [SPTAppRemoteContentItem]()
    var needsReload = true
    
    var appRemote: SPTAppRemote {
        get {
            return AppDelegate.sharedInstance.appRemote
        }
    }
    
    func loadContent() {
        guard needsReload == true else {
            return
        }
        
        if let container = containerItem {
            appRemote.contentAPI?.fetchChildren(of: container) { (items, error) in
                if let contentItems = items as? [SPTAppRemoteContentItem] {
                    self.contentItems = contentItems
                }
                self.tableView.reloadData()
            }
        } else {
            appRemote.contentAPI?.fetchRecommendedContentItems(for: .default) { (items, error) in
                if let contentItems = items as? [SPTAppRemoteContentItem] {
                    self.contentItems = contentItems
                }
                self.tableView.reloadData()
            }
        }
        
        needsReload = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        loadContent()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

}

extension SavedSongsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedSongsCell", for: indexPath) as! SubtitleTableViewCell
        
        let item = contentItems[indexPath.item]
        
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.subtitle
        
        return cell
    }
}

extension SavedSongsViewController: UITableViewDelegate {
    
}
