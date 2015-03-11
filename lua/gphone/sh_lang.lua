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
		lang = tostring(lang)
		lang = lang:lower()
		
		if gPhone.languages[lang] then
			if gPhone.getActiveLanguage() != lang then
				-- Run a hook that the language has changed
				hook.Run( "gPhone_languageChanged", gPhone.getActiveLanguage(), lang )
			end
			
			LocalPlayer():ConCommand("gphone_language "..lang)
		else
			gPhone.msgC( GPHONE_MSGC_WARNING, "Attempt to set active language to invalid ("..lang..")")
			LocalPlayer():ConCommand("gphone_language english")
			return
		end
	end
end
	
--// Creates a language table with a name and code ex: createLanguage( "english" )
function gPhone.createLanguage( name )
	name = name:lower()
	gPhone.languages[name] = {}
	
	setmetatable(gPhone.languages[name],
	{
		-- If we try to access a non existant key, return the key so it can be added
		__index = function(t, k)
			gPhone.msgC( GPHONE_MSGC_WARNING, 
			string.format("Unable to get translation for (#%s) in language (%s)",
			k, gPhone.getActiveLanguage()))
			
			if gPhone.config.replaceMissingTranslations == true then
				gPhone.languages[name][k] = gPhone.languages["english"][k]
				return gPhone.languages["english"][k]
			else
				gPhone.languages[name][k] = "##"..k
				return "##"..k
			end
		end
	})
	
	return gPhone.languages[name]
end

--// Returns the string that matches the id for the current language (abbreviated as 'trans')
function gPhone.getTranslation( id )
	return gPhone.languages[gPhone.getActiveLanguage()][id:lower()]
end

--// Returns the english translation of the id
function gPhone.getTranslationEN( id )
	return gPhone.languages["english"][id:lower()]
end

--// Used for fast, direct language lookups in functions that are called often (abbreviated as 'l')
function gPhone.getLanguageTable()
	return gPhone.languages[gPhone.getActiveLanguage()]
end

function gPhone.getLanguageTableFor( lang )
	return gPhone.languages[lang:lower()]
end

--// Adds a new phrase and id to the language table if exists and returns the phrase, throws warnings otherwise
function gPhone.addTranslation( id, phrase, language )
	language = language or "english"
	
	if gPhone.languages[language:lower()] then
		if gPhone.languages[language:lower()][id] then
			gPhone.msgC( GPHONE_MSGC_WARNING, "Overriding existing language phrase ("..id..") with '"..phrase.."'")
		end
		gPhone.languages[language:lower()][id] = phrase
		return phrase
	else
		gPhone.msgC( GPHONE_MSGC_WARNING, "Attempted to add language phrase ("..id..") to invalid language ("..language..")")
	end
end

--// Directly adds the phrase and id to the table without any warnings
function gPhone.addTranslationUnsafe( language, id, phrase )
	gPhone.languages[language:lower()][id] = phrase
end

--// Returns missing translations or the code needed to add them to your language file
function gPhone.getMissingTranslations( lang, bFormatted )
	local missing = {}
	local testedLang = gPhone.languages[lang:lower()]
	
	for id, phrase in pairs( gPhone.languages["english"] ) do
		if testedLang[id] == nil or testedLang[id] == "##"..id then
			if bFormatted == true then
				missing["l."..id] = '"'..phrase..'"'
			else
				missing[id] = phrase
			end
		end
	end
	
	return missing
end

--// Returns the active language of either the client or server
function gPhone.getActiveLanguage()
	if SERVER then
		return GetGlobalString( "gPhone_serverlang", gPhone.languages.default )
	else
		return gPhone.language:GetString():lower()
	end
end
