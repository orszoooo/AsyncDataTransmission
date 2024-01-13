#!/bin/bash

test -d ./Output

if [ $? -ne 0 ]; then
    mkdir Output
fi

#Compilation
rm -f ./Output/$1_sim.vcd

modules_dir="../Modules"
modules_list=""
modules_input=""


if [ "$#" -ne 0 ]; then
    if [ "$1" = "tx" ]; then 
        modules_input="tx"
    fi

    if [ "$1" = "rx" ]; then 
        modules_input="rx"
    fi

    if [ "$1" = "dtu" ]; then 
        modules_input="dtu tx rx clk_div clk_div_preset led_disp"
    fi
else
    echo Provide module name you want to simulate i.e. ./sim.sh tx 
    exit 1
fi

for i in $modules_input
do  
  modules_list+="$modules_dir/$i.v "
done

iverilog -Wall -s $1_tb -o ./Output/$1_sim "$modules_dir"/tb/$1_tb.v $modules_list 

if [ $? -eq 1 ]; then
    echo Source compilation failure
    exit 1
fi

#Simulation
vvp ./Output/$1_sim

if [ $? -ne 0 ]; then
    echo Running simulation failure
    exit 1
fi

rm -f ./Output/$1_sim

