import com.Utils.Faction;
import com.GameInterface.Game.Character;
import com.GameInterface.DistributedValue;

var m_ComputerInterfaceWindow:MovieClip;

// On Load
function LoadArgumentsReceived(args:Array):Void
{
    var skin:String = this[args[0]];
	var m_ACTSkin:DistributedValue = DistributedValue.Create("ComputerPuzzleSkin");
	var m_SavedSkin:String = m_ACTSkin.GetValue();
	
	if (skin == "Dragon" || skin == "Illuminati" || skin == "Templars" || skin == "Valentine")
	{
		m_ComputerInterfaceWindow.SetLayout(skin);
	}
	else if (m_SavedSkin == "Dragon" || m_SavedSkin == "Illuminati" || m_SavedSkin == "Templars" || m_SavedSkin == "Valentine" || m_SavedSkin == "Default")
	{
		m_ComputerInterfaceWindow.SetLayout(m_SavedSkin);
	}
	else
	{
		var m_Char = Character.GetClientCharacter();
		var m_PlayerFaction:String = Faction.GetFactionNameNonLocalized(m_Char.GetStat( _global.Enums.Stat.e_PlayerFaction ));
		switch (m_PlayerFaction)
		{
			case "dragon":
				m_ComputerInterfaceWindow.SetLayout("Dragon");
				break;
			case "illuminati":
				m_ComputerInterfaceWindow.SetLayout("Illuminati");
				break;
			case "templar":
				m_ComputerInterfaceWindow.SetLayout("Templars");
				break;
			default:
				m_ComputerInterfaceWindow.SetLayout("Default");
				break;
		}
	}
}