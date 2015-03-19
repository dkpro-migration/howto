# Migrating from Google Code to Github

Here we collect some experiences and best practices.

## Summary

* **Do not use the "export github" button on Google Code**
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

## Migrating step-by-step

### Migrating a Subversion repository

GitHub has a nice importer tool that allows you to import code and history from a remote Subversion repository. We use that to import our code from Google Code. In particular, we can:

* select a subtree of the SVN repository to be imported - for our projects, we usually changed the default layout (branches, tags, trunk, wiki) and created one or more folders parallel to "wiki" which then contain the standard SVN layout (branches, tags, trunk). We will want to import each of these folders into a separate git repository on GitHub (and ignore the wiki for now).
* map the Google Code committer IDs to proper name/value settings - The importer offers a nice UI to do the mapping. However, one needs to pay attention. Simply entering GitHub user IDs will not do what you may expect. IF you enter a user ID, the "name" will be set to the real name configured on that user ID and the "mail" will be set to `<userid>@users.noreply.github.com`. Commits will not be attributed to the profile of the users unless they enable the setting "Keep my email address private" in the email settings of their profile. Simply entering a mail address is also not the way to go, because it will cause both "name" and "mail" to be set to the mail address. Instead, you will want to enter a name/mail in the format `Jessy James <jessy@somedomain.com>`. This will cause the "name" to be set to the value before the pointy brackets and the "mail" to be set to the value between the pointy brackets. Of course you may actually want to keep you mail address private to avoid spam (typically *not* a problem really), then to be sure, you should use `Name you Choose <userid@users.noreply.github.com>`. Mind to make the same settings in the git client on your own computer!

### Migrating the issues

Google offers a set of scripts to migrate issues from Google Code to GitHub. This works reasonably well with the following restrictions:

* regarding issue metadata
  * all issues will appear to come from the person doing the migration
  * all issues will appear to have been made at the time of the migration
  * the issue text however will contain original reporter/commenter, time of the comment, and a link back to Google Code (working as long as it still exists)
* regarding the speed
  * conversion will be slow because the script tries to avoid triggering the abuse block
* regarding attachments
  * issue attachments are neither migrated nor is a mention added to the issue text
  * the JSON exported from Google Takeout mentions attachments, but does not actually contain them
  * GitHub does not suppport attachments anyway (other than images)

To use these script, you need:

* the scripts
* modify the "github_issue_converter.py" script to disable certificate checks
  * `self._http = http_instance if http_instance else httplib2.Http(disable_ssl_certificate_validation=True)`
* check out "Project Hosting" data from Google Takeout
* run the script

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
