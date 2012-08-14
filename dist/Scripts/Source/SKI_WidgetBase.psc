scriptname SKI_WidgetBase extends SKI_QuestBase

; CONSTANTS ---------------------------------------------------------------------------------------

string property		HUD_MENU = "HUD Menu" autoReadOnly


; PRIVATE VARIABLES -------------------------------------------------------------------------------

SKI_WidgetManager	_widgetManager

bool				_initialized = false
int					_widgetID = -1
string				_type = ""
string				_widgetRoot = ""
string[]			_modes
float				_x = 0.0
float				_y = 0.0
float				_alpha = 100.0


; PROPERTIES --------------------------------------------------------------------------------------

; Read-only
int property WidgetID
	int function get()
		return _widgetID
	endFunction
endProperty

; Read-only
bool property Initialized
	bool function get()
		return  _initialized
	endFunction
endProperty

; Read-only
string property WidgetRoot
	string function get()
		return  _widgetRoot
	endFunction
endProperty

string[] property Modes
	{HUDModes in which the widget is visible, see readme for available modes}
	string[] function get()
		return  _modes
	endFunction
	
	function set(string[] a_val)
		_modes = a_val
		if (_initialized)
			UpdateWidgetModes()
		endIf
	endFunction
endProperty

float property X
	{Horizontal position of the widget in pixels at a resolution of 1280x720}
	float function get()
		return _x
	endFunction
	
	function set(float a_val)
		_x = a_val
		if (_initialized)
			UpdateWidgetPositionX()
		endIf
	endFunction
endProperty

float property Y
	{Vertical position of the widget in pixels at a resolution of 1280x720}
	float function get()
		return _y
	endFunction
	
	function set(float a_val)
		_y = a_val
		if (_initialized)
			UpdateWidgetPositionY()
		endIf
	endFunction
endProperty

float property Alpha
	{Opacity of the widget as a percentage}
	float function get()
		return _alpha
	endFunction
	
	function set(float a_val)
		_alpha = a_val
		if (Initialized)
			UpdateWidgetAlpha()
		endIf
	endFunction
endProperty


; INITIALIZATION ----------------------------------------------------------------------------------

event OnInit()
	; Default Modes if not set via property
	if (!_modes)
		_modes = new string[2]
		_modes[0] = "All"
		_modes[1] = "StealthMode"
	endIf
	
	_widgetManager = Game.GetFormFromFile(0x00000800, "SkyUI.esp") As SKI_WidgetManager
	
	gotoState("_INIT")
	RegisterForSingleUpdate(3)
endEvent

state _INIT
	event OnUpdate()
		gotoState("")
		_widgetID = _widgetManager.RequestWidgetID(self)
		if (_widgetID != -1)
			_widgetRoot = "_root.WidgetContainer." + _widgetID + ".widget"
			OnWidgetInit()
			_widgetManager.CreateWidget(_widgetID, GetWidgetType())
			_initialized = true
		else
			Debug.Trace("WidgetWarning: " + self as string + ": could not be loaded, too many widgets. Max is 128")
		endIf
	endEvent
endState

; Do any custom widget initialization here.
; @interface
event OnWidgetInit()
endEvent


; EVENTS ------------------------------------------------------------------------------------------

; Executed after each game reload by widget manager.
event OnWidgetLoad()
	OnWidgetReset()
	
	; Before that the widget was still hidden.
	; Now that everything is done, set modes to show it eventually.
	UpdateWidgetModes()
endEvent

event OnWidgetReset()
	; Reset base properties except modes to prevent widget from being drawn too early.
	UpdateWidgetClientInfo()
	UpdateWidgetPositionX()
	UpdateWidgetPositionY()
	UpdateWidgetAlpha()
endEvent

; Executed whenever a hudModeChange is observed
; TODO
event OnHudModeChange(string a_eventName, string a_hudMode, float a_numArg, Form sender)
endEvent


; FUNCTIONS ---------------------------------------------------------------------------------------

; @interface
string function GetWidgetType()
	return ""
endFunction

function UpdateWidgetClientInfo()
	UI.InvokeString(HUD_MENU, _widgetRoot + ".setClientInfo", self as string)
endFunction

function UpdateWidgetPositionX()
	UI.SetNumber(HUD_MENU, _widgetRoot + "._x", X)
endFunction

function UpdateWidgetPositionY()
	UI.SetNumber(HUD_MENU, _widgetRoot + "._y", Y)
endFunction

function UpdateWidgetAlpha()
	UI.SetNumber(HUD_MENU, _widgetRoot + "._alpha", Alpha)
endFunction

function UpdateWidgetModes()
	UI.InvokeStringA(HUD_MENU, _widgetRoot + ".setModes", Modes)
endFunction
