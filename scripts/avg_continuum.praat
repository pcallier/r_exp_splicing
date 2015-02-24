# continuum from sample averaging
# make sure the pieces line up. TImewise, the longer sound
# will be used only up to the duration of the shorter sound

form Continuum settings
	natural Num_of_steps 9
endform

sound1 = selected("Sound",1)
sound2 = selected("Sound",2)

for i from 1 to 2
	select sound'i'
	Rename: "sound'i'"
	Down to Matrix
	matrix'i' = selected("Matrix")
	Rename: "matrix'i'"
	length'i'= Get number of columns
endfor

result_cols = min(length1, length2)
result_xmax = min(Matrix_matrix1.xmax, Matrix_matrix2.xmax)
result_dx = Matrix_matrix1.dx
echo 'result_cols', 'result_xmax'

for step_i from 1 to num_of_steps
	#Create Matrix: "m1clone", 0, result_xmax, result_cols, result_dx, 0,   1, 1, 1, 1, 1, "Matrix_matrix1 [row, col]"
	Create Matrix: "m1step'step_i'", 0, result_xmax, result_cols, result_dx, 0,   1, 1, 1, 1, 1, "Matrix_matrix1 [row, col] * ( ('num_of_steps'-('step_i'-1)-1)/('num_of_steps'-1))+Matrix_matrix2 [row, col]*((('step_i'-1)-1)/('num_of_steps'-1))"
	matrix_step'i'=  selected ( "Matrix")
	To Sound
	step'i' = selected("Sound")
	select matrix_step'i'
	Remove
endfor
