#! /bin/bash

old_dir=`pwd`
PATCH_DIR=$old_dir/patches/sommelier
WORKING_BRANCH=crosvm-bootstrap

echo "Applying Patches"
cd $PWD/../cros_vm/src/platform2/vm_tools/sommelier

# we switch to $WORKING_BRANCH before anything
git checkout master

exists=`git show-ref refs/heads/$WORKING_BRANCH`
if [ -n "$exists" ]; then
  git branch -D $WORKING_BRANCH
fi

git checkout -b $WORKING_BRANCH master
git am $PATCH_DIR/00*
