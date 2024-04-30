//
//  ToDoListTableViewCell.swift
//  ToDoList
//
//  Created by Maryna Poliakova-Bilous on 13.04.2024.
//

import UIKit

class ToDoListTableViewCell: UITableViewCell {
    var toggleDone: (() -> Void)?
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func selectCheckBox(_ sender: Any) {
          toggleDone?()
    }
   
    func configureWithItem(_ item: ToDoListItem) {
        let buttonImage =  UIImage(systemName: item.completed ? "checkmark.circle.fill" : "circle")
        
        checkBoxButton.setImage(buttonImage, for: .normal)
        title.textColor = item.completed ? UIColor.gray : UIColor.black
    }
}
