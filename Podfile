use_frameworks!
platform :ios, '9.0'

target ‘Experiment’ do
    pod 'RxSwift',    '~> 4.0'
    pod 'RxCocoa',    '~> 4.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'RxSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                end
            end
        end
    end
end
