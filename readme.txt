$Amigan: beartkat/readme.txt,v 1.5 2005/01/17 15:36:03 dcp1990 Exp $
*******************************************************************************
***									    ***
***				BearTKat Readme				    ***
***     PLEASE READ! PLEASE READ! PLEASE READ! PLEASE READ! PLEASE READ!    ***
***									    ***
*******************************************************************************
BearTKAT: http://www.theamigan.net/beartkat.html -- mirror: http://styx.theamigan.net:88/~dcp1990/beartkat.html
1.0 Introduction
	Welcome to BearTKat, one of the most fully-featured free scanner control applications for the BC250D and other Bearcat series scanner radios from Uniden that runs on both Unix and Windows! For someone new to computing, the Tcl/Tk approach may seem awkward and overly complicated. However, it is very sensible in actuality. Using Tcl/Tk allows more time to be spent on the application than interface coding and having differing codebases for different platforms. It also makes the author's job easier by bringing some comforts of the Unix programming environment to Windows, while maintaining consistency with other applications on the platform.
	If you have bug reports, fixes, suggestions, questions, comments, or anything else, feel free to direct them to Dan at dcp1990@neptune.atopia.net.
1.1 System Prerequisites
	*Tcl/Tk 8.4 (stock for Unix works fine, on Windows, ActiveTcl works very nicely) (available from http://www.tcl.tk/)
	*A BC250D radio and cable, other models may work with modifications
	*A Unix-like operating system, Windows, and possibly Mac Classic
	*A text editor (Vim is a fine choice)
	*The tablist package, available from http://www.nemethi.de/
	*425k of disk space on Windows, less on Unix. More for frequency databases.
1.2 Licensing
	BearTKat is one of the first applications licensed under the DUPL. A copy of the DUPL should be in the source distribution or displayed during installation on Windows. Please take the time to read the license, and if you are a commercial entity, it is imperative that you do so. If you are unsure about any part, talk to qualified legal personnel.
1.3 Developer Test Platforms
	Dan is able to test BearTKat on:
	*FreeBSD (stock Unix Tcl/Tk 8.4)
	*Windows XP (ActiveTcl/Tk 8.4)
	*Linux (stock Unix Tcl/Tk 8.4)
2.0 Installation and execution
	On Unix, simply run src/beartkat.tcl. If your radio is on a serial device other than /dev/cuaa0 and/or your radio's baud rate is not 19200bps, edit beartkat.conf accordingly before use. If the path to your wish binary is not /usr/local/bin/wish8.4 (as it is on FreeBSD), change the first line of beartkat.tcl accordingly.
	On Windows, run Setup.exe and the wizard will guide you from there. After installation, click either of the shortcuts created on the Desktop or the Start Menu. If your radio is on a serial device other than COM1: and/or your radio is set to a speed other than 19200 baud, please edit beartkat.conf (in the beartkat installation directory) as such. There should be a configuration utility/dialog in the very near future to handle this.
	I am unsure about MacOS Classic, but I would imagine OSX users would follow a combination of the Windows and Unix procedures outlined above.
2.1 Usage
	Upon execution of BearTKat, it will probe for your radio (by sending an "SI" command). If, after 9 tries, the radio doesn't respond, it will notify the user. If the user chooses to ignore, they can re-probe for the radio by going to Help->About my radio (which resends an "SI" command). Upon sucessful probing, the "Model:" label is set accordingly. After that, you are presented with 3 windows: the main window, the LCD/Keypad window, and the Frequency Import/Exportation window. Each serves a particular purpose, being either of:
	*Controling BearTKat itself
	*Controling the radio and displaying it's status
	*Managing memories within the radio
2.2 BearTKat dialogs
	"Set Alpha Tags," available from the Scanner menu in the main window, as it's name implies, allows you to set, clear, and retreive alpha tags for a given channel. In the channel box, one must enter a three-digit channel number, 000 being channel 1000 and 001 being channel 1. You must pad the number with zeroes. Use is fairly self-explanatory besides that point.
	The "About my radio" dialog, accessed from the Help menu, allows one to view information about their radio, including model number and battery status.
2.3 Radio control
	The LCD/Keypad window emulates the LCD display of the radio and a select few buttons. To begin polling the radio for it's LCD contents, click the "Start Polling" button in the main window. When polling is enabled, BearTKat will request LCD contents every second (this is adjustable by using the "interval" configuration parameter) until the "Stop Polling" button is pressed. You may resume polling by clicking "Start Polling" again. Other than that, use is fairly self-explanatory.
2.4 Frequency Management
	A frequency database is simply a file with lines in the form of:
Channel:freq.uency,"Alpha Tag",-d <yes|no>, -l <yes|no>
For example:
	016:0154.6950,"State",-d yes -l no
Channel is a 3 digit number (padded with zeroes), frequency is the frequency in megahertz, -d specifies the delay flag, and -l specifies the lockout flag. An example is included in the file dumps/dump.chan.
To dump your frequencies, use the buttons in the "Frequencies" window. Open the dump file using the leftmost "Browse" button. Select what banks you want to dump by clicking the appropriate tickboxes.
To load your frequencies, use the "Load Frequencies" button. Select the frequency database using the rightmost "Browse" button.
2.5 Channel dialog
	The channel dialog allows one to load a dump in the proper format and manage the channels. Currently, only tuning to a specific channel is supported (and the scanner and dump file must be in sync to work properly).
