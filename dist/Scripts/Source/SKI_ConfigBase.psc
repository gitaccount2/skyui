scriptname SKI_ConfigBase extends SKI_QuestBase

; CONSTANTS ---------------------------------------------------------------------------------------

string property		JOURNAL_MENU	= "Journal Menu" autoReadonly
string property		MENU_ROOT		= "_root.ConfigPanelFader.configPanel" autoReadonly

int property		OPTION_EMPTY	= 0 autoReadonly
int property		OPTION_HEADER	= 1 autoReadonly
int property		OPTION_TEXT		= 2 autoReadonly
int property		OPTION_TOGGLE	= 3 autoReadonly
int property 		OPTION_SLIDER	= 4 autoReadonly
int property		OPTION_MENU		= 5 autoReadonly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

SKI_ConfigManager	_configPanel
bool				_initialized	= false
int					_configID		= -1
int					_optionCount	= 0

; Local buffers
float[]				_optionTypeBuf
string[]			_textBuf
string[]			_strValueBuf
float[]				_numValueBuf


; PROPERTIES --------------------------------------------------------------------------------------

string property		ModName auto
string[] property	Pages auto
string property		CurrentPage auto hidden


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	_configPanel = Game.GetFormFromFile(0x00000802, "SkyUI.esp") As SKI_ConfigManager
	
	_optionTypeBuf	= new float[128]
	_textBuf		= new string[128]
	_strValueBuf	= new string[128]
	_numValueBuf	= new float[128]
	
	gotoState("_INIT")
	RegisterForSingleUpdate(3)
endEvent

state _INIT
	event OnUpdate()
		gotoState("")
		_configID = _configPanel.RegisterMod(self, ModName)
		if (_configID != -1)
			OnConfigRegister()
			_initialized = true
		endIf
	endEvent
endState


; EVENTS ------------------------------------------------------------------------------------------

; @interface
event OnConfigRegister()
endEvent

; @interface
event OnPageReset(string a_page)
endEvent

; @interface
event OnOptionHover(int a_option)
endEvent

; @interface
event OnOptionSelect(int a_option)
endEvent

; @interface
event OnOptionDefault(int a_option)
endEvent

; @interface
event OnOptionSliderOpen(int a_option)
endEvent

; @interface
event OnOptionSliderAccept(int a_option, float a_value)
endEvent

; @interface
event OnOptionMenuOpen(int a_option)
endEvent

; @interface
event OnOptionMenuAccept(int a_option, int a_menu)
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

int function AddOption(int a_optionType, string a_text, string a_strValue, float a_numValue)
	
	if (_optionCount >= 127)
		return -1
	endIf
	
	int id = _optionCount
	
	_optionTypeBuf[id] = a_optionType
	_textBuf[id] = a_text
	_strValueBuf[id] = a_strValue
	_numValueBuf[id] = a_numValue
	
	_optionCount += 1
	
	return id
endFunction

int function AddEmptyOption()
	return AddOption(OPTION_EMPTY, none, none, 0)
endFunction

int function AddHeaderOption(string a_text)
	return AddOption(OPTION_HEADER, a_text, none, 0)
endFunction

int function AddTextOption(string a_text, string a_value)
	return AddOption(OPTION_TEXT, a_text, a_value, 0)
endFunction

int function AddToggleOption(string a_text, bool a_checked)
	return AddOption(OPTION_TOGGLE, a_text, none, a_checked as int)
endfunction

int function AddSliderOption(string a_text, float a_value)
	return AddOption(OPTION_SLIDER, a_text, none, a_value)
endFunction

int function AddMenuOption(string a_text, string a_value)
	return AddOption(OPTION_MENU, a_text, a_value, 0)
endFunction

function LoadCustomContent(string a_source)
	UI.InvokeString(JOURNAL_MENU, MENU_ROOT + ".loadCustomContent", a_source)
endFunction

function UnloadCustomContent()
	UI.Invoke(JOURNAL_MENU, MENU_ROOT + ".unloadCustomContent")
endFunction

function FlushOptionBuffers()
	string menu = JOURNAL_MENU
	string root = MENU_ROOT
	
	UI.InvokeNumberA(menu, root + ".setOptionTypeBuffer", _optionTypeBuf)
	UI.InvokeStringA(menu, root + ".setOptionTextBuffer", _textBuf)
	UI.InvokeStringA(menu, root + ".setOptionStrValueBuffer", _strValueBuf)
	UI.InvokeNumberA(menu, root + ".setOptionNumValueBuffer", _numValueBuf)
	UI.InvokeNumber(menu, root + ".flushOptionBuffers", _optionCount)
	
	_optionCount = 0
endFunction