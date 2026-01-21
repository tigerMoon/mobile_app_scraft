// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DiedOrNot",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "DiedOrNot",
            targets: ["DiedOrNot"])
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.5.0")
    ],
    targets: [
        .target(
            name: "DiedOrNot",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: ".")
    ]
)
