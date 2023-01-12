//
//  LessonDetailViewController.swift
//  Photography
//
//  Created by Filip Karas on 12/01/2023.
//

import SwiftUI

struct LessonDetailView: UIViewControllerRepresentable {
  
    var lesson: LessonModel
    var lessons: [LessonModel]
    var dataModel: DataModel
    
    func makeUIViewController(context: Context) -> LessonDetailViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: "LessonDetail") as! LessonDetailViewController
        controller.lesson = lesson
        controller.lessons = lessons
        controller.dataModel = dataModel
        return controller
    }

    func updateUIViewController(_ uiViewController: LessonDetailViewController, context: Context) {
        
    }
}
