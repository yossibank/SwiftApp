.PHONY: setup
setup:
	brew bundle
	mint bootstrap
	make run-format
	make generate-files
	make generate-mock
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
	mkdir -p Package/Sources/Mock/Generated

.PHONY: generate-mock
generate-mock:
	make generate-api-test-mock
	make generate-model-test-mock
	make generate-pokemonData-test-mock

.PHONY: generate-api-test-mock
generate-api-test-mock:
	mint run mockolo mockolo --sourcedirs Package/Sources/API \
		--destination Package/Sources/Mock/Generated/APIMockResults.swift \
		--testable-imports API \
		--mock-final \
		--macro "DEBUG"

.PHONY: generate-model-test-mock
generate-model-test-mock:
	mint run mockolo mockolo --sourcedirs Package/Sources/Model \
		--destination Package/Sources/Mock/Generated/ModelMockResults.swift \
		--testable-imports Model \
		--mock-final \
		--macro "DEBUG"

.PHONY: generate-pokemonData-test-mock
generate-pokemonData-test-mock:
	mint run mockolo mockolo --sourcedirs Package/Sources/PokemonData \
		--destination Package/Sources/Mock/Generated/PokemonDataMockResults.swift \
		--testable-imports PokemonData \
		--mock-final \
		--macro "DEBUG"

.PHONY: generate-xcodegen
generate-xcodegen:
	mint run xcodegen --spec project.yml --project SwiftApp

.PHONY: clean
clean:
	find . -type d \( -name \*.xcodeproj \) | xargs rm -rf
	rm -rf $${HOME}/Library/Developer/Xcode/DerivedData