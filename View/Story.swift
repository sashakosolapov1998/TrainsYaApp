//
//  Story.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 7/9/25.
//

import SwiftUI

// MARK: - Модель
struct Story: Identifiable, Hashable, Sendable {
    let id = UUID()
    let imageName: String
    var isViewed: Bool
}

// MARK: - Ячейка
struct StoryThumb: View {
    let story: Story
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(story.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 92, height: 140)
                .clipped()
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(story.isViewed ? Color.clear : Color.trainsBlue, lineWidth: 10))
            
            Text("Text Text Text Text Text Text Text Text Text")
                .font(.caption.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
                .lineLimit(3)
        }
        .frame(width: 92, height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(story.isViewed ? 0.5 : 1.0)
        .saturation(story.isViewed ? 0.7 : 1.0)
    }
}

// MARK: - Полноэкранный
struct StoriesViewer: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var stories: [Story]
    @Binding var currentIndex: Int
    
    @StateObject private var vm: StoriesViewerViewModel

    init(stories: Binding<[Story]>, currentIndex: Binding<Int>) {
        _stories = stories
        _currentIndex = currentIndex
        _vm = StateObject(wrappedValue: StoriesViewerViewModel(
            stories: stories.wrappedValue,
            currentIndex: currentIndex.wrappedValue,
            stepDuration: 3.0
        ))
    }

    var body: some View {
        ZStack {
            TabView(selection: $vm.currentIndex) {
                ForEach(vm.stories.indices, id: \.self) { i in
                    GeometryReader { geo in
                        ZStack(alignment: .bottomLeading) {
                            Image(vm.stories[i].imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text")
                                    .font(.system(size: 34, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .padding(.horizontal, 16)

                                Text("Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                                    .lineLimit(3)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 40)
                            }

                            VStack(spacing: 8) {
                                HStack(spacing: 6) {
                                    ForEach(vm.stories.indices, id: \.self) { i in
                                        ZStack(alignment: .leading) {
                                            Capsule().fill(.white.opacity(0.35))
                                            GeometryReader { proxy in
                                                let w = proxy.size.width
                                                TimelineView(.animation) { _ in
                                                    let elapsed: TimeInterval = Date.now.timeIntervalSince(vm.startDate)
                                                    let pct: CGFloat = CGFloat(min(1, max(0, elapsed / vm.stepDuration)))
                                                    let fill: CGFloat = (
                                                        i < vm.currentIndex ? w :
                                                        (i > vm.currentIndex ? .zero : w * pct)
                                                    )
                                                    Capsule()
                                                        .fill(Color.trainsBlue)
                                                        .frame(width: fill)
                                                }
                                            }
                                        }
                                        .frame(height: 4)
                                    }
                                }

                                HStack {
                                    Spacer()
                                    Button { dismiss() } label: {
                                        ZStack {
                                            Image(systemName: "circle.fill")
                                                .frame(width: 26, height: 26)
                                                .foregroundStyle(.white)
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 26, weight: .semibold))
                                                .foregroundStyle(.black)
                                        }
                                    }
                                }
                            }
                            .zIndex(10)
                            .padding(.bottom, 693)
                            .padding(.leading, 12)
                            .padding(.trailing, 12)

                            HStack(spacing: 0) {
                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture { vm.prev() }

                                Color.clear
                                    .contentShape(Rectangle())
                                    .onTapGesture { vm.next() }
                            }
                            .ignoresSafeArea()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                    .contentShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                    .containerRelativeFrame(.horizontal)
                    .tag(i)
                    .onAppear {
                        vm.restart()
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .never))
            .ignoresSafeArea(.container, edges: .horizontal)
            .background(Color.black)
        }
        .onChange(of: vm.currentIndex) { newValue in
            currentIndex = newValue
        }
        .onChange(of: currentIndex) { newValue in
            vm.currentIndex = newValue
            vm.restart()
        }
        .onChange(of: vm.stories) { newValue in
            stories = newValue
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}

// MARK: - Лента
struct StoriesStrip: View {
    @Binding var stories: [Story]
    var onSelect: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(stories.indices, id: \.self) { i in
                    StoryThumb(story: stories[i])
                        .onTapGesture { onSelect(i) }
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
}


// MARK: - Preview
#Preview {
    StoryThumb(story: PreviewContainer().stories[2])
}

private struct PreviewContainer: View {
    @State var stories: [Story] = [
        Story(imageName: "stories1", isViewed: false),
        Story(imageName: "stories2", isViewed: true),
        Story(imageName: "stories3", isViewed: true),
        Story(imageName: "stories4", isViewed: false)
    ]
    @State var currentIndex: Int = 0
    
    var body: some View {
        StoriesViewer(stories: $stories, currentIndex: $currentIndex)
    }
}
