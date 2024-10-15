// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AmosBase",
    defaultLocalization: "en",
    platforms: [ // 本 Package 适用的平台
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        // 产品定义包生成的可执行文件和库，并使其对其他包可见。
        .library(
            name: "AmosBase",
            targets: ["AmosBase"]
        )
    ],
    dependencies: [
    ],
    targets: [
        // 目标是包的基本构建块。目标可以定义模块或测试套件。
        // 目标可以依赖于此程序包中的其他目标，以及此程序包所依赖的程序包中的产品。
        .target(
            name: "AmosBase",
            path: "Sources",
            resources: [
                .process("Resources"),
                .process("Localization")
            ]
        )
    ]
)
