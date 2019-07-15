#!/usr/bin/env bats

# BATS https://github.com/sstephenson/bats

load environment
thisDir=$BATS_TEST_DIRNAME
scriptsDir=$(realpath "$thisDir/../scripts")

projectDir=$thisDir/vanilla.project/barcode12

@test "Usage statement" {
  run bash $scriptsDir/np_polish_medaka.sh
  [ "$status" -eq 1 ] # usage exits with 1
  [ "$output" != "" ]
  [ ${output:0:6} == "Usage:" ] # First five characters of the usage statement is "Usage: "
}

@test "Files are present" {
  [ -f "$projectDir/unpolished.fasta" ]
}

@test "polishing with medaka" {

  if [ ! -f "$projectDir/polished.fasta" ]; then
    run bash $scriptsDir/np_polish_medaka.sh $projectDir
    [ "$status" -eq 0 ]
  fi

  export RANDOM=42
  hashsum=$(grep ">" $projectDir/polished.fasta | md5sum | cut -f 1 -d ' ')
  [[ "$hashsum" == "4a829477a7e2f21c9cc7a8077205c875" ]]
}
