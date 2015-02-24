----// Shared Language Functions //----

gPhone.languages.default = "english"

if SERVER then
	
	--// Sets the language to be used by all serverside functions
	function gPhone.setActiveLanguage( lang )
		lang = lang:lower()
		
		if gPhone.languages[lang] then
			SetGlobalString( "gPhone_serverlang", lang )
		else
			gPhone.msgC( GPHONE_MSGC_WARNING, "Attempt to set active language to invalid ("..lang..")")
			return
		end
	end
end

if CLIENT then
	gPhone.language = CreateClientConVar("gphone_language", gPhone.languages.default, true, true)	
	
	-- Handle convar changes
	cvars.AddChangeCallback("gphone_language", function(convar_name, value_old, value_new)
		gPhone.setActiveLanguage( value_new )
	end)
	
	--// Sets the clients active language
	function gPhone.setActiveLanguage( lang )
		lang = lang:lower()
		
		if gPhone.languages[lang] then
			LocalPlayer():ConCommand("gphone_language "..lang)
		else
			gPhone.msgC( GPHONE_MSGC_WARNING, "Attempt to set active language to invalid ("..lang..")")
			return
		end
	end
end
	
--// Creates a language table with a name and code ex: createLanguage( "english" )
function gPhone.createLanguage( name )
	name = name:lower()
	gPhone.languages[name] = {}
	return gPhone.languages[name]
end

--// Returns the string that matches the id for the current language (abbreviated as 'trans')
function gPhone.getTranslation( id )
	if gPhone.languages[gPhone.getActiveLanguage()] != nil then
		if gPhone.languages[gPhone.getActiveLanguage()][id] then
			return gPhone.languages[gPhone.getActiveLanguage()][id]
		end
	end
	
	gPhone.msgC( GPHONE_MSGC_WARNING, string.format("Unable to get translation for (%s) in language (%s)",
	id, gPhone.getActiveLanguage()))
	
	return "T-ERROR"
end

--// Returns the direct translation for an id without error prevention
function gPhone.getTranslationUnsafe( id )
	return gPhone.languages[gPhone.getActiveLanguage()][id]
end


--// Returns the english translation that matches the id 
function gPhone.getTranslationEN( id )
	return gPhone.languages["english"][id]
end

--// Translates the current phrase to english from another language
function gPhone.phraseToEnglish( str, initialLang )
	
end

--// Used for fast, direct language lookups in functions that are called often (abbreviated as 'l')
function gPhone.getLanguageTable()
	return gPhone.languages[gPhone.getActiveLanguage()]
end

--// Adds a new phrase and id to the language table if exists, throws warnings otherwise
function gPhone.addTranslation( language, id, phrase )
	if gPhone.languages[language:lower()] then
		if gPhone.languages[language:lower()][id] then
			gPhone.msgC( GPHONE_MSGC_WARNING, "Overriding existing language phrase ("..id..") with '"..phrase.."'")
		end
		gPhone.languages[language:lower()][id] = phrase
	else
		gPhone.msgC( GPHONE_MSGC_WARNING, "Attempted to add language phrase ("..id..") to invalid language ("..language..")")
	end
end

--// Directly adds the phrase and id to the table without any warnings
function gPhone.addTranslationUnsafe( language, id, phrase )
	gPhone.languages[language:lower()][id] = phrase
end

--// Returns the active language of either the client or server
function gPhone.getActiveLanguage()
	if SERVER then
		return GetGlobalString( "gPhone_serverlang", gPhone.languages.default )
	else
		return gPhone.language:GetString():lower()
	end
end

