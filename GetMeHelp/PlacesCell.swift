//
//  PlacesCell.swift
//  GetMeHelp
//
//  Created by Francis Furnelli on 12/19/20.
//

import UIKit
 
class PlacesCell: UITableViewCell {
    var linktoVC: ViewController?
    let heartButton = UIButton(type: .system)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        heartButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        heartButton.addTarget(self, action: #selector(handleFavoriteAction), for: .touchUpInside)
        accessoryView = heartButton
    }
    
    @objc private func handleFavoriteAction() {
        linktoVC?.flipFavorite(cell: self)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func drawHeart(toDraw: String) {
        heartButton.setImage(UIImage(systemName: toDraw), for: .normal)
        heartButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        heartButton.addTarget(self, action: #selector(handleFavoriteAction), for: .touchUpInside)
        accessoryView = heartButton
    }
    
}
