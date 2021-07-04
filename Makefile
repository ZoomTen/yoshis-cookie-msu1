# tools
ASM ?= tools/bass_v17/bass/out/bass
BPS ?= tools/beat_v2/beat/out/beat

all: yoshis_cookie_msu1.bps

.PRECIOUS: %.sfc

%.bps: %.sfc baserom.sfc
	$(BPS) -create:bps $@ baserom.sfc $<

%.sfc: %.asm baserom.sfc
	cat baserom.sfc > $@
	$(ASM) -m $@ $<

clean:
	rm -f yoshis_cookie_msu1.{bps,sfc}
