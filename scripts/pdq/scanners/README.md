# Scanners

These are powershell scripts specifically tested and used for PDQ scanners

## Usage
  1. Go to the "scanners" option, create a new scanner and name it with the file type set as "powershell script".
  2.  Copy and paste the script (or import it) in the command field.
  3.  Select a test device to run it on.
  4.  after pdq ran the script successfully make sure to select the variable type appropriately (ie. string (most will be strings btw))

## What it does
These powershell scanners are custom scripts I created because PDQ either didn't provide them or I couldn't find the information the way I wanted it.

## Notes
PDQ requires variables to be selected so you can assign the information your wanting into outputted data. 
Meaning If I run a powershell script to pull CPU models, 
I need a variable called "CPU models" so the information can be pushed on the device.
