vlog tb_memory.v
vsim -novopt tb +testname=test_fd_wr_fd_rd
add wave sim:/tb/*
run -all