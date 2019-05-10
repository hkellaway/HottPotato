# HottPotato

Delicious HTTP requests :fire: :potato:

I got tired of writing networking code over and over again for side projects, so I made something I could quickly toss in.

## Features
[![CocoaPods](https://img.shields.io/badge/pod-v0.1.0-blue.svg)](http://cocoapods.org/pods/HottPotato) 
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage) 
[![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Build Status](https://travis-ci.org/hkellaway/HottPotato.svg?branch=develop)](https://travis-ci.org/hkellaway/HottPotato)

* Simple HTTP requests
* Automatic parsing of `Decodable` models

## Getting Started

- [Download HottPotato](https://github.com/hkellaway/HottPotato/archive/master.zip) and do a `pod install` on the included `HottPotatoDemo` app to see it in action
- Check out the [documentation](http://cocoadocs.org/docsets/HottPotato/) for a more comprehensive look at the classes available in HottPotata

### Swift Version

Currently compatible with Swift 5.0.

### Installation with CocoaPods

```ruby
pod 'HottPotato', :git => 'https://github.com/hkellaway/HottPotato.git', :tag => '0.1.0'
```

### Installation with Carthage

```
github "hkellaway/HottPotato"
```

### Installation with Swift Package Manager

``` swift
import PackageDescription

let package = Package(
    name: "HelloWorld",
    dependencies: [
        .Package(url: "https://github.com/hkellaway/HottPotato.git", majorVersion: 0, minor: 1)
    ]
)
```

## Usage

### Retrieving Models

To make a request, create an `HTTPResource` with a type that is `Decodable` and enjoy receiving the `Result`.

```swift
let httpClient = HottPotato.shared
let resource = HTTPResource<GitHubProfile>(
    method: .GET,
    baseURL: "https://api.github.com",
    path: "/users/hkellaway"
)

httpClient.sendRequest(for: resource) { result in
	switch result {
		case .success(let profile):
			print("Hello world from \(profile.login)")
		case .failure(let error):
			print("Goodbye world: \(error.localizedDescription)")
	}
}

```

### Discussion

HottPotato simply wraps `URLSession` and leverages some preferred context and patterns. Namely, it assumes we're making HTTP requests and that we're receiving JSON back. Additionally, it uses the `Result` type in its response.

#### Retrieving JSON

Internally, HottPotato retrieves JSON - if you'd rather used it to query this data, simply:

```swift
guard let request = resource.toHTTPRequest() else {
	return
}

httpClient.sendJSONRequest(with: request, success: { (_, json) in
	print(json)
}, failure: { error in
	print(error)
})
```

#### Retrieving Raw Data and HTTPURLResponse

At its very heart, HottPotato simply makes a `URLRequest` using `URLSession` and returns the retrieved `Data` and `HTTPURLResponse`. If you'd rather use it to query this data, simply: 

```swift
```swift
httpClient.sendHTTPRequest(with: request, success: { (_, response) in
	print(response.statusCode)
}, failure: { error in
	print(error)
})

```

## Credits

HottPotato was created by [Harlan Kellaway](http://harlankellaway.com).

## License

HottPotato is available under the MIT license. See the [LICENSE](https://raw.githubusercontent.com/hkellaway/HottPotato/master/LICENSE) file for more info.
