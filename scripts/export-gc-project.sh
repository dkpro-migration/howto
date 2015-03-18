#!/bin/sh
#
# export-gc-project.sh <projectname>
#
# This script helps exporting a Subversion-based project from
# Google Code and doing a test re-import and check-out on the
# local file system.
#
# The exported SVN dump is stored as <projectname>.svndump.xz
#
# The following tools need to be installed to run:
#
# - svn tools - for dumping, testing
# - xz tools - for compression
#
# Note: local test svn repo and test checkout are not deleted
#       automatically.
#
set -e

PROJECT="$1"
DUMPFILE="com.googlecode.$PROJECT.svndump.xz"
TESTREPO="$PROJECT.temprepo"
TESTCHECKOUT="$PROJECT.checkout"

echo "Exporting $PROJECT"
svnrdump dump "https://$PROJECT.googlecode.com/svn/" | xz > "$DUMPFILE"
echo "Testing reimport of $PROJECT"
svnadmin create "$TESTREPO" > "$PROJECT.create.log"
xzcat "$DUMPFILE" | svnadmin load "$TESTREPO" > "$PROJECT.load.log"
svn co "file://$(pwd)/$TESTREPO" "$TESTCHECKOUT" > "$PROJECT.checkout.log"
echo "Test complete"
