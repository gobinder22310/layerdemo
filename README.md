
[![Build Status](https://circleci.com/gh/layerhq/Atlas-Messenger-iOS.svg?style=shield&circle-token=:circle-token)](https://circleci.com/gh/layerhq/Atlas-Messenger-iOS)
![Atlas Header](Resources/atlas-github-header.png)

# Atlas Messenger iOS

This repository contains the source code of Atlas Messenger, an example application built by [Layer](https://layer.com/) to showcase the capabilities of [Atlas](https://github.com/layerhq/Atlas-iOS), a library of robust communications user interface components integrated with the Layer platform.

#### For Demo Purposes Only

You may be tempted to directly integrate Atlas Messenger code straight into your app as a shortcut, but this is not recommended. Developers that have tried to directly integrate Atlas Messenger code into existing apps without fully understanding how Layer concepts work end up frustrated and confused. Three important things to note about Atlas Messenger:

1. Atlas Messenger uses an Layer identity server and token provider designed to only be used with this project. You must use your own identity server and token provider when integrating Atlas into your application. For more information, check out our [Authentication Guide](https://developer.layer.com/docs/ios/guides).
1. Atlas Messenger has a cap of only 20 users.
1. The Layer identity server does not work with production app ids.

If you're interested in learning more about how Atlas works and how best to incorporate it into your application then please read the [Atlas Documentation](https://developer.layer.com/docs/ios/atlas).

## Getting Started

Building Atlas Messenger requires that you obtain a Layer App ID. You can obtain an App ID by registering for a Layer account on the [Experience Atlas](https://developer.layer.com/dashboard/signup/atlas) page. Alternately, a pre-built version is available for immediate testing [at the same location](https://developer.layer.com/dashboard/signup/atlas).

### Building Atlas Messenger

To build Atlas Messenger, you need a few a few standard iOS Development Tools:

1. [Xcode](https://developer.apple.com/xcode/) - Apple's suite of iOS and OS X development tools. Available on the [App Store](http://itunes.apple.com/us/app/xcode/id497799835).
2. [CocoaPods](http://cocoapods.org/) - The dependency manager for Cocoa projects. CocoaPods is used to automate the build and configuration of Atlas Messenger. Available by executing `$ sudo gem install cocoapods` in your terminal.

**Note:** Make sure to use CocoaPods >= 1.0.0.

#### Cloning & Preparing the Project

Once you have installed the prerequisites, you can proceed with cloning and configuring the project by executing the following commands in your terminal:

```sh
$ git clone --recursive https://github.com/layerhq/Atlas-Messenger-iOS.git
$ cd Atlas-Messenger-iOS
$ rake init
```

These commands will clone Atlas Messenger from Github, configure the Atlas submodule in the `Libraries` sub-directory, and then install all library dependencies via CocoaPods. Once these steps have completed without error, you can open the workspace by executing:

```sh
$ open "Atlas Messenger.xcworkspace"
```

##### Using git submodules and development pods

You may wish to develop/debug Atlas in tandem with Atlas-Messenger-iOS. To do so, use the `submodule` variant of the `rake init` task:

```sh
rake init:submodules ui=1
```

Then, the Atlas source code will appear in the Xcode _Project Navigator_ under `Pods > Development Pods > Atlas`.

**Note:**
 
To use the internal LayerKit repository as a development pod, provide the location to the local working copy like so:

```sh
rake init:submodules [ui=1] core=/path/to/.../LayerKit
```
`/path/to/.../LayerKit` must be a full canonical path, no relative or `~` paths.

### Setting the App ID

Before running Atlas Messenger from source code you must configure the Layer App ID and Identity Provider URL. To do so, follow these steps:

##### App ID

Run `rake configure:set_app_id["{YOUR_APP_ID}"]` to set the App ID in 'LayerConfiguration.json', or set it manually by editing 'LayerConfiguration.json' directly.

Replace `{YOUR_APP_ID}` with your appID, obtained from the [Atlas keys](https://developer.layer.com/projects/keys) page.

##### Identity Provider URL

Run `rake configure:set_identity_provider_url["{YOUR_IDENTITY_PROVIDER_URL}"]` to set the Identity Provider URL in 'LayerConfiguration.json', or set it manually by editing 'LayerConfiguration.json' directly.

Replace `{YOUR_IDENTITY_PROVIDER_URL}` with your Identity Provider URL, obtained from the [Instastart Identity Provider](https://github.com/layerhq/instastart-identity-provider) page.

##### Example
This is an example of what your `LayerConfiguration.json` file might look like. Notice that the root of the JSON file is an Array.
```json
[
  { 
    "name": "Example App",
    "app_id": "layer://example/example",
    "provider_url": "https://www.yourproviderurl.com/example"
  }
]
```

You can now proceed with building and running Atlas Messenger. Select **Run** from the **Product** menu (or type `⌘R`). After the build completes, Atlas Messenger will launch launch in your iOS Simulator.

## Getting Oriented

Atlas Messenger was designed to strike a balance between being simple enough to quickly peruse the project, but full-featured enough to fully demonstrate the power of Atlas and Layer. As you begin working with the example code, keep the following things in mind:

* [Layer](https://layer.com/) is a hosted communications platform. All communications services leveraged by Atlas Messenger utilize the backend services hosted by Layer.
* [LayerKit](https://github.com/layerhq/releases-ios) is the native iOS SDK for accessing the Layer communications platform. LayerKit handles the networking, persistence, security and synchronization necessary to implement robust native messaging. LayerKit also presents a programming model for accessing the Conversations and Messages that are transmitted through Layer.
* [Atlas](https://atlas.layer.com/) is a library of user interface components developed by Layer that provide fully integrated user interface experiences on top of LayerKit. Atlas has a direct dependency on LayerKit and is not usable standalone.

When working with the Atlas Messenger codebase you will encounter code coming from LayerKit (prefixed by `LYR`), Atlas (prefixed by `ATL`), and Atlas Messenger itself (prefixed by `ATLM`).

### Navigating the Project

The project is organized as detailed in the table below:

| Path                    			| Type                  | Contains                                                                   |
| -------------------------------|-----------------------|----------------------------------------------------------------------------|
| `Code`                  			| Directory             | Source code organized by type                                              |
| `Gemfile`               			| Ruby code             | Ruby Gem dependency declarations for Bundler                               |
| `Gemfile.lock`          			| ASCII text            | Exact Gem dependency manifest (generated by Bundler)                       |
| `LICENSE`               			| ASCII text            | Licensing details for the project                                          |
| `Libraries`             			| Directory             | Submodules and external project dependencies                               |
| `Podfile`               			| Ruby code             | CocoaPods library dependencies for the project                             |
| `Podfile.lock`          			| ASCII text            | Exact Pod dependency manifest (generated by CocoaPods)                     |
| `Pods`                  			| Directory             | CocoaPods generated artifacts. Ignored by Git.                             |
| `README.md`             			| Markdown text         | This comprehensive README file                                             |
| `Rakefile`              			| Ruby source           | Rake automation tasks                                                      |
| `Resources`             			| Directory             | Assets such images                                                         |
| `Atlas Messenger.xcodeproj` 		| Xcode Project         | The Xcode project for Atlas Messenger. Use the workspace instead.          |
| `Atlas Messenger.xcworkspace`  	| Xcode Workspace       | The Xcode workspace for Atlas Messenger. Used for day to day development.  |
| `Tests`                 			| Directory             | Test code for the application.                                             |
| `.ruby-version`         			| rbenv configuration   | Specifies the version of Ruby that rbenv will bind to                      |
| `xcodebuild.log`        			| Log file              | Log out xcodebuild output generated by test Rake tasks. Under .gitignore   |

Because Atlas Messenger is designed to showcase the capabilities of Atlas, most of the interesting code lives in `Code/Controllers` and `Code/Views`.


## License

Atlas Messenger is licensed under the terms of the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html). Please see the [LICENSE](LICENSE) file for full details.

## Contact

Atlas Messenger was developed in San Francisco by the Layer team. If you have any technical questions or concerns about this project feel free to reach out to [Layer Support](mailto:support@layer.com).

## Credits

* [Kevin Coleman](https://github.com/kcoleman731)
* [Klemen Verdnik](https://github.com/chipxsd)
* [Blake Watters](https://github.com/blakewatters)
