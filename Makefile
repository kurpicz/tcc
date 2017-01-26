DATA_DIR = data

FILE_NAMES = $(shell cat ./download.config | grep -v "^\#" | cut -f 1 -d';')
DL = $(foreach FILE_NAME, $(FILE_NAMES), $(DATA_DIR)/$(FILE_NAME))

all: $(DL)

$(DATA_DIR)/%:
	@echo "Downloading $*"
	@$(eval tmp_url:=$(shell cat ./download.config |\
		grep -v "^\#" | grep "$*;" | cut -f 2 -d';'))
	cd $(DATA_DIR); wget -q $(tmp_url)
	@$(if $(filter %.gz,$(tmp_url)), gunzip $(DATA_DIR)/$*.gz)
	
clean:
	rm -rf ./data; mkdir data