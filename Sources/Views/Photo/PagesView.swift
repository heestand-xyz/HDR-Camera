////
////  PagesView.swift
////  Layer Camera
////
////  Created by Anton Heestand on 2021-02-14.
////  Copyright © 2021 Hexagons. All rights reserved.
////
//
//import SwiftUI
//import UIKit
//
//struct PagesView<Page: View>: UIViewControllerRepresentable {
//
//    @Binding var pageIndex: Int
//    var pages: () -> ([(id: UUID, view: Page)])
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIViewController(context: Context) -> UIPageViewController {
//        let pageViewController = UIPageViewController(
//            transitionStyle: .scroll,
//            navigationOrientation: .horizontal)
//
//        pageViewController.dataSource = context.coordinator
//        pageViewController.delegate = context.coordinator
//
//        return pageViewController
//    }
//
//    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
//
//        pageViewController.setViewControllers(
//            [context.coordinator.controllers[pageIndex].viewController], direction: .forward, animated: true)
//    }
//
//    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//
//        var parent: PagesView
//        var controllers = [(id: UUID, viewController: UIViewController)]()
//
//        init(_ pageViewController: PagesView) {
//            parent = pageViewController
//            controllers = parent.pages().map { (id: $0.id, viewController: UIHostingController(rootView: $0.view)) }
//            print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", parent.pages().map(\.id))
//        }
//
//        func pageViewController(
//            _ pageViewController: UIPageViewController,
//            viewControllerBefore viewController: UIViewController) -> UIViewController?
//        {
//            guard let pack: (id: UUID, viewController: UIViewController) = controllers.first(where: { $0.viewController == viewController }) else {
//                return nil
//            }
//            guard let index: Int = controllers.map(\.id).firstIndex(of: pack.id) else {
//                return nil
//            }
//            print(">>>> >>>> >>>> <-", index, pack.id)
//            if index == 0 {
//                return nil
//            }
//            return controllers.map(\.viewController)[index - 1]
//        }
//
//        func pageViewController(
//            _ pageViewController: UIPageViewController,
//            viewControllerAfter viewController: UIViewController) -> UIViewController?
//        {
//            guard let pack: (id: UUID, viewController: UIViewController) = controllers.first(where: { $0.viewController == viewController }) else {
//                return nil
//            }
//            guard let index: Int = controllers.map(\.id).firstIndex(of: pack.id) else {
//                return nil
//            }
//            print(">>>> >>>> >>>> ->", index, pack.id)
//            if index + 1 == controllers.count {
//                return nil
//            }
//            return controllers.map(\.viewController)[index + 1]
//        }
//
//        func pageViewController(_ pageViewController: UIPageViewController,
//                                didFinishAnimating finished: Bool,
//                                previousViewControllers: [UIViewController],
//                                transitionCompleted completed: Bool) {
//            print(">>>>>>>", previousViewControllers.map({ vc in
//                controllers.first(where: { pack in
//                    pack.viewController == vc
//                })?.id
//            }))
//            if completed,
//               let visibleViewController = pageViewController.viewControllers?.first,
//               let pack: (id: UUID, viewController: UIViewController) = controllers.first(where: { $0.viewController == visibleViewController }),
//               let index: Int = controllers.map(\.id).firstIndex(of: pack.id) {
//                print(">>>>>>>>>>>>>>>>>>>>>>>>>>", index, pack.id)
//                parent.pageIndex = index
//            }
//        }
//
//    }
//
//}
