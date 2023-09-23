.PHONY: setup
setup:
	brew bundle
	mint bootstrap
	make xcodegen

.PHONY: open
open:
	open SwiftApp.xcworkspace

.PHONY: xcodegen
xcodegen:
	mint run xcodegen --spec project.yml --project SwiftApp

.PHONY: clean
clean:
	find . -type d \( -name \*.xcodeproj \) | xargs rm -rf
	rm -rf $${HOME}/Library/Developer/Xcode/DerivedData