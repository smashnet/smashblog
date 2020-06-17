#!/bin/bash

DATE=$(git log -1 --format=%cd)
echo "Inserting last updated: $DATE"
sed -i "s/--date--/$DATE/g" _includes/footer.html
