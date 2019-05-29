
include config.mk

all: options exec.so test

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

config.mk:
	cp -n config.mk.sample config.mk

clean:
	@echo cleaning
	@rm -f vmenu vmenu.o

TEST = test-exec-immed.out test-exec-end.out

test-exec-end.out: test-exec-end.awk exec.so
	echo | gawk -l ./exec.so -f $< > $@
	echo "$$?" >> $@

test-exec-immed.out: test-exec-immed.awk exec.so
	echo | gawk -l ./exec.so -f $< > $@
	echo "$$?" >> $@

test: $(TEST)
	hg status $(TEST) | tee /dev/stderr | awk '/./{exit 1}'
	echo test success

.PHONY: all options clean test
