CONAN_INCLUDE_DIR_FLAG = -I
CONAN_LIB_DIR_FLAG = -L
CONAN_LIB_FLAG = -l
CONAN_DEFINE_FLAG = -D
CONAN_SYSTEM_LIB_FLAG = -l

include build/conandeps.mk

CXXFLAGS += -std=c++17
CPPFLAGS += $(CONAN_INCLUDE_DIRS) $(CONAN_DEFINES)
LDFLAGS  += $(CONAN_LIB_DIRS)
LDLIBS   += $(CONAN_LIBS) $(CONAN_SYSTEM_LIBS)

build/hello: src/main.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $< -o $@ $(LDFLAGS) $(LDLIBS)

.PHONY: clean
clean:
	rm -f build/hello
