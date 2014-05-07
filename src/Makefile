
include config.mk

all: options vmenu exec.so

options:
	@echo req build options:
	@echo "CFLAGS   = ${CFLAGS}"
	@echo "LDFLAGS  = ${LDFLAGS}"
	@echo "CC       = ${CC}"

exec.so: exec.c
	gcc -fPIC -shared -DHAVE_CONFIG_H -c -O -g ${AWKINC}  exec.c
	ld -o exec.so -shared exec.o

.c.o:
	@echo CC $<
	@${CC} -c ${CFLAGS} $<

vmenu: config.mk vmenu.o
	@echo LD -o $@
	@${CC} -o $@ vmenu.o ${LDFLAGS}

config.mk:
	cp -n config.mk.sample config.mk

clean:
	@echo cleaning
	@rm -f vmenu vmenu.o

.PHONY: all options clean
