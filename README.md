# JavaCompilation for Texteditors
!This script is targeted for macOS only!

![Screenshot](http://www.moritzf.de/projects/img/javacompile.png)

## What does this script do?
This script enables the compilation and execution of .java-files directly from the 
inteface of your Text-Editor. It also works with package-structures as long as the use of library-jars is not required.

## What Editors can be used?
The script was written for and tested with BBEdit (and previously Textwrangler). It is however agnostic to the editor
in use as long as it is called directly with the editor being the active window in the front.

Background: The script tries to use frontmost document in the frontmost application as basis for compilation and execution.
If that is your texteditor and it supports macOS's scripting features everything is fine.

## Setup with BBEdit
Steps to get the scripts installed:
- open BBEdit
- click the script-icon in the menubar (it looks like an S made of paper) and click on 
 "Open Scripts Folder"
- Copy the script into the folder.

Steps to use the script:
- Open .java-file in BBEdit (also works when you are currently creating a java-file
 but you should save the file before executing the script)
- Click on "ComplileAndRunJava" in the script-menu of BBEdit
