# This script generates an input file containing the specified conditions for the exploration of critical points within the Multiwfn topology module.

#!/usr/bin/env bash

check_argument() {
  if [ $# -ne 4 ]; then
     echo "Usage: $0 <filename>.molden.input <output>.dat MO_index natoms" 
     exit 1
  fi	  
}

inquire_file() {
  local filename=$1

  if [ ! -f "$filename" ]; then
    echo "File not found: $filename"
    exit 1
  fi	  
}

search_cps() {
  arr=(2 -11 4 2 3 4 5 6 11 10000 2 0 -9 2 3 4 5 -4 4 0 -10)
  local output=$1
  local MO=$2
  local natoms=$3

  if [ -f "$output" ]; then
     echo "the file $output will be overwritten"
     rm -rf $output	  
  fi

  echo "${arr[0]}" >> "$output" # activate the topology module
  echo "${arr[1]}" >> "$output" # choose function
  echo "${arr[2]}" >> "$output" # orbital wavefuntion
  echo "$MO" >> "$output" # MO index

  # search options
  echo "${arr[3]}" >> "$output" # in nuclear positions
  echo "${arr[4]}" >> "$output" 
  echo "${arr[5]}" >> "$output" 
  echo "${arr[6]}" >> "$output" 

  # define a sphere
  echo "${arr[7]}" >> "$output" 
  echo "${arr[8]}" >> "$output" # radius of sphere
  echo "${arr[9]}" >> "$output" 

  # loop over all atoms

  n=$(( $natoms + 1 ))

  for(( i=1; i<$n; i++ ))
  do 
     echo "${arr[10]}" >> "$output"
     echo "$i" >> "$output"
     echo "${arr[11]}" >> "$output"
  done

  echo "${arr[12]}" >> "$output" # return
  echo "${arr[13]}" >> "$output" # nucleus
  echo "${arr[14]}" >> "$output" # middle
  echo "${arr[15]}" >> "$output" # triangle
  echo "${arr[16]}" >> "$output" # cage

  # save cps
  echo "${arr[17]}" >> "$output" # 
  echo "${arr[18]}" >> "$output" # 
  echo "${arr[19]}" >> "$output" # 
  echo "${arr[20]}" >> "$output" # 

  # quit
  echo "q" >> "$output" # 


}

call_multiwfn() {
  local moldenfile=$1
  local condition=$2

  if ! command -v Multiwfn &> /dev/null
  then	
   echo "Multiwfn aren't installed"
   exit 1
  fi	

  Multiwfn $moldenfile < $condition
  out=`basename $moldenfile .molden.input`
  mv CPs.txt $out"_CPs.dat"
  
  clear
  echo " "
  echo "-------------------------------------------------"
  echo "Critical points saved in $out"_CPs.dat" "
  echo "-------------------------------------------------"
  echo " "
  date
  echo " "

 num=`head -n1 $out"_CPs.dat"`
 n=$(( $num - 1 ))

 rm -rf $out"_CPs.xyz"

 echo "$n" >> $out"_CPs.xyz"
 echo "$moldenfile" >> $out"_CPs.xyz" 
 tail -n$n $out"_CPs.dat" | awk '{print "H  " $2 "  " $3 "  " $4 }' >> $out"_CPs.xyz"
}


main() {
  local filename=$1
  local output=$2
  local MO=$3
  local natoms=$4
  check_argument "$@"
  inquire_file "$filename"

  search_cps $output $MO $natoms
  call_multiwfn $filename $output

}

main "$@"
