# Bulk Text From Images #

## Usage ##
In Xcode, edit the Run scheme and add two arguments passed on launch:
1. a path to directory of images containing text
2. the path of an output `.txt` file

Run the scheme, and your output file will be created with the text from the images.

## Known issues 
* The text formatter is not able to determine paragraph breaks properly.
