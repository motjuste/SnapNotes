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
    
    // TODO: - Do I need these Both?
    var contentIndex = 0
    var imageFilePath = ""
    
    override func viewDidLoad() {
        NoteImageView!.image = UIImage(contentsOfFile: imageFilePath)
    }
}
