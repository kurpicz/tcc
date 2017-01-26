DATA_DIR = data

CC=gcc
CXX=g++

FILE_NAMES = $(shell cat ./download.config | grep -v "^\#" | cut -f 1 -d';')
DL = $(foreach FILE_NAME, $(FILE_NAMES), $(DATA_DIR)/$(FILE_NAME))

BZIP_FILES = $(wildcard $(DATA_DIR)/*.bz2)
GZIP_FILES = $(wildcard $(DATA_DIR)/*.gz)

default: $(DL)
	@$(MAKE) -s decompress

decompress:
	@echo "Start decompressing"
	$(foreach FILE, $(BZIP_FILES), $(shell bzip2 -d $(FILE)))
	$(foreach FILE, $(GZIP_FILES), $(shell gunzip $(FILE)))

random: random/random_number.cpp
	$(CXX) -o random/random_number.o random/random_number.cpp

$(DATA_DIR)/%:
	@echo "Downloading $*"
	@$(eval tmp_url:=$(shell cat ./download.config |\
		grep -v "^\#" | grep "$*;" | cut -f 2 -d';'))
	@cd $(DATA_DIR); wget -q $(tmp_url)

clean:
	@rm -rf ./data; mkdir data
	@rm random/random_number.o