platform :ios, '9.0'

target 'V2EX' do
    use_frameworks!

    # Yep.
    inhibit_all_warnings!

    # Pods for V2EX

    # Networking
    pod 'Alamofire'
    pod 'Kingfisher'

    # Rx
    pod 'RxSwift', '~> 4.0' #, git: 'https://github.com/ReactiveX/RxSwift.git', branch: 'rxswift4.0-swift4.0'
    pod 'RxCocoa', '~> 4.0'
    pod 'NSObject+Rx'
    pod 'RxOptional'

    # Parse
    pod 'Kanna', '~> 2.1.0'

    # UI
    pod 'SnapKit'
    pod 'UIView+Positioning'
    pod 'PKHUD'
    pod 'Toaster'
    pod 'StatefulViewController'
    pod 'YYText'
    pod 'SKPhotoBrowser'
    pod 'PullToRefreshKit', git: 'https://github.com/Joe0708/PullToRefreshKit.git'

    # Markdown
    pod 'Marklight'
    pod 'MarkdownView'

    # Misc
    pod 'IQKeyboardManagerSwift'
    pod 'Carte'
#    pod 'RxKeyboard'

    # Bug
    pod 'Fabric'
    pod 'Crashlytics'

    # Debug only
    pod 'Reveal-SDK', '~> 4', :configurations => ['Debug']

    target 'V2EXTests' do
        inherit! :search_paths
        # Pods for testing
    end

    target 'V2EXUITests' do
        inherit! :search_paths
        # Pods for testing
    end

end

post_install do |installer|

    pods_dir = File.dirname(installer.pods_project.path)
    at_exit { `ruby #{pods_dir}/Carte/Sources/Carte/carte.rb configure` }

    # 需要指定编译版本的第三方库名称
    swift3_targets = ['Kanna', 'Marklight']
    installer.pods_project.targets.each do |target|
        if swift3_targets.include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
    end
end
