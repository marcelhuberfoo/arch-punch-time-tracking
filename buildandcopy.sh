#!/bin/sh

thedirs="."
repodir=/home/own-repo
category=office

thingsToDo=(
  'for n in $thedirs; do ( cd $n && updpkgsums ;  makepkg --force --noprogressbar --nodeps --nobuild ); done'
  'git diff --quiet --no-ext-diff --exit-code && echo clean || ( git diff -b -w && git add -p && git commit ) || true'
  'for n in $thedirs; do ( cd $n && updpkgsums ;  makepkg --force --noprogressbar --nodeps ); done'
  'mkaurball -ef'
  'upfile=$(ls -tc1 *.src.tar.gz | head -1); test -n "$upfile" && ( echo uploading $upfile; burp --user=marcelhuber --category=$category $upfile)'
  'test -n "$repodir" -a -d "$repodir" && for n in $thedirs; do for pkgdir in $(find $n -name "*.tar.xz" -printf "%h\n" | sort | uniq); do cpfn=$(ls -tc1 $pkgdir/*.tar.xz | head -1); echo "copy [$cpfn]? (y*|n)"; read v; if [ ! "$v" = "n" -a ! "$v" = "N" ]; then sudo sh -c "cp --interactive --preserve --update $cpfn $repodir && ( repo-add --new --quiet ${repodir}/ownrepo.db.tar.gz $repodir/$(basename $cpfn); repo-add --files --new --quiet ${repodir}/ownrepo.files.tar.gz $repodir/$(basename $cpfn))"; fi; done; done'
)

set -e

for n in "${thingsToDo[@]}"; do
  echo "Continue with [$n] (y*|n)?"
  read v
  if [ "$v" = "n" -o "$v" = "N" ]; then
    echo "..command skipped..";
  else
    eval "$n";
  fi
done

