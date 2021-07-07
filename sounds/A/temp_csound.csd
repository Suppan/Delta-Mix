
<CsoundSynthesizer>
<CsOptions>
-o "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/out/mix_out.wav"
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
i1    0.000 3.720408163265306   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/1-water-splash.wav"
i1    3.033 7.73514739229025   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/8-children.wav"
i1    4.767 2.010544217687075 -12   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/4-ugly-horn.wav"
i1    5.200 2.524603174603175   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/3-machine-noise2.wav"
i1    6.067 4.446666666666666   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/5-crowd.wav"
i1    8.233 9.453333333333333   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/0-sticks.wav"
i1    9.100 3.674013605442177   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/2-machine-noise1.wav"
i1   11.267 6.971111111111111   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/7-car-stop.wav"
i1   11.700 3.72108843537415   0   0.0 "/Users/wsuppan/Dropbox/2021/Apps/Delta-Mix-0.21/sounds/A/6-kung-fu.wav"

e
</CsScore>
</CsoundSynthesizer>
