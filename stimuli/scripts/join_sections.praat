procedure save_chunk_and_tg(chunk, tg, dir$, prefix$)
	select chunk
	Save as WAV file: dir$ + "/" + prefix$ + ".wav"
	t0 = Get start time
	t1 = Get end time
	select tg
	Extract part: t0, t1, "no"
	Save as text file: dir$ + "/" + prefix$ + ".TextGrid"
	Remove
	select chunk
endproc

procedure scale_target_by_frame(frame_chunk, target_chunk)
	select frame_chunk
	sample_rate = Get sampling frequency
	#mean_intensity = Get intensity (dB)
	frame_peak = Get maximum: 0, 0, "sinc70"
	select target_chunk
	Scale peak: frame_peak
endproc

rless_folder$ = "/home/pcallier/Dropbox/ongoing/r_exp/stimuli/khilton-original/pieces/rless/"
rful_folder$ = "/home/pcallier/Dropbox/ongoing/r_exp/stimuli/khilton-original/pieces/rful/"

frame_tg = selected("TextGrid")
frame_name$ = selected$("TextGrid")
if index (frame_name$, "rful") <> 0
	frame_dir$ = rful_folder$
	target_dir$ = rless_folder$
else
	frame_dir$ = rless_folder$
	target_dir$ = rful_folder$
endif

Extract all intervals: 3, "yes"

numberSelectedFrame = numberOfSelected("Sound")
for i to numberSelectedFrame
	frame[i] = selected("Sound", i)
endfor

pause Select the target sound and TextGrid
target_tg = selected("TextGrid")
Extract all intervals: 3, "yes"

numberSelectedTarget = numberOfSelected("Sound")
for j to numberSelectedTarget
	target[j] = selected("Sound", j)
endfor

chain = frame[1]
@save_chunk_and_tg(frame[1], frame_tg, frame_dir$, "1")
@save_chunk_and_tg(target[1], target_tg, target_dir$, "1")
for k from 2 to numberSelectedFrame
	# save files to separate folders for later use
	@save_chunk_and_tg(frame[k], frame_tg, frame_dir$, string$(k))
	@save_chunk_and_tg(target[k], target_tg, target_dir$, string$(k))

	# add from target if not a carrier segment, from carrier otherwise
	nameFrame$ = selected$ ("Sound")
	if nameFrame$ <> "untitled"
		@scale_target_by_frame(frame[k], target[k])
		Copy: "addendum"
	else
		select frame[k]
		Copy: "addendum"
	endif
	select chain
	plusObject: "Sound addendum"
	Concatenate
	new_chain = selected ("Sound")
	select chain
	plus frame[k]
	plus target[k]
	plusObject: "Sound addendum"
	Remove
	chain = new_chain
endfor

select target[1]
Remove


procedure match_sounds (sound0, scale0, sound1, scale1)
	# scales sound0 or sound1 based on the ratio
	# between scale0 and scale1, which could be, for instance, the 
	# RMS of the samples at the point at which they are to be joined, or
	# the peak intensity of the sound
	# going to skip this for the moment...
endproc

procedure get_intensity_multiplier (sound0, sound1)
	# produce an IntensityTier in the time domain of sound1
	# that when multiplied with sound1 will give it an intensity
	# envelope that looks like sound0's (scaled for time differences)
	select sound0
	intensity0 = To Intensity: 100, 0, "no"
	intensityTier0 = Down to IntensityTier
	t0_start = Get start time
	t0_end = Get end time

	select sound1
	intensity1 = To Intensity: 100, 0, "no"
	intensityTier1 = Down to IntensityTier
	t1_start = Get start time
	t1_end = Get end time

	select intensityTier0
	Scale times to: t1_start, t1_end
	
	numTimeSteps = 10
	timeStep = (t1_end - t1_start) / numTimeSteps
	intensityTierOut = Copy: "intensityTierOut"
	Remove points between: t1_start, t1_end
	select intensity1
	intensity_out_denom = Get mean: 0, 0, "energy"
	for i to numTimeSteps
		t_out [i] = t1_start + (i - 1) * timeStep
		select intensityTier0
		intensity_out_num [i] = Get value at time: t_out [i]
		intensity_out [i] = intensity_out_num [i] / intensity_out_denom
		select intensityTierOut
		Add point: t_out [i], intensity_out [i]
	endfor
	select intensity0
	plus intensityTier0
	plus intensity1
	plus intensityTier1
	Remove
	select intensityTierOut
endproc

procedure scale_sound_with_intensity(sound0, sound1)
	@get_intensity_multiplier(sound0, sound1)
	intensityTierOut = selected ("IntensityTier")
	#select sound1
	#intensity1 = To Intenstity: 100, 0, "no"
	plus sound1
	Multiply: "no"
endproc



#a[1] = selected("Sound", 1)
#a[2] = selected("Sound", 2)
#@scale_sound_with_intensity(a[1], a[2])


