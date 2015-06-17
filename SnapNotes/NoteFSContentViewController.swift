//
//  NoteFSContentViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 17/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit

class NoteFSContentViewController: UIViewController {

    @IBOutlet weak var NoteImageView: UIImageView!
    
    // ???
    var contentIndex = 0
    
    var imageFileName = "" {
        didSet {
            if let imageView = NoteImageView {
                imageView.image = UIImage(named: imageFileName)
            }
        }
    }
    var category = ""
    var note: Note? {
        didSet {
            imageFileName = note!.imageFileName
            category = note!.categoryID!
        }
    }
    
    override func viewDidLoad() {
        NoteImageView!.image = UIImage(named: imageFileName)
    }
}
