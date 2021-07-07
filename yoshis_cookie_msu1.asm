// assembler: bass v17

architecture wdc65816

macro seek(variable offset) {
  origin ((offset & $7F0000) >> 1) | (offset & $7FFF)
  base offset
}

constant new_sound_id          = $e6
constant sound_routine_counter = $1d6

// MSU-1 consts
constant MSU1_STATUS = $2000
constant MSU1_ID     = $2002
constant MSU1_TRACK  = $2004
constant MSU1_VOLUME = $2006
constant MSU1_PLAY   = $2007

seek($d8000)
function play_music_REDIRECT {
	jsl play_music
	rtl
}

seek($dfc80)
function play_music {
// This new routine will take account of the MSU-1 stuff
	php
	phy
	rep   #$20
	ldy   sound_routine_counter
	bne   play_music.done

	pha
	sep   #$20
	cmp   #$41
	bcs   play_music.skip
	xba
	cmp   new_sound_id
	beq   play_music.skip

	function msu1 { // MSU-1 patch
		php
		rep #$10
		ldx MSU1_ID
		cpx #$2d53 // S-
		bne msu1.no_msu
		ldx MSU1_ID + 2
		cpx #$534d // MS
		bne msu1.no_msu
		ldx MSU1_ID + 4
		cpx #$3155 // U1
		bne msu1.no_msu
	// play MSU1 track
		rep #$20
		and #$00ff
		tax
		sep #$20
		lda #$FF
		sta MSU1_VOLUME
	// insert track ID to X here...
		stx MSU1_TRACK
	// wait until not busy
	wait:
		bit MSU1_STATUS
		bvs msu1.wait
		lda.b #3
		sta MSU1_PLAY
		plp

		rep #$10
		rep #$20
		pla
		ply
		plp
		rtl

	no_msu:
		plp
	}

// load music in
	ora   #$80
	sta   new_sound_id
	rep   #$20
	pla
	and   #$00ff
	ora   #$8000
	sta   new_sound_id + 1
	bra   play_music.done

skip:
	rep   #$20
	pla
	and   #$00ff
	sta   new_sound_id + 1
	jsr   $81fb

done:
	ply
	plp
	rtl
}
