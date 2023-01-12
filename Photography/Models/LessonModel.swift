//
//  LessonModel.swift
//  Photography
//
//  Created by Filip Karas on 11/01/2023.
//

import Foundation

struct LessonModel: Identifiable, Codable {
    
    var id: Int
    var name: String
    var description: String
    var thumbnail: String
    var video_url: String
}

struct LessonsModel: Codable {
    
    var lessons: [LessonModel]
}
