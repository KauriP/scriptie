#!/usr/bin/env nu
let source_dir = pwd
let target_dir = pwd | path join "../typst-packages/packages/preview/scriptie" | path expand
let version = (open ($source_dir | path join typst.toml)).package.version
cd $target_dir
mkdir $version
cd $source_dir
let target_dir = $target_dir | path join $version
let relative_import = '#import "scriptie.typ"'
let universe_import = $'#import "@preview/scriptie:($version)"'
print $"Update ($target_dir)"
git --work-tree=($target_dir) checkout -f
rm $"($target_dir)/update-typst-packages.nu"
for f in (ls ($target_dir | path join demo*.typ | into glob)) {
  let file = $f.name
  print $"Update import in ($file)"
  cat $file | str replace $relative_import $universe_import | save $file -f
}
echo done
