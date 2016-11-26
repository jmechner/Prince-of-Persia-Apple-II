###############################################################################
# Makefile created by Adam Green (https://github.com/adamgreen)
#
# Variables that can be set in environment to customize build process:
#   VERBOSE: When set to 1, all build commands will be displayed to console.
#            It defaults to 0 which suppresses the output of the build tool
#            command lines themselves.
#   RELEASE_PATCH: If defined, applies patches that modify the source code in
#                  the repository to match the code used for released version
#                  of the 3.5" version of the game.  See Other/*.PATCH for more
#                  information.
###############################################################################


# If VERBOSE make variable set to non-zero then output all tool commands.
VERBOSE?=0
ifeq "$(VERBOSE)" "0"
Q=@
else
Q=
endif


# Customize the build depending on which OS we are running.
ifeq "$(OS)" "Windows_NT"
TOOL_PATH=.\Build\win32
COPY=copy
REMOVE = del
SHELL=cmd.exe
REMOVE_DIR = rd /s /q
MKDIR = mkdir
MOVE=move
PATCH=.\Build\win32\applydiff --binary
IGNORE=>nul 2>nul & exit 0
QUIET=>nul 2>nul

# Macro which will convert / to \ on Windows.
define convert-slash
$(subst /,\,$1)
endef

else

COPY=cp
REMOVE = rm
REMOVE_DIR = rm -r -f
MKDIR = mkdir -p
MOVE=mv
PATCH=patch
IGNORE=> /dev/null 2>&1 ; exit 0
QUIET=> /dev/null 2>&1

# Can keep / as / on *nix.
define convert-slash
$1
endef

ifeq ($(OSTYPE),)
OSTYPE=$(shell uname)
endif

ifneq ($(findstring Darwin,$(OSTYPE)),)
TOOL_PATH=Build/osx32
else
TOOL_PATH=Build/lin32
endif

endif


# Tools to be used for building game binaries and disk image.
ASSEMBLER=$(call convert-slash,$(TOOL_PATH)/snap)
IMAGER=$(call convert-slash,$(TOOL_PATH)/crackle)


# Assembler source file paths.
DISK_ROUTINES=02\ POP\ Disk\ Routines/RW1835
GAME_SOURCES=01\ POP\ Source/Source

# Assembler source file paths using globbing operator in place of space.
GAME_SOURCES_GLOB=01?POP?Source/Source


# Game data file paths.
IMAGE_TABLES=./01\ POP\ Source/Images
LEVELS=./01\ POP\ Source/Levels
OTHER_FILES=./Other


# Output directory.
OUTPUT_DIR=obj


# Assembly Language source to be built.
# NOTE: Use lower case and special rules for SAV'ed files which produce lower
# case object filenames so that incremental builds work properly on Linux.
OBJECTS =$(OUTPUT_DIR)/popboot35
OBJECTS+=$(OUTPUT_DIR)/rw1835.pop
OBJECTS+=$(OUTPUT_DIR)/boot
OBJECTS+=$(OUTPUT_DIR)/RW18525
OBJECTS+=$(OUTPUT_DIR)/AUTO
OBJECTS+=$(OUTPUT_DIR)/CTRLSUBS
OBJECTS+=$(OUTPUT_DIR)/COLL
OBJECTS+=$(OUTPUT_DIR)/CTRL
OBJECTS+=$(OUTPUT_DIR)/FRAMEADV
OBJECTS+=$(OUTPUT_DIR)/FRAMEDEF
OBJECTS+=$(OUTPUT_DIR)/GAMEBG
OBJECTS+=$(OUTPUT_DIR)/GRAFIX
OBJECTS+=$(OUTPUT_DIR)/HIRES
OBJECTS+=$(OUTPUT_DIR)/HRTABLES
OBJECTS+=$(OUTPUT_DIR)/MASTER
OBJECTS+=$(OUTPUT_DIR)/MISC
OBJECTS+=$(OUTPUT_DIR)/MOVER
OBJECTS+=$(OUTPUT_DIR)/SEQTABLE
OBJECTS+=$(OUTPUT_DIR)/SOUND
OBJECTS+=$(OUTPUT_DIR)/SUBS
OBJECTS+=$(OUTPUT_DIR)/TABLES
OBJECTS+=$(OUTPUT_DIR)/UNPACK
OBJECTS+=$(OUTPUT_DIR)/CTRL
OBJECTS+=$(OUTPUT_DIR)/FRAMEADV
OBJECTS+=$(OUTPUT_DIR)/FRAMEDEF
OBJECTS+=$(OUTPUT_DIR)/GAMEBG
OBJECTS+=$(OUTPUT_DIR)/GRAFIX
OBJECTS+=$(OUTPUT_DIR)/HRTABLES
OBJECTS+=$(OUTPUT_DIR)/MISC
OBJECTS+=$(OUTPUT_DIR)/MOVER
OBJECTS+=$(OUTPUT_DIR)/SEQTABLE
OBJECTS+=$(OUTPUT_DIR)/SOUND

# Check to see if some of the files should be patched to match the released build of Prince of Persia.
ifdef RELEASE_PATCH
OBJECTS+=$(OUTPUT_DIR)/TOPCTRL.PATCH
OBJECTS+=$(OUTPUT_DIR)/SPECIALK.PATCH
OBJECTS+=$(OUTPUT_DIR)/VERSION.PATCH
else
OBJECTS+=$(OUTPUT_DIR)/TOPCTRL
OBJECTS+=$(OUTPUT_DIR)/SPECIALK
OBJECTS+=$(OUTPUT_DIR)/VERSION
endif


# Game data to be included in disk image.
GAME_DATA =$(IMAGE_TABLES)/IMG.BGTAB1.DUN
GAME_DATA+=$(IMAGE_TABLES)/IMG.BGTAB1.PAL
GAME_DATA+=$(IMAGE_TABLES)/IMG.BGTAB2.DUN
GAME_DATA+=$(IMAGE_TABLES)/IMG.BGTAB2.PAL
GAME_DATA+=$(IMAGE_TABLES)/IMG.CHTAB1
GAME_DATA+=$(IMAGE_TABLES)/IMG.CHTAB2
GAME_DATA+=$(IMAGE_TABLES)/IMG.CHTAB3
GAME_DATA+=$(IMAGE_TABLES)/IMG.CHTAB4.FAT
GAME_DATA+=$(IMAGE_TABLES)/IMG.CHTAB4.GD
GAME_DATA+=$(IMAGE_TABLES)/IMG.CHTAB4.SHAD
GAME_DATA+=$(IMAGE_TABLES)/IMG.CHTAB4.SKEL
GAME_DATA+=$(IMAGE_TABLES)/IMG.CHTAB4.VIZ
GAME_DATA+=$(IMAGE_TABLES)/IMG.CHTAB5
GAME_DATA+=$(IMAGE_TABLES)/IMG.CHTAB6.A
GAME_DATA+=$(IMAGE_TABLES)/IMG.CHTAB6.B
GAME_DATA+=$(IMAGE_TABLES)/IMG.CHTAB7
GAME_DATA+=$(LEVELS)/LEVEL0
GAME_DATA+=$(LEVELS)/LEVEL1
GAME_DATA+=$(LEVELS)/LEVEL2
GAME_DATA+=$(LEVELS)/LEVEL4
GAME_DATA+=$(LEVELS)/LEVEL5
GAME_DATA+=$(LEVELS)/LEVEL6
GAME_DATA+=$(LEVELS)/LEVEL7
GAME_DATA+=$(LEVELS)/LEVEL8
GAME_DATA+=$(LEVELS)/LEVEL9
GAME_DATA+=$(LEVELS)/LEVEL10
GAME_DATA+=$(LEVELS)/LEVEL11
GAME_DATA+=$(LEVELS)/LEVEL12
GAME_DATA+=$(LEVELS)/LEVEL13
GAME_DATA+=$(LEVELS)/LEVEL14
GAME_DATA+=$(wildcard $(OTHER_FILES)/*)


# Disk layout description for where contents should be laid out on disk.
DISK_35_LAYOUT=$(OTHER_FILES)/PrinceOfPersia_3.5.layout
DISK_525A_LAYOUT=$(OTHER_FILES)/PrinceOfPersia_5.25_SideA.layout
DISK_525B_LAYOUT=$(OTHER_FILES)/PrinceOfPersia_5.25_SideB.layout


# Final disk images to be created.
DISK_35_IMAGE=PrinceOfPersia_3.5.hdv
DISK_525A_IMAGE=PrinceOfPersia_5.25_SideA.nib
DISK_525B_IMAGE=PrinceOfPersia_5.25_SideB.nib


# Flags to pass into build tools.
ASM_FLAGS=--putdirs "$(call convert-slash,./01 POP Source/Source)" --outdir $(call convert-slash,$(OUTPUT_DIR))
IMAGER_35_FLAGS=--format hdv_3.5
IMAGER_525_FLAGS=--format nib_5.25


# Main build rules.
.PHONY : all clean

all: $(OUTPUT_DIR) $(OBJECTS) $(DISK_35_IMAGE) $(DISK_525A_IMAGE) $(DISK_525B_IMAGE)

$(OUTPUT_DIR) :
	$(Q) $(MKDIR) $(call convert-slash,$@) $(QUIET)

$(DISK_35_IMAGE) : $(OBJECTS) $(GAME_DATA) Makefile
	@echo Creating disk image $@
	$(Q) $(IMAGER) $(IMAGER_35_FLAGS) $(call convert-slash,$(DISK_35_LAYOUT)) $@

$(DISK_525A_IMAGE) : $(OBJECTS) $(GAME_DATA) Makefile
	@echo Creating disk image $@
	$(Q) $(IMAGER) $(IMAGER_525_FLAGS) $(call convert-slash,$(DISK_525A_LAYOUT)) $@

$(DISK_525B_IMAGE) : $(OBJECTS) $(GAME_DATA) Makefile
	@echo Creating disk image $@
	$(Q) $(IMAGER) $(IMAGER_525_FLAGS) $(call convert-slash,$(DISK_525B_LAYOUT)) $@

clean:
	@echo Cleaning project
	$(Q) $(REMOVE_DIR) $(call convert-slash,$(OUTPUT_DIR)) $(IGNORE)
	$(Q) $(REMOVE) $(DISK_35_IMAGE) $(IGNORE)
	$(Q) $(REMOVE) $(DISK_525A_IMAGE) $(IGNORE)
	$(Q) $(REMOVE) $(DISK_525B_IMAGE) $(IGNORE)


# Rules to assemble .S files
$(OUTPUT_DIR)/popboot35 : $(DISK_ROUTINES)/POPBOOT35.S Makefile
	@echo Assembling $<
	$(Q) $(ASSEMBLER) "$(call convert-slash,$<)" $(ASM_FLAGS) --list $(call convert-slash,$@.LST)

$(OUTPUT_DIR)/rw1835.pop : $(DISK_ROUTINES)/RW1835.POP.S Makefile
	@echo Assembling $<
	$(Q) $(ASSEMBLER) "$(call convert-slash,$<)" $(ASM_FLAGS) --list $(call convert-slash,$@.LST)

$(OUTPUT_DIR)/boot : $(GAME_SOURCES)/BOOT.S Makefile
	@echo Assembling $<
	$(Q) $(ASSEMBLER) "$(call convert-slash,$<)" $(ASM_FLAGS) --list $(call convert-slash,$@.LST)

$(OUTPUT_DIR)/% : $(GAME_SOURCES_GLOB)/%.S Makefile
	@echo Assembling $<
	$(Q) $(ASSEMBLER) "$(call convert-slash,$<)" $(ASM_FLAGS) --list $(call convert-slash,$@.LST)

$(OUTPUT_DIR)/% : $(OTHER_FILES)/%.S Makefile
	@echo Assembling $<
	$(Q) $(ASSEMBLER) "$(call convert-slash,$<)" $(ASM_FLAGS) --list $(call convert-slash,$@.LST)


# Default rules to patch and assemble .S files.
$(OUTPUT_DIR)/%.PATCH : $(GAME_SOURCES_GLOB)/%.S Makefile
	@echo Patching and Assembling $<
	$(Q) $(COPY) "$(call convert-slash,$<)" $(call convert-slash,$(patsubst %.PATCH,%.PATCH.S,$@)) $(QUIET)
	$(Q) $(PATCH) -p1 < $(call convert-slash,$(patsubst $(OUTPUT_DIR)/%,$(OTHER_FILES)/%,$@)) $(QUIET)
	$(Q) $(ASSEMBLER) $(call convert-slash,$(patsubst %.PATCH,%.PATCH.S,$@)) $(ASM_FLAGS) --list $(call convert-slash,$@.LST)
	$(Q) $(COPY) $(call convert-slash,$@) $(call convert-slash,$(patsubst %.PATCH,%,$@)) $(QUIET)
