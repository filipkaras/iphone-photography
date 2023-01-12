//
//  LessonListView.swift
//  Photography
//
//  Created by Filip Karas on 11/01/2023.
//

import SwiftUI
import AVKit

struct LessonDetailView: View {
    
    @Environment(\.isPresented) var isPresented
    @EnvironmentObject var vm: LessonListViewModel
    @State var videoLaunched: Bool = false
    @State var lesson: LessonModel
    @State var player = AVPlayer()
    @StateObject var dataModel = DataModel()
    
    var nextLessonAvailable: Bool {
        guard let index = vm.lessons.firstIndex(where: { $0.id == lesson.id }) else { return false }
        return index < vm.lessons.count - 1
    }
    
    init(lesson: LessonModel) {
        self.lesson = lesson
    }
    
    func switchToLextLesson() {
        let index = vm.lessons.firstIndex(where: { $0.id == lesson.id })!
        lesson = vm.lessons[index + 1]
        videoLaunched = false
        player.pause()
        dataModel.stopDownload()
    }
    
    var body: some View {
        ScrollView {
            ZStack {
                AsyncImage(
                    url: URL(string: lesson.thumbnail),
                    content: { image in
                        image
                            .resizable()
                            .frame(height: 220)
                            .clipped()
                    },
                    placeholder: {
                        Color.gray
                    }
                )
                Image(systemName: "play.fill")
                    .font(.system(size: 60))
                    .onTapGesture {
                        if dataModel.localFileExistsForUrlString(lesson.video_url) {
                            self.player = AVPlayer(url: dataModel.localFileUrlForUrlString(lesson.video_url)!)
                        } else {
                            self.player = AVPlayer(url: URL(string: lesson.video_url)!)
                        }
                        videoLaunched = true
                        player.play()
                    }
                VideoPlayer(player: player)
                    .frame(height: 220)
                    .opacity(videoLaunched ? 1 : 0)
                    .onChange(of: isPresented) { isPresented in
                        if !isPresented {
                            player.pause()
                            dataModel.stopDownload()
                        }
                    }
            }
            Group {
                Text(lesson.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.vertical, K.UI.Space.normal)
                Text(lesson.description)
            }
            .padding(.horizontal, K.UI.Space.normal)
            HStack {
                Spacer()
                Button {
                    switchToLextLesson()
                } label: {
                    Text("Next Lesson")
                    Image(systemName: "chevron.right")
                        .font(.system(size: 22, weight: .medium))
                }
                .padding(.trailing, K.UI.Space.normal)
                .padding(.top, K.UI.Space.normal)
                .opacity(nextLessonAvailable ? 1 : 0)
            }
            Spacer()
        }
        .background(Color(.systemGray6))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarButtons(dataModel: dataModel, lesson: lesson)
        }
    }
}

struct ToolbarButtons: View {
    
    @StateObject var dataModel: DataModel
    @State var lesson: LessonModel
    
    var body: some View {
        if dataModel.activeDownload != nil {
            CircularProgressView(progress: dataModel.progress)
                .opacity(dataModel.progress > 0 ? 1 : 0)
                .frame(width: 24)
        }
        if dataModel.activeDownload == nil && !dataModel.localFileExistsForUrlString(lesson.video_url) {
            Button {
                dataModel.downloadFromUrlString(lesson.video_url)
            } label: {
                Image(systemName: "icloud.and.arrow.down")
                Text("Download")
            }
        }
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.gray.opacity(0.5),
                    lineWidth: 2
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(.systemBlue),
                    style: StrokeStyle(
                        lineWidth: 2,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
    }
}

struct LessonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LessonDetailView(lesson: LessonModel(
            id: 950,
            name: "The Key To Success In iPhone Photography",
            description: "What’s the secret to taking truly incredible iPhone photos? Learning how to use your iPhone camera is very important, but there’s something even more fundamental to iPhone photography that will help you take the photos of your dreams! Watch this video to learn some unique photography techniques and to discover your own key to success in iPhone photography!",
            thumbnail: "https://embed-ssl.wistia.com/deliveries/b57817b5b05c3e3129b7071eee83ecb7.jpg?image_crop_resized=1000x560",
            video_url: "https://embed-ssl.wistia.com/deliveries/cc8402e8c16cc8f36d3f63bd29eb82f99f4b5f88/accudvh5jy.mp4"
        ))
        .environmentObject(LessonListViewModel())
            .preferredColorScheme(.dark)
    }
}
