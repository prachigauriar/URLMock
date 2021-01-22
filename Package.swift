// swift-tools-version:5.2
import PackageDescription


let package = Package(
    name: "URLMock",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11)
    ],
    products: [
        .library(
            name: "URLMock",
            targets: ["URLMock"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "URLMock",
            publicHeadersPath: "Headers/Public",
            cSettings: [.headerSearchPath("Headers/Private")]
        )
    ]
)
