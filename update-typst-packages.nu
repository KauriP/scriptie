#!/usr/bin/env nu
let source_dir = pwd
let target_dir = pwd | path join "../typst-packages/packages/preview/scriptie" | path expand
let version = (open ($source_dir | path join typst.toml)).package.version
cd $target_dir
mkdir $version
cd $source_dir
let target_dir = $target_dir | path join $version
print $"Update ($target_dir)"
git --work-tree=($target_dir) checkout -f
rm $"($target_dir)/update-typst-packages.nu"
