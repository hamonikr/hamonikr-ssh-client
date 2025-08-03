#!/bin/bash

# Extract translatable strings from Ásbrú Connection Manager
# This script creates a POT template file from the source code

PACKAGE="asbru-cm"
VERSION="6.4.0"
DOMAIN="asbru-cm"
POT_FILE="$DOMAIN.pot"

# Create temporary file list
TEMP_FILES=$(mktemp)

# Find all Perl source files
find ../lib -name "*.pm" > $TEMP_FILES
find .. -name "asbru-cm" >> $TEMP_FILES

echo "Extracting strings from source files..."

# Extract strings from Perl files using xgettext
xgettext --from-code=UTF-8 \
         --language=Perl \
         --keyword=__t \
         --keyword=__i18n \
         --keyword=__ni18n:1,2 \
         --package-name="$PACKAGE" \
         --package-version="$VERSION" \
         --msgid-bugs-address="https://github.com/asbru-cm/asbru-cm/issues" \
         --copyright-holder="Ásbrú Connection Manager team" \
         --output="$POT_FILE" \
         --files-from=$TEMP_FILES

# Extract strings from Glade file
echo "Extracting strings from Glade file..."
xgettext --from-code=UTF-8 \
         --language=Glade \
         --join-existing \
         --output="$POT_FILE" \
         ../res/asbru.glade

# Clean up
rm -f $TEMP_FILES

echo "POT file created: $POT_FILE"
echo "You can now create language-specific PO files using:"
echo "  msginit -l ko_KR.UTF-8 -o ko.po -i $POT_FILE"