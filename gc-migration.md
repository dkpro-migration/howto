# Migrating from Google Code to Github

Here we collect some experiences and best practices.

## Summary

* **Do not use the "export github" button on Google Code!**
* **Do not mark the projects "as moved" on Google Code!**
* Migrate code (selectively) using the GitHub importer tool (web-based)
* Migrate issues using the Google Issue Exporter tool (Python script)
* Migrate landing page (and wiki) to GitHub pages (and Jekyll)

## Do not use the "Export to Github" button

What the "Export to GitHub" button does:

* Creates a new repository under your personal GitHub account with the name of the Google Code project
* Migrate the complete contents of the SVN repository to that new git repo
* Migrate all the issues over - they will all appear under the name of the person running the migration and timestamp will be the time of migration
* Migrate the wiki contents over - they will be added as a branch called "wiki" in the target repository and be coverted to markdown format. However, only the latest state of the pages is preseved, the wiki history is lost.
* If you are very lucky, it completes - most likely it will send a failure mail

What the "Export to GitHub" button does **not**:

* Allow you to update contributor IDs - mind that Subversion only has a "committer ID" that may not even be a mail address, while in git, there is a "name" and a "email" field to fill in. Most likely, you will want to map the committer IDs to some sensible name/mail values.
* Allow you to select a subtree of a repository for conversion, e.g. if you have changed the standard repository layout on Google Code

## Do not mark the projects "as moved" on Google Code

If you mark the projects "as moved" on Google Code, you can no longer access any of its data (as far as I can tell). This is bad because not all data is automatically convered in the migration process and some data cannot even be migrated:

- the Google Code start page contents are lost including any sidebar links you might have configured
- issue attachments cannot be converted to GitHub because it does not support attachments!

Instead of marking the project "as moved", do the following:

- place a prominent message on the start page mentioning where the project has moved
- (optionally) change all committers into contributors to avoid futher commits to the repository by non-owners (and make sure he owners know that nothing should be committed anymore)

## Migrating step-by-step

### Migrating a Subversion repository

GitHub has a nice importer tool that allows you to import code and history from a remote Subversion repository. See instructions here: https://help.github.com/articles/importing-from-subversion/. We use that to import our code from Google Code. In particular, we can:

* select a subtree of the SVN repository to be imported - for our projects, we usually changed the default layout (branches, tags, trunk, wiki) and created one or more folders parallel to "wiki" which then contain the standard SVN layout (branches, tags, trunk). We will want to import each of these folders into a separate git repository on GitHub (and ignore the wiki for now). If only a fraction of the committers have worked on this particular subtree, please see the note below to save you some work.
* map the Google Code committer IDs to proper name/value settings - The importer offers a nice UI to do the mapping. However, this doesn't always work as expected:
 * If you enter something in the format `Jessy James <jessy@example.com>` (or `Jessy James <githubid@users.noreply.github.com>` if you know the committer wants to keep their email address private) then the importer will try to match the email address to an existing GitHub account.  If it finds one, it will display the user's profile picture and a green check mark.  It will then correctly set the "name" and "mail" fields for the commits, and will correctly attribute these commits to the GitHub profile.  This is probably the best way of mapping commiter IDs to name/value settings, though it requires you to know the email address the commiter uses for their GitHub account.  (But there is no easy way of discovering this out short of guessing and/or asking them directly.)
 * If instead you enter a GitHub user ID, the importer will recognize this by displaying the user's profile picture and a green check mark.  The "name" will be set to the real name configured on that user ID and the "mail" will be set to `githubid@users.noreply.github.com`.  However, commits may not be attributed to the profile of the users unless they enable the setting "Keep my email address private" in the email settings of their profile.  (But there is no easy way to tell whether or not a user has this setting enabled.)  This is probably the best way of mapping committer IDs to name/value settings if the previous approach doesn't work.
 * If the committer doesn't have a GitHub account, then just use the format `Jessy James <jessy@example.com>`.  The "name" and "mail" fields will be correctly set but of course they don't be associated with a GitHub account.  Do *not* enter the email address without the name, as this will cause both the "name" and "mail" fields to be set to the email address.
 * For some committers the importer won't show you any meaningful information; the name will show up as "Nobody" despite there being a valid name and/or email address in the SVN logs.  You'll have to guess who these "Nobody"s are; after importing, you can inspect the list of contributors, and if you guessed wrong, you can delete the repository and run the import tool again.  Alternatively, you could just ignore the "Nobody"s.
* After running the importer, to check if all assignments were correct, create a local clone of the repository and use the command `git shortlog -sen` to get a list of all contributors including name and email address.

**NOTE:** Even when only migrating a sub-tree, the GitHub importer will still read *all* commits in the SVN and detect all committers, even those that only contributed outside of the subtree. So after the migration is complete and *before* reassigning the user IDs, you should clone the new repository to your local disk and use the `git shortlog -sen` command to get a list of the committers relevant to the subtree only. Then you can save some work by just reassigning the IDs of these committers. After reassigning, delete the local clone and clone it again. Use the command again to see of all reassignments were done.

In case you need to fix committer IDs later, e.g. because you missed somebody but already started working on the migrated repository, the following information might help: https://help.github.com/articles/changing-author-info/

### Migrating the issues

Google offers a set of scripts to migrate issues from Google Code to GitHub, see https://code.google.com/p/support-tools/wiki/IssueExporterTool. 
This works reasonably well with the following restrictions:

* regarding issue metadata
  * all issues will appear to come from the person doing the migration
  * all issues will appear to have been made at the time of the migration
  * the issue text however will contain original reporter/commenter, time of the comment, and a link back to Google Code (working as long as it still exists)
* regarding the speed
  * conversion will be slow because the script tries to avoid triggering the abuse block
  * the abuse block may be triggered anyway, but the script allows you to continue with the last issue
* regarding attachments
  * issue attachments are neither migrated nor is a mention added to the issue text
  * the JSON exported from Google Takeout mentions attachments, but does not actually contain them
  * GitHub does not suppport attachments anyway (other than images)

To use these script, you need:

* the scripts, which you can get by cloning the Google code repository: git clone https://code.google.com/p/support-tools/
  * if you have cloned it before, make sure you **update** as there might be bug fixes! 
* [Contact GitHub](https://github.com/contact?form%5Bsubject%5D=Google+Code+Export:+API+Abuse+Rate+Limits) to request the anti-abuse rate limit for your account raised.  If you don't do this, you may run into the abuse detection mechanism after a couple of issues.
* modify the "github_issue_converter.py" script to disable certificate checks (**this is not necessary in later versions of the script**)
  * in `__init__`: 
  * replace `self._http = http_instance if http_instance else httplib2.Http()` 
  * by `self._http = http_instance if http_instance else httplib2.Http(disable_ssl_certificate_validation=True)`
* the scripts use Python 2 (i.e. do not work with Python 3) 
* check out "Project Hosting" data from Google Takeout (see also: ["Use Google Takeout to Get Issue Data"](https://code.google.com/p/support-tools/wiki/IssueExporterTool))
* to perform the export of Google Code project issues to GitHub: [create a personal access token on GitHub](https://github.com/settings/tokens)
* run the script, see ["Exporting to GitHub"](https://code.google.com/p/support-tools/wiki/IssueExporterTool)
  * For dkpro/similarity the command was is as follows: `python github_issue_converter.py --github_oauth_token="<removed auth token>" --github_owner_username=dkpro --github_repo_name=similarity --issue_file_path=GoogleCodeProjectHosting.json --project_name=dkpro-similarity-asl`
* if for some reason GitHub is going down during the migration of the issues or the process is killed (seems to happen regularly), the script detects already migrated issues, establishes a consistent state and continues with the migration. At least this is how it should work. There seems to be a bug in the script, because eventually, you might encounter the message "RuntimeError: Unable to find Google Code issue #XX 'IssueTiele'.
    Were issues added to GitHub since last export attempt?" Which means that the issue import is out of sync and can not be continued. This has been [reported](https://code.google.com/p/support-tools/issues/detail?id=90).

**Do not mark the projects "as moved" on Google Code!** - The moved issues contain links back to the original issues on Google Code which might still have the attachments! (As far as I can tell) If you mark the project "as moved", you can no longer access the issues.

### Migrating the project homepage and wiki

#### README page

GitHub doesn't have the concept of a project homepage in the way that Google Code has. By default, a project only has a repository with some README file in it. However, there is an alternative (see GitHub pages below).

#### Wiki

Additionally, there is a wiki functionality on GitHub, which is actually a separate repo and which (unlike the Google Code wiki) is editable by anyone (with a GitHub account). If you used your wiki to maintain documentation and used Google Analytics to learn about which parts are more interesting than others, you will notice that GA doesn't play well with the GitHub wiki - ok, GitHub meanwhile offers its own analytics which might be sufficient for you.

#### GitHub pages

GitHub pages are a great offering that allows you to very flexibly design your project website. However, where there is choice... well, there is the need to make a choice. On Google Code, there was no choice - only a single layout, no CSS or JavaScript, etc. Now you have to worry about this. Fortunately, GitHub offers a set of prebuilt templates and a wizard to fill in such a template with some text. In that way, it should be rather straight forward to convert the landing page from your Google Code project to a GitHub Pages web presence. 

But this simple conversion is maybe not what you want. GitHub pages are powered by a technology called Jekyll - essentially a templating engine. How does it work? Github monitors the "gh_pages" branch in your git repository and publishes the contents to "http://userid.github.io/reponame". If it detects configuration files and special folders for Jekyll, it "compiles" the contents of the repository from the Jekyll templates into static HTML pages which are then served under said URL. The extra "compile" step is what makes this setup so powerful, because here you can use Jekyll to create templates, includes, convert different formats (e.g. Markdown) to HTML, etc. etc. Actually, Jekyll is mean to be a blogging engine, so dynamically creating an overview of blog posts on your site is possible and all kinds of loops and conditions necessary to perform such a feat can be evaluated.

Mind that all GitHub repository content can be edited comfortably through your webbrowser (supporting preview for markdown formats etc).

So by using GitHub pages instead of the GitHub wiki, you can gain:

* the ability to restrict who is able to make modifications to members of your team
* the ability to visually style your presence
* the ability to inject analytics in all pages via Jekyll includes 
* a nice URL
* the ability to use your own domain name (CNAME) for your webpresence instead of lala.github.io

#### Cleaning up on Google Code

As previously mentioned, you may not want to use the Google Code setting which marks your project as moved, as that will cut off access to any attachments in the old issue tracker.  However, you should update your old Google Code page to forward visitors to your project's new home, and to prevent them from using the old source repository and issue tracker:

* Replace your project's description page with a prominent message notifying visitors that the project has moved to GitHub.  Provide a link.
* Once you migrate the source code repository, go to the "Administer" tab, select "Tabs" from the menu bar, and check the "Hide" box next to "Source".
* Once you migrate the issue tracker, go to the "Administer" tab, select "Tabs" from the menu bar, and check the "Hide" box next to "Issues".
* Consider removing all your wiki pages, or revising them to include prominent messages notifying visitors where they can obtain the current documentation.

## Fixing the Maven configuration

Projects built with Maven need to be updated after the migration to GitHub / git. This affects mainly the following things:

* the SCM settings
* the issue management settings
* the folder structure

### SCM settings

The SCM settings must be changed to reflect the new repository location and version control system, e.g. (FIXME needs testing during a release - maybe `<tag>HEAD</tag>`required)

```
<scm>
  <connection>scm:git:git://github.com/USER-OR-ORG-ID/REPO</connection>
  <developerConnection>scm:git:git@github.com:USER-OR-ORG-ID/REPO.git</developerConnection>
  <url>https://github.com/USER-OR-ORG-ID/REPO</url>
</scm>	
```

### Issue management

```
<issueManagement>
  <url>https://github.com/USER-OR-ORG-ID/REPO/issues</url>
  <system>GitHub Issues</system>
</issueManagement>
```

### Folder structure

The Maven release plugin does not work well with git unless the root POM is in the repository root. So if you had your project prepared to be a multi-module Maven project but never actually turned it into multi-module, then your Subversion folder structure might have looked something like this:

```
<svn repo root>
`- tags
`- branches
`- trunk
   `- myproject
      `- pom.xml
      `- ...
```

This will have been converted to GitHub as

```
<git repo root>
`- myproject
   `- pom.xml
    `- ...
```

For the release plugin to work properly, the easiest will be to remove the `myproject` folder and move its contents to the repo root. Fortunately, git is (supposed to be) good at tracking moved files. Alternatively, you could create a `pom.xml` file at the root of the repo and add `myproject` as a module.

## Changes in development environment and workflows
This section is intended to summarize important changes when moving from SVN to Git.

### Developing on Windows
It is crucial to globally set the line endings:
https://help.github.com/articles/dealing-with-line-endings/#global-settings-for-line-endings

### Using Maven in Eclipse

Maven has an SCM connector for Git called eGit.  To see if it's already installed on your system, go to File -> Import -> Check out Maven Projects from SCM.  If it is installed, you will see "git" as one of the options in the "SCM URL" drop-down box.  If it's not there, follow the "m2e Marketplace" link near the bottom of the dialog, browse through the list of connectors until you find the one for eGit, and install it.

Normally you can clone and import Maven projects from Git by using File -> Import -> Check out Maven Projects from SCM and then entering the remote repository URL.  However, this may not always work with multi-module projects.  In this case, use the following workflow:
* clone the git repo to the local disk, either using Eclipse or the command line
* Use "Import -> Existing Maven Project" in Eclipse then to import the project
* in particular DKPro Core has many dependencies and a few large ones which sometimes causes our Maven repository server to time out. To fix this repeatedly do one of the following until all the errors are gone:
 * use "Maven -> Update project ([x] force update snapshots)" in Eclipse, or
 * use "mvn -U clean install" on the command line

### Jenkins

If Jenkins is configured to automatically fetch and build your project from Google Code, you'll need to update the build configuration so that it fetches from GitHub instead.
