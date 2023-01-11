//
//  LessonListView.swift
//  Photography
//
//  Created by Filip Karas on 11/01/2023.
//

import SwiftUI

struct LessonDetailView: View {
    var lesson: Lesson
    
    var body: some View {
        ScrollView {
            ZStack {
                Image("thumb-placeholder")
                    .resizable()
                    .frame(height: 225)
                    .clipped()
                Image(systemName: "play.fill")
                    .font(.system(size: 60))
            }
            Group {
                Text(lesson.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.vertical, 16)
                Text(lesson.description)
            }
            .padding(.horizontal, 16)
            HStack {
                Spacer()
                Button {
                    
                } label: {
                    Text("Next Lesson")
                    Image(systemName: "chevron.right")
                        .font(.system(size: 22, weight: .medium))
                }
                .padding(.trailing, 16)
                .padding(.top, 16)
            }
            Spacer()
        }
        .background(Color(.systemGray6))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                
            } label: {
                Image(systemName: "icloud.and.arrow.down")
                Text("Download")
            }
        }
    }
}

struct LessonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LessonDetailView(lesson: Lesson(
            id: 950,
            name: "The Key To Success In iPhone Photography",
            description: "What’s the secret to taking truly incredible iPhone photos? Learning how to use your iPhone camera is very important, but there’s something even more fundamental to iPhone photography that will help you take the photos of your dreams! Watch this video to learn some unique photography techniques and to discover your own key to success in iPhone photography!",
            thumbnail: "https://embed-ssl.wistia.com/deliveries/b57817b5b05c3e3129b7071eee83ecb7.jpg?image_crop_resized=1000x560",
            video_url: "https://embed-ssl.wistia.com/deliveries/cc8402e8c16cc8f36d3f63bd29eb82f99f4b5f88/accudvh5jy.mp4"
        ))
            .preferredColorScheme(.dark)
    }
}
