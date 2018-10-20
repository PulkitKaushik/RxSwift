//
//  ViewControllerTVC.swift
//  Experiment
//
//  Created by Pulkit Kaushik on 10/12/18.
//  Copyright © 2018 Pulkit Kaushik. All rights reserved.
//

import UIKit

class ViewControllerTVC: UITableViewCell {

    // MARK:- IBOutlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCellUIAndData(with isSwitchOn: Bool, andName name: String) {
        imgView.isHidden = !isSwitchOn
        titleLbl.text = name
    }
    
    func setCellSections(with indexPath: IndexPath) {
        imgView.isHidden = true
        titleLbl.text = "(Section No is \(indexPath.row))"
    }
}
