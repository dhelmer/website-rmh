#!/bin/bash

for file in ./shtml/*
do
    if [[ -f $file ]]; then

        inputfile=`basename -s .shtml "$file"`

	# Assign the filename 'content' to variable $outputfile.
	outputfile=content

	# Body variable to clean up the grep search for the body text. Note: the (?s) allows the dot to match new lines! 
	body='(?<=header\.html)(?s).*(?=footer\.html)'

	# Tile Raw variable to clean up the two sed search/replace lines below for the title.
	titleraw='<DIV ALIGN\=\"CENTER\"><FONT SIZE\=\"\+2\"><B>(.*?)<\/B><\/FONT><\/DIV>'

	# Progress message to the user.
	echo Converting $inputfile.

	# Get the body text and put it into a new file.
	grep -z -o -P $body ./shtml/${inputfile}.shtml > $outputfile

	# Remove the title from the output file as we don't need it in the body content. 
	sed -i -re "s/$titleraw//g" ${outputfile}

	# Grab the title from the original shtml file, assign it to variable for later.
	sed -nr "s|$titleraw|\1|pg" ./shtml/${inputfile}.shtml > title

	# Assign the title to variable $title.
	title=$(cat title)

	# Echo the title to give the user some feeback.
	echo The title is: $title

	# Remove the Printer Friendly line.
	perl -i -pe 's|^.*Printer Friendly Format.*$||g' ${outputfile}

	# Remove the remnant of the footer.html include SSI line.
	sed -i -re 's/^\" -->//' ${outputfile}

	# Remove the remnant of the header.html include SSI line.
	sed -i -e 's/<\!--\#include virtual\=\"\/ssi\/main_//g' ${outputfile}

	# Use tr (translate) command to replace all newlines into tabs making the contents on a single line and store in tmp.txt.
	cat ${outputfile} | tr '\n' '\t' > tmp.txt

	# Use a perl grep to replace the old tags around quoted "letters home" text with a div with a CSS class.
	perl -i -pe 's|<BLOCKQUOTE><FONT FACE="Courier New, Courier">(.*?)</FONT></BLOCKQUOTE>|<div class=\"missive\">\1<\/div>|g' tmp.txt

	# Use tr command to restore the newlines in the single-line content and write the output back into the output file.
	cat tmp.txt | tr '\t' '\n' > ${outputfile}


	# Create the header.
cat > header  <<EOF
<sergey-import src="template">
  <sergey-template name="metadesc">Ron M. Helmer stories about growing up in Calgary and worldly travels.</sergey-template>
  <sergey-template name="metatitle">WorldlyGuy.com | $title </sergey-template>
  <sergey-template name="title">$title</sergey-template>
  <sergey-template name="by">By:</sergey-template>
  <sergey-template name="author">Ron M. Helmer</sergey-template>
  <sergey-template name="authorURL">/authors/ron-helmer.html</sergey-template>

  <!--Content -->
EOF

	# Create the footer.
cat > footer <<EOF
  <!--/Content -->

</sergey-import>
EOF

	# Cat the files together and create the [input filename].html file.
	cat header <(echo) content <(echo) footer <(echo) > ./html/${inputfile}.html

	# Remove the blank lines from the output file.
	sed -i '/^[[:space:]]*$/d' ./html/${inputfile}.html

	# Remove the friggin' Microsoft carriage returns from the document.
	sed -i 's/\r$//' html/${inputfile}.html

	# Remove the non-breaking space pararagraph spacers
	sed -i 's/<P>&nbsp;<\/P>//g' html/${inputfile}.html

	# Remove the temp files and original input file.
	rm header content footer title tmp.txt 

	# Notify user the that the munged file has been created.
	echo Your output file ${inputfile}.html is ready.

    fi
done



