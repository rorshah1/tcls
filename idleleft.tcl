### idleleft.tcl by rorshah for channel #FreeBot / Bg IRC NETWORK
### Commands in #FreeBot:
### !addbot [botname] <host> - Add hostmask to except list for idle checker!
### !delbot [botname] <host> - Del hostmask from except list for idle checker!
### !botlist - Loading except list!
### !activity <botname> [channel] - Loading channel's activity!
### Auto leave after 7 days unactivity!

setudef int msgidle
setudef int joinidle

bind pub * "!activity" check:active
bind pub * "!addbot" add:bot
bind pub * "!botlist" bot:list
bind pub * "!delbot" del:bot
bind pubm * "*" reset:msg
bind join * * reset:join
bind time - "04 00 * * *" incr:data

set chanmaika "#freebot"

proc incr:data {min hr day mth yr} {
global chanmaika
putnow "PRIVMSG $chanmaika :Update channel activity..."
foreach c [channels] {
if {$c != $chanmaika} {
set mid [channel get $c msgidle]
if {$mid == "7" || $mid > "7"} {
channel set $c msgidle "0"
channel set $c joinidle "0"
putnow "PRIVMSG $c :This channel is not active! Automatic leave after 7 days!"
putnow "PRIVMSG $chanmaika :Automatic leave from $c! 7 days unactivity!"
channel remove $c
}
if {$mid < "7"} {
incr mid
set jid [channel get $c joinidle]
incr jid
channel set $c msgidle "$mid"
channel set $c joinidle "$jid"
}
}
}
}
proc reset:join {nick uhost hand chan} { 
global chanmaika botnick
if {$chan != $chanmaika && $nick != $botnick && ![matchattr $hand B|B]} { 
if {[channel get $chan joinidle] == "0"} { return 0 }
if {[channel get $chan joinidle] != "0"} { channel set $chan joinidle "0"; return 0 }
}
}

proc reset:msg {nick uhost hand chan text} {
global chanmaika botnick
if {$chan != $chanmaika && $nick != $botnick && ![matchattr $hand B|B]} { 
if {[channel get $chan msgidle] == "0"} { return 0 }
if {[channel get $chan msgidle] != "0"} { channel set $chan msgidle "0"; return 0 }
}
}

proc del:bot {nick uhost hand chan text} {
global chanmaika botnick
if {$chan == $chanmaika && [isop $nick $chan]} {
if {[onchan [lindex $text 0] $chan]} { 
if {[string toupper [lindex $text 0]] == [string toupper $botnick] && [lindex $text 1] != ""} {
set m "false"
foreach host [getuser "bot" hosts] {
if {$host == [lindex $text 1]} { delhost bot $host; putnow "PRIVMSG $chan :Removed host: [lindex $text 1] from botlist!"; set m "true"; return 0; }
if {$m == "false"} { putnow "PRIVMSG $chan :Host: [lindex $text 1] is not on botlist!"; return 0; }
}
}
}
if {![onchan [lindex $text 0] $chan]} { 
if {[lindex $text 0] != ""} {
set m "false"
foreach host [getuser "bot" hosts] {
if {$host == [lindex $text 0]} { delhost bot $host; putnow "PRIVMSG $chan :Removed host: [lindex $text 0] from botlist!"; set m "true"; return 0; }
if {$m == "false"} { putnow "PRIVMSG $chan :Host: [lindex $text 0] is not on botlist!"; return 0; }
}
}
}
}
}

proc bot:list {nick uhost hand chan text} {
global chanmaika botnick
if {$chan == $chanmaika && [isop $nick $chan]} { 
if {[string toupper [lindex $text 0]] == [string toupper $botnick]} {
set n "1"
putnow "PRIVMSG $chan :Loading hosts..."
foreach host [getuser "bot" hosts] {
putnow "PRIVMSG $chan :$n. $host"
incr n
}
}
}
}
proc add:bot {nick uhost hand chan text} {
global chanmaika botnick
if {$chan == $chanmaika && [isop $nick $chan]} {
if {[onchan [lindex $text 0] $chan]} { 
if {[string toupper [lindex $text 0]] == [string toupper $botnick] && [lindex $text 1] != ""} {
if {[matchattr "bot" B|B] == "0"} {
 set botstats [adduser bot [lindex $text 1]];
 if {$botstats == "1"} { putnow "PRIVMSG $chan :Added bot \"bot\" with host [lindex $text 1]!"; 
chattr bot "+B"
return 0
}
 if {$botstats == "0"} { putnow "PRIVMSG $chan :Can't be added \"bot\""; return 0; }
 return 0; 
}
if {![string match -nocase "*[lindex $text 1]*" [getuser "bot" hosts]]} {
setuser bot hosts [lindex $text 1]
putnow "PRIVMSG $chan :Added [lindex $text 1] to botlist!"
return 0
}
if {[string match -nocase "*[lindex $text 1]*" [getuser "bot" hosts]]} {
putnow "PRIVMSG $chan :This host is already added!"
return 0
}
}
 return 0; 
}
if {[matchattr "bot" B|B] == "0"} {
 set botstats [adduser bot [lindex $text 0]];
 if {$botstats == "1"} { putnow "PRIVMSG $chan :Added bot \"bot\" with host [lindex $text 0]"; 
chattr bot "+B"
return 0
}
 if {$botstats == "0"} { putnow "PRIVMSG $chan :Can't be added \"bot\""; return 0; }
 return 0; 
}
if {![string match -nocase "*[lindex $text 0]*" [getuser "bot" hosts]]} {
setuser bot hosts [lindex $text 0]
putnow "PRIVMSG $chan :Added [lindex $text 0] to botlist"
return 0
}
if {[string match -nocase "*[lindex $text 0]*" [getuser "bot" hosts]]} {
putnow "PRIVMSG $chan :This host is already added!"
return 0
}
}
}

proc inc:idle {nick uhost hand chan text} {
putlog "[lindex [string map -nocase [list "@" " "] $uhost] 1]"
putlog "[matchattr $hand b|b $chan]"
set numer [channel get $chan msgidle]
set numer [incr numer]
channel set $chan msgidle "$numer"
putnow "PRIVMSG $chan :done"
putnow "PRIVMSG $chan :$numer"

}

proc check:active {nick uhost hand chan text} {
global chanmaika botnick
if {$chan == $chanmaika && [isop $nick $chan] && [string toupper [lindex $text 0]] == [string toupper $botnick] && [lindex $text 1] != ""} {
putnow "PRIVMSG $chan :Channel activity...."
set nn "0"
set nicklista ""
foreach nchan [chanlist [lindex $text 1]] {
if {$nn < "7"} { append nicklista "$nchan; "; }
incr nn
}
if {$nn > "7"} { set nicklista "Too many " }
putquick "PRIVMSG $chan :Channel: [lindex $text 1] | MSG: \"[channel get [lindex $text 1] msgidle]\" d. | JOIN: \"[channel get [lindex $text 1] joinidle]\" d. | USERS: \"$nn\" \( $nicklista\) "
}
if {$chan == $chanmaika && [isop $nick $chan] && [string toupper [lindex $text 0]] == [string toupper $botnick] && [lindex $text 1] == ""} {
putnow "PRIVMSG $chan :Channels activity...."
set num "1"
foreach channel [channels] {
set nn "0"
set nicklista ""
foreach nchan [chanlist $channel] {
if {$nn < "7"} { append nicklista "$nchan; "; }
incr nn
}
if {$nn > "7"} { set nicklista "Too many " }
if {$channel != ""} { putquick "PRIVMSG $chan :$num. | Channel: $channel | MSG: \"[channel get $channel msgidle]\" d. | JOIN: \"[channel get $channel joinidle]\" d. | USERS: \"$nn\" \( $nicklista\) " }
incr num
}
}
}

putlog "idleleft.tcl loaded..."
