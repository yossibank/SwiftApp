.PHONY: setup
setup:
	$(MAKE) brew-bundle
	$(MAKE) install-mint-packages
	$(MAKE) run-format
	$(MAKE) generate-files
	$(MAKE) generate-resources
	$(MAKE) generate-mock
	$(MAKE) generate-xcodegen
	$(MAKE) open

.PHONY: open
open:
	open SwiftApp.xcworkspace

.PHONY: brew-bundle
brew-bundle:
	brew bundle

.PHONY: install-bundler
install-bundler:
	bundle install

.PHONY: install-mint-packages
install-mint-packages:
	mint bootstrap --overwrite y

.PHONY: run-format
run-format:
	swift run --package-path BuildTools swiftformat .

.PHONY: generate-files
generate-files:
	mkdir -p Package/Sources/AppResources/Generated
	mkdir -p Package/Sources/Mock/Generated

.PHONY: generate-resources
generate-resources:
	mint run swiftgen config run --config swiftgen.yml

.PHONY: generate-mock
generate-mock:
	make generate-api-test-mock
	make generate-pokemonData-test-mock
	make generate-pokemonDomain-test-mock

.PHONY: generate-api-test-mock
generate-api-test-mock:
	mint run mockolo mockolo --sourcedirs Package/Sources/API \
		--destination Package/Sources/Mock/Generated/APIMockResults.swift \
		--testable-imports API \
		--mock-final \
		--macro "DEBUG"

.PHONY: generate-pokemonData-test-mock
generate-pokemonData-test-mock:
	mint run mockolo mockolo --sourcedirs Package/Sources/PokemonData \
		--destination Package/Sources/Mock/Generated/PokemonDataMockResults.swift \
		--testable-imports PokemonData \
		--mock-final \
		--macro "DEBUG"

.PHONY: generate-pokemonDomain-test-mock
generate-pokemonDomain-test-mock:
	mint run mockolo mockolo --sourcedirs Package/Sources/PokemonDomain \
		--destination Package/Sources/Mock/Generated/PokemonDomainMockResults.swift \
		--testable-imports PokemonDomain \
		--mock-final \
		--macro "DEBUG"

.PHONY: generate-xcodegen
generate-xcodegen:
	mint run xcodegen --spec project.yml --project SwiftApp

.PHONY: clean
clean:
	find . -type d \( -name \*.xcodeproj \) | xargs rm -rf
	rm -rf $${HOME}/Library/Developer/Xcode/DerivedData