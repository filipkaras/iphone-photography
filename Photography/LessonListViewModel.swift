//
//  DownloadData.swift
//  Photography
//
//  Created by Filip Karas on 11/01/2023.
//

import Foundation
import Combine

class LessonListViewModel: ObservableObject {
    
    @Published var lessons: [LessonModel] = []
    var cancellables = Set<AnyCancellable>()
    
    init() {
        getLessons()
    }
    
    func getLessons() {
        let url = URL(string: K.Api.Url)!
        URLSession.shared.dataTaskPublisher(for: url, cachedResponseOnError: true)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .tryMap { (data, response) -> Data in
                guard
                    let response = response as? HTTPURLResponse,
                    response.statusCode >= 200 && response.statusCode < 300 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: LessonsModel.self, decoder: JSONDecoder())
            .sink { completion in
                print("COMPLETION: \(completion)")
            } receiveValue: { [weak self] returnedLessons in
                self?.lessons = returnedLessons.lessons
            }
            .store(in: &cancellables)
    }
}
