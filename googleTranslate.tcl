# 	Translation using Google Translate API
#
#	!tr <lg> Sentence
#   lg is the destination language - will set to English if not found

namespace eval googleTranslate {
	
    variable author "manavortex"
    variable versionNum "0.2"
    variable versionName "googleTranslate"
	
	bind pub - !tr googleTranslate::translate
	
	proc translate { nick uhost handle chan text } {

		set appUrl "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto"
		
		package require http
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
