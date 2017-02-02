################################################################################
# Makefile
#
# Copyright (C) 2017 Florian Kurpicz <florian.kurpicz@tu-dortmund.de>
#
# All rights reserved. Published under the BSD-2 license in the LICENSE file.
################################################################################

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

RD_ENTRIES = $(shell cat $(MAIN_CONFIG) | grep -v "^\#" | grep "RD;" | cut -f 2 -d ";")
RD = $(foreach RD_ENTRY, $(RD_ENTRIES), $(DATA_DIR)/random/$(RD_ENTRY))

download: $(DL)
	$(BZIP_DECOMPRESS)
	$(GZIP_DECOMPRESS) 

random: $(RD)

$(DATA_DIR)/random/%:
	@$(eval FILE_NAME:=$(shell cat ./corpora.config |\
		grep -v "^\#" | grep "RD;$*;" | cut -f 2 -d ';'))
	@$(eval FILE_SIZE:=$(shell cat ./corpora.config |\
			grep -v "^\#" | grep "RD;$*;" | cut -f 3 -d ';'))
	@$(eval SYMBOL_WIDTH:=$(shell cat ./corpora.config |\
			grep -v "^\#" | grep "RD;$*;" | cut -f 4 -d ';'))
	@cd $(DATA_DIR)/random; dd bs=$(SYMBOL_WIDTH) if=/dev/urandom of=$(FILE_NAME) count=$(FILE_SIZE)

$(DATA_DIR)/%:
	@$(eval CONFIG_NAME:=$(shell echo $* | cut -f 1 -d '/'))
	@$(eval FILE_NAME:=$(shell echo $* | cut -f 2 -d '/'))
	@$(eval URL:=$(shell cat ./corpora/$(CONFIG_NAME).config |\
		grep -v "^\#" | grep "$(FILE_NAME);" | cut -f 3 -d ';'))
	@cd $(DATA_DIR); mkdir -p $(basename $(CONFIG_NAME)); cd $(basename $(CONFIG_NAME)); wget -q $(URL)

clean:
	@rm -rf ./data; mkdir data