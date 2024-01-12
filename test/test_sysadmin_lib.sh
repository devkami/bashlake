#!/bin/bash

# Import sysadmin_lib and the script to be tested
source ../utils/sysadmin_lib.sh

function preTest(){    
  required_distro=$(lsb_release -is)
  required_version=$(lsb_release -rs)
  test_folder="/tmp/testfolder"
  test_file="/tmp/testfolder/testfile.txt"
  cron_job="* * * * * /path/to/script.sh"
}

function testCheckSystemVersion(){  
  checkSystemVersion "$required_distro" "$required_version" > /dev/null 2>&1
  return $?
}

function testCheckExpectInstall(){  
  checkExpectInstall > /dev/null 2>&1
  return $?
}

function testCheckPvInstall(){  
  checkPvInstall > /dev/null 2>&1
  return $?
}

function testCheckCronJob(){  
  createCronJob "$cron_job" > /dev/null 2>&1
  checkCronJob "$cron_job" > /dev/null 2>&1
  return $?
}

function testCheckEnvironmentVars(){
  export TEST_VAR="value"
  checkEnvironmentVars "TEST_VAR" > /dev/null 2>&1
  return $?
}

function testGetDiskSpace(){  
  getDiskSpace > /dev/null 2>&1
  return 0
}

function testLogDiskSpaceFreed(){  
  local space_before=$(getDiskSpace)
  logDiskSpaceFreed "$space_before" > /dev/null 2>&1
  return 0
}

function testCheckJqInstall(){  
  checkJqInstall > /dev/null 2>&1
  return $?
}

function testListFolderTree(){
  mkdir -p "$test_folder"
  listFolderTree "$test_folder" > /dev/null 2>&1
  return $?
}

function testListFilesInFolder(){
  mkdir -p "$test_folder"
  touch "$test_file"
  listFilesInFolder "$test_folder" > /dev/null 2>&1
  return $?
}

function postTest(){
  rm -rf "$test_folder"
  unset required_distro required_version test_folder test_file cron_job
}

function run(){
  source test_lib.sh
  preTest
  runAllTests
  postTest
}

run
