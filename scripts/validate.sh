#!/usr/bin/env bash

TEMPLATES="$PWD/templates/*"

for template in $TEMPLATES
do
	echo "Validating $template"
	aws cloudformation validate-template --template-body file:///$template

done
