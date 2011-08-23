DEVICE=xc6slx75-3csg484

all: sim_aes_ccm

sim_aes_ccm: scripts/aes_ccm.do
	vsim -do scripts/aes_ccm.do

syn_aes_ccm: 
	  echo "run -ifn synthesis/aes_ccm.prj -ifmt VHDL -ofn aes_ccm -p \
	        $(DEVICE) -opt_mode Speed -opt_level 1" | xst	     
clean:
	rm -rf transcript work vsim.wlf *.rlf *.vstf *~ *.xrpt *.ngc _xmsgs  xst .lso

	
		