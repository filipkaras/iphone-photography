//
//  LessonListView.swift
//  Photography
//
//  Created by Filip Karas on 11/01/2023.
//

import SwiftUI
import CachedAsyncImage

struct LessonListView: View {
    
    @StateObject var vm = LessonListViewModel(url: URL(string: K.Api.Url)!)
    @StateObject var dataModel = DownloadManager()
    
    var body: some View {
        NavigationView {
            List(vm.lessons) { lesson in
                NavigationLink {
                    LessonDetailView(lesson: lesson, lessons: vm.lessons, dataModel: dataModel)
                        .background(Color(.systemGray6))
                        .edgesIgnoringSafeArea(.bottom)
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    LessonItemView(lesson: lesson)
                }
                .foregroundColor(.blue)
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Lessons")
            .background(Color(.systemGray6))
        }
    }
}

struct LessonItemView: View {
    var lesson: LessonModel
    var body: some View {
        HStack {
            CachedAsyncImage(
                url: URL(string: lesson.thumbnail),
                content: { image in
                    image
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                },
                placeholder: {
                    Color.gray
                }
            )
            .frame(width: 100, height: 60)
            .cornerRadius(K.UI.Radius.normal)
            Text(lesson.name)
                .padding(.leading, K.UI.Space.small)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.vertical, K.UI.Space.xsmall)
    }
}

struct LessonListView_Previews: PreviewProvider {
    static var previews: some View {
        LessonListView()
            .preferredColorScheme(.dark)
    }
}
