#!/bin/bash
#
# regional simulation example with S40RTS and Crust1.0
#
# script runs mesher and solver using mpirun on 4 CPU-cores
# and creates surface movie files in AVS .inp format (loadable by Paraview)
#
# modify accordingly for your own system specifics
##################################################

echo "running example: `date`"
currentdir=`pwd`

echo "directory: $currentdir"
echo "(will take about 2 minutes)"
echo

# sets up directory structure in current example directoy
echo
echo "   setting up example..."
echo

mkdir -p DATABASES_MPI
mkdir -p OUTPUT_FILES

rm -rf DATABASES_MPI/*
rm -rf OUTPUT_FILES/*

# checks if executables were compiled and available
if [ ! -e ../../bin/xspecfem3D ]; then
  echo "Compiling first all binaries in the root directory..."
  echo

  # compiles executables in root directory
  # using default configuration
  cd ../../

  # only in case static compilation would have been set to yes in Makefile:
  cp $currentdir/DATA/Par_file DATA/Par_file

  # compiles code
  make clean
  make -j4 all

  # checks exit code
  if [[ $? -ne 0 ]]; then exit 1; fi

  # backup of constants setup
  cp setup/* $currentdir/OUTPUT_FILES/
  if [ -e OUTPUT_FILES/values_from_mesher ]; then
    cp OUTPUT_FILES/values_from_mesher.h $currentdir/OUTPUT_FILES/values_from_mesher.h.compilation
  fi
  cp DATA/Par_file $currentdir/OUTPUT_FILES/

  cd $currentdir
fi

# copy executables
mkdir -p bin
rm -rf bin/*
cp ../../bin/xmeshfem3D ./bin/
cp ../../bin/xspecfem3D ./bin/
cp ../../bin/xcombine_vol_data ./bin/
cp ../../bin/xcombine_vol_data_vtk ./bin/
cp ../../bin/xcreate_movie_AVS_DX  ./bin/xcreate_movie_AVS_DX

# links data directories needed to run example in this current directory with s362ani
cd DATA/
ln -s ../../../DATA/crust1.0
ln -s ../../../DATA/s20rts
ln -s ../../../DATA/s40rts
ln -s ../../../DATA/topo_bathy
cd ../

# run mesher & solver
echo
echo "  running script..."
echo
./run_mesher_solver.bash

# checks exit code
if [[ $? -ne 0 ]]; then exit 1; fi

# run movie generation
echo
echo "  creating movie files..."
echo
./bin/xcreate_movie_AVS_DX <<EOF
2
1
-1
1
EOF
if [[ $? -ne 0 ]]; then exit 1; fi

echo
echo `date`

