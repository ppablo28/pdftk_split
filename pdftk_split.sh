#!/bin/bash

# Author: Paweł Parafiński
# Date: 22.10.2013
# Email: ppablo28@gmail.com

# Default number of pages for each PDF file
DEFAULT_NUM=20

# Proper usage of this script
function usage {
    echo "Split the given PDF file into smaller files (format FIRST_PAGE_LAST_PAGE)."
    echo "Arguments:"
    echo -e "\t-n - the maximal number of pages for each PDF file (default - 20)"
    echo -e "\t-f - the source file"
}

# Get file name from the input
function getFileName {
    tmp=$1
    tmp=${tmp##*/}
    FILE_BASE=${tmp%%.*}
}

# Read arguments
function readArgs {
    flag_N=false
    flag_F=false
    while getopts ":n:f:" opt
    do
        case $opt in
            n)
                re='^[1-9][0-9]*$'
                if ! [[ $OPTARG =~ $re ]] ; then
                   usage; exit 1
                fi
                flag_N=true
                DEFAULT_NUM=$OPTARG;;
            f)
                re='^.*.pdf$'
                if ! [[ $OPTARG =~ $re ]] ; then
                    usage; exit 1
                fi
                flag_F=true
                FILE=$OPTARG
                getFileName $FILE;;
            \?)
                echo "Invalid option -$OPTARG"; exit 1;;
        esac
    done
    if ! ($flag_N && $flag_F); then 
        echo "Arguments -f and -n with parameters are required!"; exit 1
    fi
}

### ======== Main body ========= ###
readArgs "$@"

# Get the number of pages from PDF file
NUM_OF_PAGES=`pdftk $FILE dump_data output - | grep NumberOfPages | cut -d' ' -f 2-`

# Check if the PDF file should be split
if [ $NUM_OF_PAGES -le $DEFAULT_NUM ]
then
    echo "Your file is too small to be split. Pages: $NUM_OF_PAGES, given: $DEFAULT_NUM."
    exit 1
fi

# Get the number of iterations
ITER_NUM=$(($NUM_OF_PAGES / $DEFAULT_NUM));

for i in $(eval echo {0..$(($ITER_NUM - 1))})
do
    FIRST=$(($DEFAULT_NUM * $i + 1))
    LAST=$(($DEFAULT_NUM * ($i + 1)))
    echo "Saving file: ${FILE_BASE}_$FIRST-$LAST.pdf"
    `pdftk $FILE cat $FIRST-$LAST output ${FILE_BASE}_$FIRST-$LAST.pdf dont_ask`
done

# Save the rest of the file
if [ $LAST -lt $NUM_OF_PAGES ]
then
    LAST=$(($LAST + 1))
    echo "Saving file: ${FILE_BASE}_$LAST-$NUM_OF_PAGES.pdf"
    `pdftk $FILE cat $LAST-end output ${FILE_BASE}_$LAST-$NUM_OF_PAGES.pdf dont_ask`
fi


