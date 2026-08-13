extends Node
#class_name SettingsManager

var match_settings    := MatchSettings.new()
var personal_settings := PersonalSettings.new()
var peer_settings     :  Dictionary = {}

class PeerSettings:
   var dummy: Dummy
   var name_tag: String
   var primary_color: Color
   var secondary_color: Color
   
   func _init(peer_dummy: Dummy, peer_name_tag: String, peer_primary_color: Color, peer_secondary_color: Color) -> void:
      dummy           = peer_dummy
      name_tag        = peer_name_tag
      primary_color   = peer_primary_color
      secondary_color = peer_secondary_color
