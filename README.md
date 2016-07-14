# hdshell

## What is hdshell?
hdshell is a command line script that makes it easy to manage your Hadoop distributed file system (HDFS). Tired of typing something like this?

	$ ls
	file001 file002 file003
	$ bin/hdfs dfs -put file001 file002 file003 /user/saagarjha/input

With hdshell, it's as simple as

	$ hdshell
	/user/saagarjha$ cd input
	/user/saagarjha/input$ put $(ls) @

## Installation
1. Clone this project: `git clone https://github.com/saagarjha/hdshell.git`
2. Open `hdshell.xcodeproj`
3. Build the project. The `hdshell` executable will automatically be placed in `/usr/local/bin`.

## Uninstallation
1. Remove `hdshell` from `/usr/local/bin`.

## Usage
* **Starting hdshell:**  
Type `hdshell` at the command line.
* **Stopping hdshell:**  
Type `exit` and press enter.
* **Running `hdfs` commands in hdshell:**  
Type the command as you would for `hdfs`, dropping `bin/hdfs dfs -`. For example, `bin/hdfs dfs -cat foo` becomes `cat foo`.
* **Using shell commands in hdshell:**  
hdshell will automatically run any command enclosed by `$([your command here])` and replace it with the output of the command. (If your input to hdshell starts with `$`, hdshell will evaluate it `bash` and print the output instead of passing it to `hdfs`.)
* **Setting the home directory in hdshell:**  
By default, the home directory (`~`, the HDFS directory on startup) is `/user/[your user name]`. If you don't particularly like this default, you can change it using `hdshell -d [new home directory]`.
* **Navigating HDFS using hdshell:**  
hdshell recognizes commands such as `cd` and `pwd`, which function as they would in a standard shell.
* **Using HDFS filenames in hdshell:**  
hdshell will attempt to resolve HDFS filenames for you based on your current directory. You may prefix your filename with an `@`, like so: `@../tmp`. If you're in the directory `/user/`, this will be replaced with `/tmp`.

## Planned features
* Comments in the code
* More customization
* Improved filename resolution
* "Shell" features, such as autocomplete and line pushback