GODOT=/Applications/Godot.app/Contents/MacOS/Godot
BUTTLER=/Applications/butler-darwin-amd64/butler
EXPORT=--export
#EXPORT=--export-debug
BUILD_ROOT=../JamCraft5Export
ITCHIO_USERNAME=keksdev
ITCHIO_GAME=jamcraft5

all: html

html:
	mkdir -p $(BUILD_ROOT)/web
	$(GODOT) $(EXPORT) "HTML5" $(BUILD_ROOT)/web/index.html

publish: html
	$(BUTTLER) push $(BUILD_ROOT)/web $(ITCHIO_USERNAME)/$(ITCHIO_GAME):web
