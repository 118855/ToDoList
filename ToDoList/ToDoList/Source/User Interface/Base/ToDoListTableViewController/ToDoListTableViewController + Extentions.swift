//
//  ToDoListTableViewController + Extentions.swift
//  ToDoList
//
//  Created by Maryna Poliakova-Bilous on 27.04.2024.
//

import UIKit

extension ToDoListTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemsCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ToDoListTableViewCell
        let item = viewModel.itemAtIndex(indexPath.row)
        
        cell.title.text = item.title
        cell.toggleDone = { [weak self] in
            self?.viewModel.toggleIsDone(for: item)
            cell.configureWithItem(item)
            tableView.reloadRows(at: [indexPath], with: .none)
            self?.updateProgress()
        }
        
        DispatchQueue.main.async {
            cell.configureWithItem(item)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = viewModel.itemAtIndex(indexPath.row)
        let alert = UIAlertController(title: "Edit", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = model.title
        }
        
        let submitAction = UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let newTitle = field.text, !newTitle.isEmpty else {
                return
            }
            self?.viewModel.updateItemAtIndex(indexPath.row, with: newTitle)
            tableView.reloadRows(at: [indexPath], with: .none)
        })
        
        submitAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(submitAction)
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: {[weak self]
            (action, sourceView, completionHandler) in
            self?.viewModel.deleteItemAtIndex(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self?.updateProgress()
            completionHandler(true)
        })
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = false
        
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}

