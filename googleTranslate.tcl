#   Translation using Google Translate API
#
#  Usage:
#  !tr <lg> sentence - lg (optional) is the destination language - will default to English

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
        

        # it is not empty: strip it from the translation string and trim both
        if {[binary scan $lngEx c c]} {                    
            regsub -all {\W} $lngEx "" targetlang
            regsub -all {^\s*\w\w\s} $text "" text
            set translateme [string trim $text]
        } else {
            set translateme $text
        }

        # encode it as query and generate the URL
        set translateme [::http::formatQuery  [split $translateme] ]

        # use the app url that the chrome translate expansion uses. Please don't abuse this.
        set appUrl "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto"
        set translationurl "$appUrl&tl=$targetlang&dt=t&q=$translateme"

        # do encoding magic, thanks SergioR on #egghelp
        set apioutput [::http::geturl $translationurl -binary 1]     
        set result [::json::json2dict [encoding convertfrom utf-8 [http::data $apioutput]]]    
        
        # three levels deep down in the nested array lieth the truth...
        set translationresult [lindex $result 0 0 0]
        
        putserv "PRIVMSG $chan :$translationresult"
    }

}

putlog "\002$::googleTranslate::versionName $::googleTranslate::versionNum\002 loaded"
