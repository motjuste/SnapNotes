//
//  Categories.swift
//  SnapNotes
//
//  Created by Abdullah on 10/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import Foundation

class Categories {
    let id: String
    var name: String
    var order: Int
//    var notesList: [Note] = [] //{
////        didSet {
////            // TODO: Move this to NotesManager
////            notesList.sort{ $0.date!.greaterThan($1.date!) }
////        }
////    }
//    
    init(id: String, name:String, order: Int) {
        self.id = id
        self.name = name
        self.order = order
    }
//
//    func addNote(newNote: Note) {
//        notesList.append(newNote)
//    }
//    
//    func deleteNote(selectedNoteIndex: Int) {
//        notesList.removeAtIndex(selectedNoteIndex)
//    }
}