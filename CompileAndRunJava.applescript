on replace_text(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to {""}
	return this_text
end replace_text

tell application "TextWrangler"
	save text document 1
	set the_file to file of text document 1
end tell

tell application "Finder"
	set compiled_name to name of (file the_file as alias)
	set compiled_name to text 1 thru -6 of compiled_name
end tell

set no_error to true
set package_name to ""

set file_contents to paragraphs of (read file the_file)
repeat with next_line in file_contents
	if {next_line contains "package "} then
		set package_name to replace_text(next_line, "package ", "")
		set package_name to replace_text(package_name, ";", "")
		if package_name contains " " then
			set package_name to replace_text(package_name, " ", "")
		end if
	end if
end repeat
if package_name contains "." then
	set package_subpath to replace_text(package_name, ".", "/")
else
	set package_subpath to (package_name)
end if

tell application "Finder"
	set folder_path to (POSIX path of ((container of file the_file) as string)) as string
	set astid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to package_subpath
	set TIs to folder_path's text items -- Any case of package_subpath in folder_path will be replaced.
	set AppleScript's text item delimiters to ""
	set folder_path to TIs as Unicode text
	set AppleScript's text item delimiters to astid
end tell

try
	tell application "Terminal"
		activate
		if (package_name is "") then
			set shell_script to "cd " & quoted form of folder_path & Â
				"; javac " & compiled_name & ".java"
		else
			set shell_script to "cd " & quoted form of folder_path & Â
				"; javac ./**/*.java"
		end if
		if (count windows) is 0 then
			do script shell_script
		else
			do script shell_script in the front window
		end if
		set result to do shell script shell_script
	end tell
on error
	set no_error to false
end try

if (no_error) then
	tell application "Terminal"
		activate
		
		if (package_name is "") then
			set shell_script to "java " & compiled_name
		else
			set shell_script to "java " & package_name & "." & compiled_name
		end if
		
		if (count windows) is 0 then
			do script shell_script
		else
			do script shell_script in the front window
		end if
	end tell
end if

