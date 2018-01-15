#Function: Replaces occurences of search_string with replacement_string in a given text this_text
on replace_text(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to {""}
	return this_text
end replace_text

set front_app to (path to frontmost application as Unicode text)

#Get the file from the editor (Textwrangler, BBEdit etc.)
tell application front_app
	save front document
	set the_file to file of front document
end tell

#Get the name of the file without the .java-Extension. The filename also represents the classname
#of the compiled class.
tell application "Finder"
	set compiled_name to name of (file the_file as alias)
	set compiled_name to text 1 thru (-1 * ((length of ".java") + 1)) of compiled_name
end tell

set no_error to true
set package_name to ""

#Take the first line starting with the keyword "package " and use the information to define the package name.
#Subsequent lines starting with package do not overwrite the value once it is set.
set file_contents to paragraphs of (read file the_file)
repeat with next_line in file_contents
	if (next_line starts with "package ") then
		#Strip away "package ", ";" and spaces
		set package_name to text ((length of "package ") + 1) thru -1 of next_line
		set package_name to replace_text(package_name, ";", "")
		if package_name contains " " then
			set package_name to replace_text(package_name, " ", "")
		end if
		exit repeat
	end if
end repeat

#Get the folder path to the root folder where the package-structure starts
#This is the location from which we call javac and java later
tell application "Finder"
	#For a java-file without package declaration, the folder to use is the parent of the java-file.
	set folder_path to (POSIX path of ((container of file the_file) as string)) as string
	if (not package_name is "") then
		#If a package declaration was found, we can use its length to strip away
		#the according path from our folder_path because the respective (normalized) POSIX-Subpath
		#is of the same length.
		set folder_path to text 1 thru (-1 * (2 + (length of package_name))) of folder_path
	end if
end tell


try
	tell application "Terminal"
		activate
		
		#Define compilation targets by finding all java-files	
		set shell_script to "cd " & quoted form of folder_path & ¬
			"; find . -name \"*.java\" -print | xargs javac "
		
		#Execute the command in the terminal for the user
		if (count windows) is 0 then
			do script shell_script
		else
			do script shell_script in the front window
		end if
		#Get the result of the execution separately to allow error handling
		set result to do shell script shell_script
	end tell
on error
	set no_error to false
end try

#Only try to run the program if compilation was successful.
if (no_error) then
	tell application "Terminal"
		activate
		
		
		if (package_name is "") then
 			set shell_script to "cd " & quoted form of folder_path & ¬
 				"; java " & compiled_name
 		else
 			set shell_script to "cd " & quoted form of folder_path & ¬
 				"; java " & package_name & "." & compiled_name
 		end if
		
		
		if (count windows) is 0 then
			do script shell_script
		else
			do script shell_script in the front window
		end if
	end tell
end if

