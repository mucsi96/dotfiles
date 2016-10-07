@echo off

doskey ga=git add $*
doskey gaa=git add --all $*
doskey gc=git commit -v $*
doskey gc!=git commit -v --amend $*
doskey gcn!=git commit -v --no-edit --amend $*
doskey gca=git commit -v -a $*
doskey gca!=git commit -v -a --amend $*
doskey gcan!=git commit -v -a --no-edit --amend $*
doskey gcans!=git commit -v -a -s --no-edit --amend $*
doskey gcam=git commit -a -m $*
doskey gcsm=git commit -s -m $*
doskey gcb=git checkout -b $*
doskey gcm=git checkout master $*
doskey gcd=git checkout dev $*
doskey gco=git checkout $*
doskey gd=git diff $*
doskey gf=git fetch $*
doskey ggl=git pull $*
doskey glola=git log --graph --pretty=oneline --abbrev-commit --all $*
doskey gm=git merge $*
doskey gmom=git merge origin/master $*
doskey ggp=git push $*