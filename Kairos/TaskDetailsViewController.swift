//
//  TaskDetailsViewController.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import Former

class TaskDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateStartLabel: UILabel!
    @IBOutlet weak var dateEndLabel: UILabel!

    @IBOutlet weak var usersCollectionView: UICollectionView!
    
    private lazy var model: UserModelCollectionController = {
        let _model = UserModelCollectionController(self.usersCollectionView)
        _model.users = TaskManager.shared.users(for: self.task!)
        return _model
    }()

    var project: Project?
    var task: Task?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        usersCollectionView.delegate = model
        usersCollectionView.dataSource = model
        title = project?.title
        configureDetailsView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureDetailsView() {
        guard let task = task else {
            dismiss(animated: true, completion: nil)
            return
        }
        titleLabel.text = task.title
        descriptionLabel.text = task.notes
        dateStartLabel.text = String.shortDateNoTime(task.dateStart as! Date)
        dateEndLabel.text = String.shortDateNoTime(task.dateEnd as! Date)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "showEditTask":
                let destVC = segue.destination as! EditTaskTableViewController
                destVC.project = task?.project
                destVC.task = task
            default:
                break
            }
        }
        
    }
    
}
