# choose_stimulus_chunks
#
# Choose which parts of which recording to splice in 

procedure scale_target_by_frame(frame_chunk, target_chunk)
	select frame_chunk
	sample_rate = Get sampling frequency
	frame_peak = Get maximum: 0, 0, "sinc70"
	select target_chunk
	Scale peak: frame_peak
endproc

procedure concat_sounds(snd0, snd1, norm_target)
	if norm_target <> 0
		@scale_target_by_frame(snd1, norm_target)
	endif
	select snd1
	Copy: "addendum"
	plus snd0
	snd_to_return = Concatenate
	selectObject: "Sound addendum"
	Remove
	select snd_to_return
endproc

form Choose options
	choice carrier_guise 2
		button rless
		button rful
	sentence chunks_path /home/pcallier/Dropbox/ongoing/r_exp/stimuli/khilton-original/pieces/
endform

clearinfo

if carrier_guise$ = "rless"
	target_guise$ = "rful"
else
	target_guise$ = "rless"
endif

carrier_folder$ = chunks_path$ + carrier_guise$ + "/"
target_folder$ = chunks_path$ + target_guise$ + "/"

carrier_files = Create Strings as file list: "carrier_list", carrier_folder$ +"*.wav"
target_files = Create Strings as file list: "target_list", target_folder$ + "*.wav"

select carrier_files
num_files = Get number of strings
result_snd = 0
for i from 1 to num_files
	base$ = string$(i)
	carrier_snd = Read from file: carrier_folder$ + base$ + ".wav"
	carrier_tg = Read from file: carrier_folder$ + base$ + ".TextGrid"
	target_snd = Read from file: target_folder$ + base$ + ".wav"
	
	select carrier_tg
	label_tier = 3
	t0 = Get start time
	t1 = Get end time
	tmid = t0 + (t1-t0) / 2
	label_int = Get interval at time: label_tier, tmid
	label$ = Get label of interval: label_tier, label_int

	snd_to_use = -1
	if label$ <> ""
		# if the sound has a label, it's a critical segment
		# ask the user what they want
		beginPause: "Choose whether to use carrier or target for" + label$
			comment: "The word is " + label$
			comment: "Stimulus chunk #" + base$
			comment: "Target is " + target_guise$
			choice: "Which guise", 1
				option: "carrier" 
				comment: "(" + carrier_guise$ + ")" 
				option: "target" 
				comment: "(" + target_guise$ + ")"
		endPause: "OK", 1

		appendInfoLine: "Guise chosen: " + string$(which_guise)
		if which_guise = 1
			snd_to_use = carrier_snd
		else
			snd_to_use = target_snd
		endif
		
		# pick result sound or concatenate sounds
		if result_snd = 0
			result_snd = snd_to_use
		else
			@concat_sounds(result_snd, snd_to_use, if which_guise = 1 then 0 else carrier_snd fi)
			concat_snd = selected("Sound")
			select result_snd
			Remove
			result_snd = concat_snd
			#pauseScript: "Check the sound"
		endif
	else
		# if the label is blank, then this is a non-critical segment of the carrier
		if result_snd = 0
			result_snd = carrier_snd
		else
			@concat_sounds(result_snd, carrier_snd, 0)
			concat_snd = selected("Sound")
			select result_snd
			Remove
			result_snd = concat_snd
		endif
	endif

	select carrier_tg
	plus carrier_snd
	plus target_snd
	nocheck minus result_snd
	appendInfoLine: "Carrier TG: " + string$(carrier_tg) + tab$ + "Carrier sound: " + string$(carrier_snd) + tab$ + "Target sound: " + string$(target_snd) + tab$ + "Result sound: " +  string$(result_snd)
	#Remove
endfor
