# Merge one entire git repository into another with full history/tags/branches

**We assume that the tags in the primary repo and secondary repo already have different names!**

**It doesn't hurt training this on a fork of the primary repository and test if the results meet your expectations!**

* check out primary repo
* add secondary repo as additional remote
* pull
  * [X] fetch from all remotes  
  * [X] prune tracking branches no longer present on remote(s)
  * [X] fetch and store all tags locally
* create a new empty branch to host the secondary repo
  * `git checkout --orphan NEWBRANCH`
  * `git rm -rf .`
* merge oldes branch from secondary repo into the new empty branch
  * `git merge gpl-rec/1.2.x`
* repeat the previous two steps with other branches from secondary repo from the oldest to the newest and do not forget the master

At this point you should have local branches for all branches of the secondary remote repo and all tags from the secondary repo should be available locally as well - do not forget the "master" branch of the seconardy repo!

* remove secondary repo as additional remote
* push to origin - select to push all of the local branches you have created from the secondary repository and all tags

At this point you have the full histories of the primary and the secondary repo in the primary repo in parallel families of branch

Now, we want to merge the master branch we got from the secondary repo into the master branch of the primary repo.

We assume that the branches have by-and-large no overlapping files, e.g. because they are both multi-module maven projects that have submodules by different names. If there are files or folders with the exactly same names in both master branches, you should check out the master branch of the secondary repo and rename the files/folders before attempting the merge. A typical candidate to be renamed is the aggregate pom.xml file in the secondary master.

To move/rename files out of the way use `git mv` so you preserve history.

* Now switch to the primary repo master branch
* Merge the secondary repo master branch - this should work now without conflicts

When merging the multi module Maven projecs DKPro Core ASL and GPL, I moved the aggregate POMs of the two projects into subdirectories, i.e. the DKPro Core ASL pom.xml file into a subdirectory "de.tudarmstadt.ukp.dkpro.core-asl" and the DKPro Core GPL pom.xml file into "de.tudarmstadt.ukp.dkpro.core-gpl" - the same for the LICENSE.txt, scripts folder, and other non-module files and directories. Then I added a new aggregate pom.xml in the repository root folder that only has the "de.tudarmstadt.ukp.dkpro.core-asl" and "de.tudarmstadt.ukp.dkpro.core-gpl" as subfolders. I also had to update the module locations in the "de.tudarmstadt.ukp.dkpro.core-asl" and "de.tudarmstadt.ukp.dkpro.core-gpl" as subfolders to add a "../" to each module declaration.

If you did this all on a fork now, it is not necessary to repeat everything again on the real repo. Just add the real repo as an additional remote now (remove the fork) and push the changes to the real repo. Again, make sure to select all branches when pushing!
