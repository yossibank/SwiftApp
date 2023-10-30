.PHONY: setup
setup:
	brew bundle
	mint bootstrap
	make run-format
	make generate-files
	make generate-api-test-mock
	make generate-xcodegen
	make open

.PHONY: open
open:
	open SwiftApp.xcworkspace

.PHONY: run-format
run-format:
	swift run --package-path BuildTools swiftformat .

.PHONY: generate-files
generate-files:
	mkdir -p Package/Tests/APITest/Mock

.PHONY: generate-api-test-mock
generate-test-mock:
	mint run mockolo mockolo --sourcedirs Package/Sources/API \
		--destination Package/Tests/APITest/Mock/MockResults.swift \
		--testable-imports API \
		--mock-final \
		--macro "DEBUG"

.PHONY: generate-xcodegen
generate-xcodegen:
	mint run xcodegen --spec project.yml --project SwiftApp

.PHONY: clean
clean:
	find . -type d \( -name \*.xcodeproj \) | xargs rm -rf
	rm -rf $${HOME}/Library/Developer/Xcode/DerivedData