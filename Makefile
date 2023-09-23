.PHONY: setup
setup:
	brew bundle
	mint bootstrap
	make xcodegen
	make open

.PHONY: open
open:
	open SwiftApp.xcworkspace

.PHONY: xcodegen
xcodegen:
	mint run xcodegen --spec project.yml --project SwiftApp

.PHONY: format
format:
	swift run --package-path BuildTools swiftformat .

.PHONY: clean
clean:
	find . -type d \( -name \*.xcodeproj \) | xargs rm -rf
	rm -rf $${HOME}/Library/Developer/Xcode/DerivedData