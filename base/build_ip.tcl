# Copyright (C) 2022 Xilinx, Inc

# SPDX-License-Identifier: BSD-3-Clause

# Rebuild HLS IP from source
set current_dir [pwd]
set pynq_hls_ip "./../pynq/boards/ip/hls"

# get list of IP from folder names
set ip {pixel_pack_2 pixel_unpack_2}
set ip_version {"1.0" "1.0"}
# Check and build each IP
foreach item $ip version $ip_version {
   if {[catch { glob -directory ${pynq_hls_ip}/${item}/${item}_zu3_solution/impl/ip/ *.zip} zip_file]} {
# Build IP only if a packaged IP does not exist
      puts "Building $item IP"
      set runner [file join /tmp run_hls_${item}_[pid].tcl]
      set fd [open $runner w]
      puts $fd "set ip_name {$item}"
      puts $fd "set version {$version}"
      puts $fd "source [file normalize ./build_hls_ip.tcl]"
      close $fd
      puts "vitis-run --mode hls --tcl $runner"
      exec vitis-run --mode hls --tcl $runner
   } else {
# Skip IP when a packaged IP exists in ip directory
      puts "Skipping building $item"
   }
   unset zip_file
# Testing the built IP
   puts "Checking $item"
   set fd [open ${pynq_hls_ip}/${item}/${item}_zu3_solution/syn/report/${item}_csynth.rpt r]
   set timing_flag 0
   set latency_flag 0
   while { [gets $fd line] >= 0 } {
# Check whether the timing has been met
    if [string match {+ Timing: } $line]  { 
      set timing_flag 1
      set latency_flag 0
      continue
    }
    if {$timing_flag == 1} {
      if [regexp {[0-9]+} $line]  {
        set period [regexp -all -inline {[0-9]*\.[0-9]*} $line]
        lassign $period target estimated uncertainty
        if {$target < $estimated} {
            puts "ERROR: Estimated clock period $estimated > target $target."
            puts "ERROR: Revise $item to be compatible with Vitis HLS."
            exit 1
        }
      }
    }
# Check whether the II has been met
    if [string match {+ Latency: } $line]  { 
      set timing_flag 0
      set latency_flag 1
      continue
    }
    if {$latency_flag == 1} {
      if [regexp {[0-9]+} $line]  {
        set interval [regexp -all -inline {[0-9]*\.*[0-9]*} $line]
        lassign $interval lc_min lc_max la_min la_max achieved target
        if {$achieved != $target} {
            puts "ERROR: Achieved II $achieved != target $target."
            puts "ERROR: Revise $item to be compatible with Vitis HLS."
            exit 1
        }
      }
    }
# Testing ends
    if [string match {== Utilization Estimates} $line]  { 
       unset timing_flag latency_flag period interval
       break
    }
   }
   unset fd
}
cd $current_dir
puts "HLS IP builds complete"
