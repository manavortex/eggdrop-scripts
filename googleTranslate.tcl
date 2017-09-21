# 	Translation using Google Translate API
#
#	Usage:
#	!tr <lg> sentence - lg (optional) is the destination language - will default to English

namespace eval googleTranslate {
	
    variable author "manavortex"
    variable versionNum "0.1"
    variable versionName "googleTranslate"
	
	http::register https 443 [list ::tls::socket -ssl2 0 -ssl3 0 -tls1 1]

	bind pub - !tr googleTranslate::translate
	
	proc translate { nick uhost handle chan text } {

		set appUrl "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto"
		
		package require http 2.7
		package require tls 1.6
		package require json


		#set default language 
		set targetlang "en"

		#try to overwrite with language from translation string:
        set lngEx [regexp -all -inline -- {^\s*\w\w\s} $text]
        
        # if we set a destination language, strip them from text

        # it is not empty
        if {[binary scan $lngEx c c]} {                    
            regsub -all {\W} $lngEx "" targetlang
			regsub -all {^\s*\w\w\s} $text "" text
			set translateme [string trim $text]
        
        # it is empty
        } else {
			set translateme $text
        }


		set translateme [::http::formatQuery  [split $translateme] ]
		set appUrl "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto"
		set translationurl "$appUrl&tl=$targetlang&dt=t&q=$translateme"

		
 		set apioutput [::http::geturl $translationurl -binary 1] 		
		set result [::json::json2dict [encoding convertfrom utf-8 [http::data $apioutput]]]		
		set translationtext [lindex [lindex [lindex $result 0] 0] 0]
		
		putserv "PRIVMSG $chan :$translationtext"
	}

}

putlog "\002$::googleTranslate::versionName $::googleTranslate::versionNum\002 loaded"
