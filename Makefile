DATA_DIR = data
MAIN_CONFIG = ./corpora.config

CC=gcc
CXX=g++

DL_CONFIG_FILES = $(shell cat $(MAIN_CONFIG) | grep -v "^\#" | grep "DL;" | cut -f 2 -d ";")
DL_FILE_NAMES = $(foreach DL_CONFIG_FILE, $(DL_CONFIG_FILES),\
	$(shell cat $(DL_CONFIG_FILE) | grep -v "^\#" | cut -f 1,2 -d ';' --output-delimiter='/'))
DL = $(foreach DL_FILE_NAME, $(DL_FILE_NAMES), $(DATA_DIR)/$(DL_FILE_NAME))

BZIP_DECOMPRESS = $(foreach FILE, $(wildcard $(DATA_DIR)/*/*.bz2), $(shell bzip2 -d $(FILE)))
GZIP_DECOMPRESS = $(foreach FILE, $(wildcard $(DATA_DIR)/*/*.gz), $(shell gunzip $(FILE)))

download: $(DL)
	$(BZIP_DECOMPRESS)
	$(GZIP_DECOMPRESS) 

random: random/random_number.cpp
	$(CXX) -o random/random_number.o random/random_number.cpp

$(DATA_DIR)/%:
	@$(eval CONFIG_NAME:=$(shell echo $* | cut -f 1 -d '/'))
	@$(eval FILE_NAME:=$(shell echo $* | cut -f 2 -d '/'))
	@$(eval URL:=$(shell cat ./corpora/$(CONFIG_NAME).config |\
		grep -v "^\#" | grep "$(FILE_NAME);" | cut -f 3 -d ';'))
	@cd $(DATA_DIR); mkdir -p $(basename $(CONFIG_NAME)); cd $(basename $(CONFIG_NAME)); wget -q $(URL)

clean:
	@rm -rf ./data; mkdir data