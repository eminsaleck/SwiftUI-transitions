// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUI-transitions",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Transitions",
            targets: ["Transitions"]),
        .library(
            name: "SwipeGesture",
            targets: ["SwipeGesture"]),
    ],
    targets: [
        .target(
            name: "Transitions"),
        .target(
            name: "SwipeGesture")
    ]
)
