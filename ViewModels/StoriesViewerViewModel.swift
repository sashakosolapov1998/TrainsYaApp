//
//  StoriesViewerViewModel.swift
//  TrainsYa
//
//  Created by Александр Косолапов on 14/9/25.
//

import Foundation
import SwiftUI

@MainActor
final class StoriesViewerViewModel: ObservableObject {
    @Published var stories: [Story]
    @Published var currentIndex: Int
    @Published var didFinish = false

    @Published private(set) var startDate: Date = .now
    let stepDuration: TimeInterval

    private var progressTask: Task<Void, Never>?

    init(stories: [Story], currentIndex: Int, stepDuration: TimeInterval = 3.0) {
        self.stories = stories
        self.currentIndex = currentIndex
        self.stepDuration = stepDuration
    }

    deinit { progressTask?.cancel() }

    func start() {
        markCurrentViewed()
        restartTimer()
    }

    func stop() {
        progressTask?.cancel()
        progressTask = nil
    }

    func restart() {
        markCurrentViewed()
        restartTimer()
    }

    func next() {
        guard currentIndex < stories.count - 1 else { didFinish = true; return }
        currentIndex += 1
        restartTimer()
    }

    func prev() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        restartTimer()
    }

    private func restartTimer() {
        startDate = .now
        progressTask?.cancel()
        progressTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
            if Task.isCancelled { return }
            await self.next()
        }
    }

    private func markCurrentViewed() {
        guard stories.indices.contains(currentIndex) else { return }
        if !stories[currentIndex].isViewed {
            stories[currentIndex].isViewed = true
        }
    }
}

