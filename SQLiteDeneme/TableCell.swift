//
//  TableCell.swift
//  SQLiteDeneme
//
//  Created by Enes Özkırdeniz on 21.10.2022.
//

import UIKit

class TableCell: UITableViewCell {

    static let identifier = "cell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
