
<CsoundSynthesizer>
<CsOptions>
-o "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/C/out/mix_out.wav"
</CsOptions>
<CsInstruments>

sr 	= 	44100
ksmps 	= 	32
nchnls 	= 	2	

0dbfs = 1

instr 1

itransp = p4
imul = ampdbfs(p5)
Sfilepath = p6

ichn filenchnls Sfilepath
ispeed = powoftwo(itransp / 12)

if ichn == 2 then
aL, aR diskin2 Sfilepath, ispeed, 0, 0, 0, 32
outs aL*imul ,aR*imul
else
aL diskin2 Sfilepath, ispeed, 0, 0, 0, 32
outs aL*imul, aL*imul
endif
  endin
</CsInstruments>

<CsScore>
i1    0.000  47.964807 -36 -32.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/C/9-car-horn-old.wav"
i1    4.416  75.626667 -36   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/C/10-sticks.wav"
i1    8.831  34.492517 -36   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/C/11-camera-noise.wav"

e
</CsScore>
</CsoundSynthesizer>
