GRAMINEDIR ?= ../..
GRAMINE_PKGLIBDIR ?= /usr/lib/x86_64-linux-gnu/gramine # this is debian/ubuntu specific

ARCH_LIBDIR ?= /lib/$(shell $(CC) -dumpmachine)

# for EPID attestation, specify your SPID and linkable/unlinkable attestation policy;
# for DCAP/ECDSA attestation, specify SPID as empty string (linkable value is ignored)
RA_CLIENT_SPID ?=
RA_CLIENT_LINKABLE ?= 0

ifeq ($(DEBUG),1)
GRAMINE_LOG_LEVEL = debug
CFLAGS += -O0 -ggdb3
else
GRAMINE_LOG_LEVEL = error
CFLAGS += -O2
endif

CFLAGS += -fPIE
LDFLAGS += -pie

.PHONY: app
#app: mbedtls/.mbedtls_configured server.manifest.sgx server.sig server.token client
app: server client


######################### CLIENT/SERVER EXECUTABLES ###########################

#CFLAGS += -I./mbedtls/include $(shell pkg-config --cflags mbedtls_gramine) -I./src/* -g
CFLAGS_S +=  -I./src/* -I./include -g -DMG_ENABLE_MBEDTLS=1

LDFLAGS += -ldl -lpthread -lcrypto -lssl  -lcurl


SOURCES_TP +=$(wildcard include/lib/*.cc)
SOURCES_TP +=$(wildcard include/lib2/*.cc)

#OBJECTS_TP += $(SOURCES_TP:.cpp=.o)
OBJECTS_TP += $(SOURCES_TP:.cc=.o)


#SOURCES_S += $(wildcard src/*.cpp)
SOURCES_S += $(wildcard src/*.cc)
#OBJECTS_S += $(SOURCES_S:.cpp=.o)
OBJECTS_S += $(SOURCES_S:.cc=.o)


%.o: %.c
	$(CC) -c  $< $(CFLAGS_C) -o $@

%.o: %.cc
	$(CXX) -c  $< $(CFLAGS_S) -o $@

%.o: %.cpp
	$(CXX) -c  $< $(CFLAGS_S) -o $@


#server: $(OBJECTS_S) mbedtls/.mbedtls_configured
server: $(OBJECTS_S) $(OBJECTS_TP)
	$(CXX) $(OBJECTS_S) $(OBJECTS_TP)  $(LDFLAGS) -o $@





