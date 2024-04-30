//
//  ToDoListTableViewController.swift
//  ToDoList
//
//  Created by Maryna Poliakova-Bilous on 13.04.2024.
//

import UIKit
class ToDoListTableViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var percentProgressLabel: UILabel!
    
    let cellIdentifier = "ToDoListTableViewCell"
    
    var viewModel: ToDoListViewModel!
    var dragInitialIndexPath: IndexPath?
    var dragCellSnapshot: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ToDoListViewModel(manager: CoreDataManager.shared)
        createTableView()
        setupAddButton()
        setUpProgressView()
        updateProgress()
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        let alert = UIAlertController(title: "New Task", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            self?.viewModel.addItem(title: text)
            self?.tableView.reloadData()
            self?.updateProgress()
        })
        
        submitAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(submitAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        let state = gestureRecognizer.state
        let location = gestureRecognizer.location(in: self.tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: location) else {
            return
        }
        
        switch state {
        case .began:
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            dragInitialIndexPath = indexPath
            dragCellSnapshot = snapshotOfCell(inputView: cell)
            animateCellLift(cell: cell, locationInView: location)
        case .changed:
            guard let snapshot = dragCellSnapshot else { return }
            updateSnapshotPosition(snapshot: snapshot, locationInView: location)
            maybeExchangeItems(indexPath: indexPath)
        case .ended, .cancelled:
            dropSnapshot()
        default:
            break
        }
    }
    
    func createTableView() {
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    func setupAddButton() {
        addButton.layer.cornerRadius = 15
        addButton.layer.borderWidth = 1.0
        addButton.layer.borderColor = UIColor.black.cgColor
    }
    
    func setUpProgressView() {
        progressView.layer.borderWidth = 1
        progressView.layer.borderColor = UIColor.black.cgColor
        progressView.layer.cornerRadius = 10 / 2
        progressView.progressTintColor = UIColor(named: "lime")
        progressView.trackTintColor = UIColor.white
        progressView.clipsToBounds = true
    }
    
    func updateProgress() {
        let total = viewModel.itemsCount
        let completed = viewModel.completedItemsCount
        let progress = total > 0 ? Float(completed) / Float(total) : 0
        progressView.setProgress(progress, animated: true)
        percentProgressLabel.text = "\(Int(progress*100))%"
        
    }
    
    // MARK: Drag and drop
    
    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cellSnapshot = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 100.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        
        return cellSnapshot
    }
    
    func animateCellLift(cell: UITableViewCell, locationInView: CGPoint) {
        var center = cell.center
        dragCellSnapshot?.center = center
        dragCellSnapshot?.alpha = 0.0
        tableView.addSubview(dragCellSnapshot!)
        
        UIView.animate(withDuration: 0.25, animations: {
            center.y = locationInView.y
            self.dragCellSnapshot?.center = center
            self.dragCellSnapshot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.dragCellSnapshot?.alpha = 0.99
            cell.alpha = 0.0
        }, completion: { finished in
            cell.isHidden = finished
        })
    }
    
    func updateSnapshotPosition(snapshot: UIView, locationInView: CGPoint) {
        var center = snapshot.center
        center.y = locationInView.y
        snapshot.center = center
    }
    func dropSnapshot() {
        guard let snapshot = dragCellSnapshot, let indexPath = dragInitialIndexPath else { return }
        
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.isHidden = false
        cell?.alpha = 0.0
        
        UIView.animate(withDuration: 0.25, animations: {
            snapshot.center = cell?.center ?? CGPoint.zero
            snapshot.transform = CGAffineTransform.identity
            snapshot.alpha = 0.0
            cell?.alpha = 1.0
        }, completion: { _ in
            self.dragInitialIndexPath = nil
            snapshot.removeFromSuperview()
            self.dragCellSnapshot = nil
        })
    }
    
    func maybeExchangeItems(indexPath: IndexPath) {
        guard let initialIndexPath = dragInitialIndexPath, initialIndexPath != indexPath else { return }
        
        viewModel.moveItem(from: initialIndexPath.row, to: indexPath.row)
        tableView.moveRow(at: initialIndexPath, to: indexPath)
        dragInitialIndexPath = indexPath
    }
}

