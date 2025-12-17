#!/bin/bash

# Rebuild run.n (CLI bytecode)
echo "Building run.n..."
haxe -main Run -neko run.n
if [ $? -ne 0 ]; then
    echo "Error building run.n"
    exit 1
fi

# Target zip file
ZIP_NAME="shade.zip"

# Delete existing zip if it exists
rm -f "$ZIP_NAME"

# Create a temporary exclude file
EXCLUDE_FILE=".zipexclude"

# Write excluded patterns to the exclude file
cat > "$EXCLUDE_FILE" << EOF
.git/*
.git/**/*
.vscode/*
.vscode/**/*
.haxelib/*
.haxelib/**/*
.DS_Store
*.log
test/out/*
test/out/**/*
submit.sh
$ZIP_NAME
$EXCLUDE_FILE
EOF

# Create zip command and execute
echo "Creating $ZIP_NAME..."
zip -r "$ZIP_NAME" . -x@"$EXCLUDE_FILE"

# Check if zip was successful
STATUS=$?
if [ $STATUS -eq 0 ]; then
    echo "Successfully created $ZIP_NAME"
else
    echo "Error creating zip file"
fi

# Clean up the temporary exclude file
rm "$EXCLUDE_FILE"

haxelib submit shade.zip

exit $STATUS
