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
    pod 'RxSwift', git: 'https://github.com/ReactiveX/RxSwift.git', branch: 'rxswift4.0-swift4.0'
    pod 'RxCocoa', git: 'https://github.com/ReactiveX/RxSwift.git', branch: 'rxswift4.0-swift4.0'
    #  pod 'NSObject+Rx', git: 'https://github.com/RxSwiftCommunity/NSObject-Rx.git'
    pod 'RxOptional'

    pod 'Kanna', '~> 2.1.0'

    # UI
    pod 'SnapKit'
    pod 'UIView+Positioning'

    # Misc
    pod 'R.swift'

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
    # 需要指定编译版本的第三方库名称
    myTargets = ['Kanna']
    installer.pods_project.targets.each do |target|
        if myTargets.include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
    end
end
