
<CsoundSynthesizer>
<CsOptions>
-o "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/out/mix_out.wav"
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
i1    0.000  15.470295 -12 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/8-children.wav"
i1    0.205   14.77127 -13 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/7-car-stop.wav"
i1    0.411  17.364819 -14 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/8-children.wav"
i1    0.616   16.58019 -15 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/7-car-stop.wav"
i1    0.821   19.49135 -16 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/8-children.wav"
i1    1.026  18.610634 -17 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/7-car-stop.wav"
i1    1.232  21.878301 -18 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/8-children.wav"
i1    1.437   20.88973 -19 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/7-car-stop.wav"
i1    1.642  24.557562 -20 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/8-children.wav"
i1    1.847  23.447929 -21 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/7-car-stop.wav"
i1    2.053  27.564932 -22 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/8-children.wav"
i1    2.258  26.319411 -23 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/7-car-stop.wav"
i1    2.463   3.867574  12 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/8-children.wav"
i1    2.668   29.54254 -25 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/7-car-stop.wav"
i1    2.874  34.729638 -26 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/8-children.wav"
i1    3.079   33.16038 -27 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/7-car-stop.wav"
i1    3.284    38.9827 -28 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/8-children.wav"
i1    3.489  37.221268 -29 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/7-car-stop.wav"
i1    3.695  43.756601 -30 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/8-children.wav"
i1    3.900   41.77946 -31 -10.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/B/7-car-stop.wav"

e
</CsScore>
</CsoundSynthesizer>
