//
//  LeaderboardViewController.swift
//  TriviaChallenge
//
//  Created by Paul Smith on 8/13/21.
//

import UIKit
import CoreData

class LeaderboardViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var highScoreTableView: UITableView!
    
    var fetchedResultsController:NSFetchedResultsController<HighScore>!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        titleLabel.underline()
        highScoreTableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        highScoreTableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: - Helper
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<HighScore> = HighScore.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "score", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
}

extension LeaderboardViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchedResultsController.fetchedObjects?.count ?? 0
        tableView.isHidden = count <= 0
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HighScoreCell")!

        guard let highScore = fetchedResultsController.fetchedObjects?[indexPath.row] else {
            return cell
        }
        
        let rank = indexPath.row + 1
        let highScoreName = !(highScore.name ?? "").trimmingCharacters(in: .whitespaces).isEmpty ? highScore.name! : "Anonymous"
        
        cell.textLabel?.text = "\(rank). \(highScoreName)"
        cell.detailTextLabel?.text = String(highScore.score)
        return cell
    }
    
}
