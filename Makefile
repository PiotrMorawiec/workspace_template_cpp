# GCC Compiler Flags and Options:
# https://caiorss.github.io/C-Cpp-Notes/compiler-flags-options.html
#
# Important GCC flags in Linux
# https://linuxhandbook.com/gcc-flags/

TARGET   ?= main.out

CXX       = g++
LINKER    = g++

MKDIR_P  ?= mkdir -p
SRCDIR    = .
OBJDIR    = obj
DEPDIR    = deps
BINDIR    = bin

SRCS      := $(shell find . -type f -name \*cpp)
OBJS      := $(SRCS:$(SRCDIR)/%.cpp=$(OBJDIR)/%.o)
DEPS      := $(SRCS:$(SRCDIR)/%.cpp=$(DEPDIR)/%.d)
TREE      := $(sort $(patsubst %/,%,$(dir $(OBJS))))

# Variable containing additional header files search paths
INCDIRS   := $(shell find $(SRCDIR) -type d)
INCFLAGS  := $(addprefix -I,$(INCDIRS))

# Variable containing shared libraries
# Add shared library using -l<lib>
# Add external shared library using -L<path_to_lib>
LDLIBS    += #-l<lib_name> -L<path_to_lib>

LDFLAGS   += -Wall $(LDLIBS) $(DIRS)
DEPFLAGS  += -MMD -MP -MF $(@:$(OBJDIR)/%.o=$(DEPDIR)/%.d)
CFLAGS    += -lstdc++ -Wall -std=c++17 $(INCFLAGS)

default: comp
all:     comp run

$(BINDIR)/$(TARGET): $(OBJS)
	@echo "\nLinking ..."
	@$(MKDIR_P) $(dir $@)
	@$(LINKER) $(LDFLAGS) $(OBJS) -o $@
	@echo "Linking complete\n"

$(OBJS): $(OBJDIR)/%.o : $(SRCDIR)/%.cpp
	@echo "Compiling $@"
	@$(MKDIR_P) $(dir $@)
	@$(MKDIR_P) $(DEPDIR)
	@$(CXX) $(CFLAGS) $(DEPFLAGS) -c $< -o $@

.PHONY: comp run help clean

%:
	@$(MKDIR_P) $(TREE)
	@$(MKDIR_P) $(TREE:$(OBJDIR)%=$(DEPDIR)%)
	@$(MKDIR_P) $(BINDIR)

comp: $(BINDIR)/$(TARGET)

run: $(BINDIR)/$(TARGET)
	@echo "Running $(BINDIR)/$(TARGET) ...\n"
	@./$(BINDIR)/$(TARGET)

help:
	@echo "*********************************************************"
	@echo "                    VARIABLES                            "
	@echo "*********************************************************"
	@echo "SRCS:      $(SRCS)"
	@echo "OBJS:      $(OBJS)"
	@echo "DEPS:      $(DEPS)"
	@echo "TREE:      $(TREE)"
	@echo "DEPFLAGS:  $(DEPFLAGS)"
	@echo "LDFLAGS:   $(LDFLAGS)"
	@echo "CFLAGS:    $(CFLAGS)"
	@echo "*********************************************************"
	@echo "                    TARGETS                              "
	@echo "*********************************************************"
	@echo "make comp             compiles object files and links"
	@echo "                      them into the binary \"$(TARGET)\""
	@echo "make run              runs the executable ($(TARGET))"
	@echo "make help             prints help message"
	@echo "make clean            cleans up build intermediate files"

clean:
	$(RM) -rf $(DEPDIR)
	$(RM) -rf $(OBJDIR)
	$(RM) -rf $(BINDIR)

-include $(DEPS)
