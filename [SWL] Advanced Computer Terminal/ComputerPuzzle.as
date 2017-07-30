/*
Copyright © 2017 Sergey "Rianon" Pugovkin. All Rights Reserved.
Copyright © 2012 Funcom. All Rights Reserved.
This code partially based on Funcom User Interface Source Code.
*/
import com.Utils.LDBFormat;
import com.Utils.Faction;
import com.GameInterface.Log;
import com.GameInterface.ComputerPuzzleIF;
import com.GameInterface.DistributedValue;
import com.GameInterface.GUIModuleIF;
import com.GameInterface.Game.Character;
import com.GameInterface.ProjectUtils;
import gfx.motion.Tween;
import gfx.controls.Button;
import mx.utils.Delegate;

var ILLUMINATI_SKIN:String = "Illuminati";
var TEMPLARS_SKIN:String = "Templars";
var DRAGON_SKIN:String = "Dragon";
var VALENTINE_SKIN:String = "Valentine";
var STANDARD_SKIN:String = "Default";
var TEXT_AREA_LINE_HEIGHT:Number = 14.8;	// Height of 1 line of text on main screen
var TEXT_AREA_WIDTH:Number = 700;			// Width of main screen text area
var TEXT_COLOR_STANDARD:Number = 0x00FF00;
var TEXT_COLOR_DRAGON:Number = 0x9DC785;
var TEXT_COLOR_ILLUMINATI:Number = 0x9FE2FF;
var TEXT_COLOR_TEMPLARS:Number = 0xFAE5E4;
var TEXT_COLOR_VALENTIN:Number = 0xFC7175;
var TITLE_ACCESSING_DATA_EN:String = "DATA ACCESS ESTABLISHED";
var TITLE_ACCESSING_DATA_DE:String = "DATENZUGANG GEGRÜNDET";
var TITLE_ACCESSING_DATA_FR:String = "ACCÈS AUX DONNÉES ÉTABLI";
var TITLE_NO_LOCALE:String = "LOCALE NOT DETECTED";
var INPUT_FIELD_HOLDER_TEXT:String = LDBFormat.LDBGetText("GenericGUI", "ComputerPuzzle_InputFieldHolderText");
var CURRENT_LOCALE:String = LDBFormat.GetCurrentLanguageCode();

var g_FocusListener:Object = new Object();
var m_UserInputField:TextField;
var layout:String;
var m_Character:Character;
var m_TextArea:MovieClip;
var m_Title:MovieClip;
var m_KeyHintAlt:MovieClip;
var m_KeyHintCtrl:MovieClip;
var m_SkinParent:MovieClip;
var m_UserInputField:MovieClip;
var m_Closing:Boolean;
var m_CurrentTextColor:Number;

var m_ArrowUpColor:Color = new Color(m_TextArea.m_ArrowUp);
var m_ArrowDownColor:Color = new Color(m_TextArea.m_ArrowDown);
var m_SkinSaved:DistributedValue = DistributedValue.Create("ComputerPuzzleSkin");

function onLoad()
{
	m_CloseButton.disableFocus = true;
	Log.Info2("ComputerPuzzle", "onLoad()");
	switch (CURRENT_LOCALE)
	{
		case "de":
			m_Title.textField.text = TITLE_ACCESSING_DATA_DE;
			break;
		case "fr":
			m_Title.textField.text = TITLE_ACCESSING_DATA_FR;
			break;
		case "en":
			m_Title.textField.text = TITLE_ACCESSING_DATA_EN;
			break;
		default:
			m_Title.textField.text = TITLE_NO_LOCALE;
			break;
	}
    m_CurrentTextColor = TEXT_COLOR_STANDARD;
	m_TextArea.textField.textColor = m_CurrentTextColor;
	m_Title.textField.textColor = m_CurrentTextColor;
	m_KeyHintAlt.textField.textColor = m_CurrentTextColor;
	m_KeyHintCtrl.textField.textColor = m_CurrentTextColor;
	m_UserInputField.textField.textColor = m_CurrentTextColor;
	m_CommandPrompt.textField.textColor = m_CurrentTextColor;
	m_TextArea.textField.htmlText = "";    
    m_TextArea.textField.autoSize = "left";
	m_KeyHintAlt._visible = false;
	m_KeyHintCtrl._visible = false;
    
    m_Character = Character.GetClientCharacter();
    if (m_Character != undefined)
	{
		m_Character.AddEffectPackage( "sound_fxpackage_GUI_computer_activated.xml" );
	}
	
	ComputerPuzzleIF.SignalTextUpdated.Connect(SlotTextUpdated, this);
	ComputerPuzzleIF.SignalQuestionsUpdated.Connect(SlotQuestionsUpdated, this);   
    ComputerPuzzleIF.SignalClose.Connect(SlotClose, this);
	
	ProjectUtils.SetMovieClipMask(m_TextArea, null, m_TextArea.m_Background._height, m_TextArea.m_Background._width, false);
    
	var moduleIF:GUIModuleIF = GUIModuleIF.FindModuleIF("GenericHideModule");
	moduleIF.SignalStatusChanged.Connect(SlotModuleStatusChanged, this);
	SlotModuleStatusChanged(moduleIF, moduleIF.IsActive());
	
	SlotTextUpdated();
	SlotQuestionsUpdated();
    
	Key.addListener(this);
	m_CloseButton.addEventListener("click", this, "CloseComputerPuzzle");
	
	m_Dragpoint.onPress = function()
	{
		_parent.startDrag();
	}
	m_Dragpoint.onRelease = function()
	{
		_parent.stopDrag();
	}
	m_Dragpoint.onReleaseOutside = function()
	{
		_parent.stopDrag();
	}
	_parent._x = Stage["visibleRect"].x + ((Stage["visibleRect"].width - _parent._width)/2);
	_parent._y = Stage["visibleRect"].y + ((Stage["visibleRect"].height - _parent._height)/2);
	
	Selection.setFocus(m_UserInputField.textField);
	g_FocusListener.onSetFocus = function(oldFocus, newFocus)
	{
		if (newFocus == m_UserInputField.textField)
		{
			//ProjectUtils.SetMovieClipMask(missionWindow, m_Window.m_Content, m_ContentSize.height);
			if (m_UserInputField.textField.text == INPUT_FIELD_HOLDER_TEXT)
			{
				m_UserInputField.textField.text = "";
			}
		}
        else if (newFocus == m_TextArea.textField)
        {
			if (m_UserInputField.textField.text == "")
			{
				m_UserInputField.textField.text = INPUT_FIELD_HOLDER_TEXT;
			}
        }
	}
	Selection.addListener( g_FocusListener );
	
	Character.SignalCharacterEnteredReticuleMode.Connect(SlotCharacterEnteredReticuleMode, this);
    m_Closing = false;
}

function SlotCharacterEnteredReticuleMode():Void
{
    if (!m_Closing)
    {
        CloseComputerPuzzle();
    }
}

function SlotClose():Void
{
    if (!m_Closing)
    {
        CloseComputerPuzzle();
    }
}

function CheckTextArea():Void
{
    if (m_TextArea.textField._height > m_TextArea.m_Background._height)
    {
        m_TextArea.textField._width = TEXT_AREA_WIDTH - m_TextArea.m_ArrowUp._width;   
        m_TextArea.m_ArrowUp._visible = m_TextArea.m_ArrowDown._visible = true;
        
        if (m_TextArea.textField._y >= m_TextArea.m_Background._y)
        {
            m_TextArea.m_ArrowUp._visible = false;
        }
        else if (m_TextArea.textField._y + m_TextArea.textField._height <= m_TextArea.m_Background._y + m_TextArea.m_Background._height)
        {
            m_TextArea.m_ArrowDown._visible = false;
        }
    }
    else
    {
        m_TextArea.textField._y = 0;
        m_TextArea.textField._width = TEXT_AREA_WIDTH;
        m_TextArea.m_ArrowUp._visible = m_TextArea.m_ArrowDown._visible = false;
    }
    m_TextArea.textField.selectable = true;
}

// Setting skin
function SetLayout(layout:String):Void
{
    if (m_SkinParent.m_Skin)	// If some skin already here, remove it
    {
        m_Skin.removeMovieClip();
        m_SkinParent.m_Skin = undefined;
    }
	switch (layout)
	{
		case ILLUMINATI_SKIN:
			m_CurrentTextColor = TEXT_COLOR_ILLUMINATI;
			m_TextArea.textField.textColor = m_CurrentTextColor;
			m_Title.textField.textColor = m_CurrentTextColor;
			m_KeyHintAlt.textField.textColor = m_CurrentTextColor;
			m_KeyHintCtrl.textField.textColor = m_CurrentTextColor;
			m_UserInputField.textField.textColor = m_CurrentTextColor;
			m_CommandPrompt.textField.textColor = m_CurrentTextColor;
			m_ArrowUpColor.setRGB(m_CurrentTextColor);
			m_ArrowDownColor.setRGB(m_CurrentTextColor);
			m_SkinParent.attachMovie("BackgroundIlluminati","m_Skin",m_SkinParent.getNextHighestDepth());
			break;
		case TEMPLARS_SKIN:
			m_CurrentTextColor = TEXT_COLOR_TEMPLARS;
			m_TextArea.textField.textColor = m_CurrentTextColor;
			m_Title.textField.textColor = m_CurrentTextColor;
			m_KeyHintAlt.textField.textColor = m_CurrentTextColor;
			m_KeyHintCtrl.textField.textColor = m_CurrentTextColor;
			m_UserInputField.textField.textColor = m_CurrentTextColor;
			m_CommandPrompt.textField.textColor = m_CurrentTextColor;
			m_ArrowUpColor.setRGB(m_CurrentTextColor);
			m_ArrowDownColor.setRGB(m_CurrentTextColor);
			m_SkinParent.attachMovie("BackgroundTemplars","m_Skin",m_SkinParent.getNextHighestDepth());
			break;
		case DRAGON_SKIN:
			m_CurrentTextColor = TEXT_COLOR_DRAGON;
			m_TextArea.textField.textColor = m_CurrentTextColor;
			m_Title.textField.textColor = m_CurrentTextColor;
			m_KeyHintAlt.textField.textColor = m_CurrentTextColor;
			m_KeyHintCtrl.textField.textColor = m_CurrentTextColor;
			m_UserInputField.textField.textColor = m_CurrentTextColor;
			m_CommandPrompt.textField.textColor = m_CurrentTextColor;
			m_ArrowUpColor.setRGB(m_CurrentTextColor);
			m_ArrowDownColor.setRGB(m_CurrentTextColor);
			m_SkinParent.attachMovie("BackgroundDragon","m_Skin",m_SkinParent.getNextHighestDepth());
			break;
		case VALENTINE_SKIN:
			m_CurrentTextColor = TEXT_COLOR_VALENTIN;
			m_TextArea.textField.textColor = m_CurrentTextColor;
			m_Title.textField.textColor = m_CurrentTextColor;
			m_KeyHintAlt.textField.textColor = m_CurrentTextColor;
			m_KeyHintCtrl.textField.textColor = m_CurrentTextColor;
			m_UserInputField.textField.textColor = m_CurrentTextColor;
			m_CommandPrompt.textField.textColor = m_CurrentTextColor;
			m_ArrowUpColor.setRGB(m_CurrentTextColor);
			m_ArrowDownColor.setRGB(m_CurrentTextColor);
			m_SkinParent.attachMovie("BackgroundValentin","m_Skin",m_SkinParent.getNextHighestDepth());
			break;
		case STANDARD_SKIN:
			m_CurrentTextColor = TEXT_COLOR_STANDARD;
			m_TextArea.textField.textColor = m_CurrentTextColor;
			m_Title.textField.textColor = m_CurrentTextColor;
			m_KeyHintAlt.textField.textColor = m_CurrentTextColor;
			m_KeyHintCtrl.textField.textColor = m_CurrentTextColor;
			m_UserInputField.textField.textColor = m_CurrentTextColor;
			m_CommandPrompt.textField.textColor = m_CurrentTextColor;
			m_ArrowUpColor.setRGB(m_CurrentTextColor);
			m_ArrowDownColor.setRGB(m_CurrentTextColor);
			m_SkinParent.attachMovie("SkinBase","m_Skin",m_SkinParent.getNextHighestDepth());
			break;
		default:
			break;
	}
}

// On Key Down
function onKeyDown()
{        
    var scanCode:Number = Key.getCode();   
    if (scanCode == 13) // ENTER 
    {
        Log.Info2("ComputerPuzzle", "Player input '" + m_UserInputField.textField.text + "' accepted and sent to server.");   
        var success:Boolean = ComputerPuzzleIF.AcceptPlayerInput(m_UserInputField.textField.text);
        if (m_Character != undefined)
        {
            if (success)
            {
                m_Character.AddEffectPackage( "sound_fxpackage_GUI_computer_entry_success.xml" );
            }
            else
            {
                m_Character.AddEffectPackage( "sound_fxpackage_GUI_computer_entry_fail.xml" );
            }
        }
        Selection.setFocus(m_UserInputField.textField);
        m_UserInputField.textField.text = "";
    }
    else if (scanCode == 27) // ESC
    {
        SlotClose();
    }
	else if (scanCode == 33 || scanCode == 38) // PageUp or Arrow Up
	{
		if (m_TextArea.m_ArrowUp._visible)
		{
			m_TextArea.textField._y += TEXT_AREA_LINE_HEIGHT;
			CheckTextArea();
		}
	}
	else if (scanCode == 34 || scanCode == 40) // PageDown or Arrow Down
	{
		if (m_TextArea.m_ArrowDown._visible)
		{
			m_TextArea.textField._y -= TEXT_AREA_LINE_HEIGHT;
			CheckTextArea();
		}
	}
	else if (Key.isDown(18) && !Key.isDown(17)) // Alt (check for Ctrl not pressed in the same time)
	{
		m_KeyHintAlt._visible = true;
		switch (scanCode)
		{
			case 82: // R
				ComputerPuzzleIF.AcceptPlayerInput("root");
				break;
			case 72: // H
				ComputerPuzzleIF.AcceptPlayerInput("hint");
				break;
			case 76: // L
				ComputerPuzzleIF.AcceptPlayerInput("help");
				break;
			case 81: // Q
				ComputerPuzzleIF.AcceptPlayerInput("quit");
				break;
			default:
				break;
		}
	}
	else if (Key.isDown(17) && !Key.isDown(18)) // Ctrl (check for Alt not pressed at the same time)
	{
		m_KeyHintCtrl._visible = true;
		switch (scanCode)
		{
			case 68: // D
				this.SetLayout(DRAGON_SKIN);
				m_SkinSaved.SetValue("Dragon");
				break;
			case 73: // I
				this.SetLayout(ILLUMINATI_SKIN);
				m_SkinSaved.SetValue("Illuminati");
				break;
			case 84: // T
				this.SetLayout(TEMPLARS_SKIN);
				m_SkinSaved.SetValue("Templars");
				break;
			case 76: // L
				this.SetLayout(VALENTINE_SKIN);
				m_SkinSaved.SetValue("Valentine");
				break;
			case 83: // S
				this.SetLayout(STANDARD_SKIN);
				m_SkinSaved.SetValue("Default");
				break;
			default:
				break;
		}
	}
}

// On Key Up
function onKeyUp():Void
{    
    if (!Key.isDown(17)) // Ctrl
	{
		m_KeyHintCtrl._visible = false;
	}
	if (!Key.isDown(18)) // Alt
	{
		m_KeyHintAlt._visible = false;
	}
	if (Selection.getFocus() == m_TextArea.textField)
    {
        SlotTextUpdated();
        SlotQuestionsUpdated();
    }
}

// Slot Module Status Changed
function SlotModuleStatusChanged( module:GUIModuleIF, isActive:Boolean )
{
    _visible = isActive;
}

// Slot Text Updated
function SlotTextUpdated() : Void
{
    m_TextArea.textField._y = 0;
	m_TextArea.textField._width = TEXT_AREA_WIDTH;
	m_TextArea.m_ArrowUp._visible = m_TextArea.m_ArrowDown._visible = false;
	m_TextArea.textField.htmlText = ComputerPuzzleIF.GetText();
	m_TextArea.textField.textColor = m_CurrentTextColor;
	CheckTextArea();
}

// Slot Questions Updated
function SlotQuestionsUpdated() : Void
{    
	var questions:Array = ComputerPuzzleIF.GetQuestions();
    
    for (i:Number = 0; i < questions.length; ++i)
    {
        Log.Info1("ComputerPuzzle", "Command " + i + ": '" + questions[i] + "'");
    }
	CheckTextArea();
}

// On Unload
function onUnload()
{
    Log.Info2("ComputerPuzzle", "onUnload()");    
    Key.removeListener(this);    
}

// Resize Handler (why it's here, we can't resize this?)
function ResizeHandler() : Void
{
    var visibleRect:flash.geom.Rectangle = Stage["visibleRect"];

    _y = visibleRect.y;
    _x = visibleRect.x;
    m_HalfWidth = visibleRect.width / 2;
}

// Close Computer Puzzle
function CloseComputerPuzzle() : Void
{
    m_Closing = true;
	_parent.UnloadClip();
	ComputerPuzzleIF.Close();
}