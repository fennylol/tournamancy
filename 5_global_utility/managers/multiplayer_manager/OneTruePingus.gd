extends Node
class_name OneTruePingus
# ========= #
# constants #
# ========= #
enum  PingusStates {NOT_STARTED, INFORMING, CONNECTED}
enum  PingusTypes {INFORM = 0x1EF0, KEEPALIVE = 0x8EE9, DATA = 0xDA7A}
enum  DataTypes   {CONTROL = 0xC0} # the rest should be user defined types
const TYPE_SIZE      : int   = 2
const ID_SIZE        : int   = 4
# header layout: [pkt_type u32][sender NetworkID u32][target NetworkID u32].
# target 0 means "anyone" (manual connects, before the peer's ID is known).
const HEADER_SIZE    : int   = TYPE_SIZE + ID_SIZE + ID_SIZE
const DATA_TYPE_SIZE : int   = 1
const RETRY_TIME     : float = 2.5
const MAX_RETRIES    : int   = 5
const KEEP_ALIVE_TIME: float = 5.0
# ========= #
# variables #
# ========= #
var Udp         : PacketPeerUDP = PacketPeerUDP.new()
var PingusState : PingusStates  = PingusStates.NOT_STARTED
var PingusTimer : float         = -1
var TargetAddr  : String        = "":
   set(NewAddress):
      var regex = RegEx.new()
      regex.compile("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
      var result = regex.search(NewAddress)
      if result: TargetAddr = NewAddress
var TargetPort  : int           = -1:
   set(NewPort):
      var regex = RegEx.new()
      regex.compile("^(0|[1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$")
      var result = regex.search(str(NewPort))
      if result: TargetPort = NewPort
var TargetID    : int           = 0
var ExternAddr  : String        = "":
   set(NewAddress):
      var regex = RegEx.new()
      regex.compile("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
      var result = regex.search(NewAddress)
      if result: ExternAddr = NewAddress
var ExternPort  : int           = -1:
   set(NewPort):
      var regex = RegEx.new()
      regex.compile("^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$")
      var result = regex.search(str(NewPort))
      if result: ExternPort = NewPort
var NetworkID   : int           = 0
var SprayRate   : int           = 100
# ======= #
# signals #
# ======= #
signal recieved_data(sender_id: int, data_type: int, data: PackedByteArray)
signal connection_established(sender_id: int)

func _ready() -> void:
   var bind_err = Udp.bind(0)
   if bind_err != OK: _emit_control("ERROR: OneTruePingus failed to bind UDP socket"); return
func _init(external_address: String = "", network_id: int = 0) -> void:
   NetworkID = network_id
   ExternAddr = external_address
   if NetworkID  == 0 : _discover_network_id()
   if ExternAddr == "": _discover_address()   
func _discover_network_id() -> void:
   while NetworkID == 0:
      seed((Time.get_unix_time_from_system()*100000) as int)
      NetworkID = randi()
func _discover_address() -> void:
   var ag := AddressGopher.new()
   ag.info_fetching_complete.connect(
      func(result: AddressGopher.InfoFetchingResults, address: String = "", port: int = 0):
         var retry_on_fail: Callable = func(err_str: String):
            PingusTimer += 1
            if PingusTimer < MAX_RETRIES:
               _emit_control(err_str + " Retrying... ")
               await get_tree().create_timer(RETRY_TIME).timeout
               ag.attempt_info_fetch()
            else:
               _emit_control(err_str + " Aborting...")

         match result:
            AddressGopher.InfoFetchingResults.OK                      : _emit_control("External IP recieved: " + address + ":" + str(port)); ag.queue_free()
            AddressGopher.InfoFetchingResults.BAD_SERVER_LIST_RESULT  : retry_on_fail.call("BAD_SERVER_LIST_RESULT")
            AddressGopher.InfoFetchingResults.BAD_SERVER_LIST_RESPONSE: retry_on_fail.call("BAD_SERVER_LIST_RESPONSE")
            AddressGopher.InfoFetchingResults.BAD_SERVER_LIST_DATA    : retry_on_fail.call("BAD_SERVER_LIST_DATA")
            AddressGopher.InfoFetchingResults.BAD_STUN_RESULT         : retry_on_fail.call("BAD_STUN_RESULT")
            AddressGopher.InfoFetchingResults.BAD_STUN_RESPONSE       : retry_on_fail.call("BAD_STUN_RESPONSE")
            AddressGopher.InfoFetchingResults.BAD_STUN_DATA           : retry_on_fail.call("BAD_STUN_DATA")
   )
   ag.set_name("AddressGopher")
   add_child(ag)
# =================== #
# PingusState machine #
# =================== #
func _process(delta: float) -> void:
   if TargetAddr == "" or ExternAddr == "" or NetworkID == 0:
      if not PingusState == PingusStates.NOT_STARTED:
         PingusState = PingusStates.NOT_STARTED
         _emit_control("ERROR: Malformed %s: %s. Returning to NOT_STARTED..." % (["target IP address", "[NULL]"] if TargetAddr == "" else ["external IP address", "[NULL]"] if ExternAddr == "" else ["network ID", "0"] if NetworkID == 0 else ["error", "like... this one.."]))
   
   match PingusState:
      # NOT_STARTED:  the OneTruePingus has not begun attempting a connection.
      # -> INFORMING: once a target is set, it will begin spraying packets at
      # the target to establish a connection.
      PingusStates.NOT_STARTED:
         if TargetAddr != "" and TargetPort == -1 and ExternAddr != "" and NetworkID != 0:
            PingusState = PingusStates.INFORMING
            _emit_control("Attempting to connect to " + TargetAddr)
      # INFORMING: the OneTruePingus has a target set. it is sending
      # the target's port to the target.
      # -> CONNECTED: when an INFORM packet is recieved, the target is also
      # aware of the connection.
      PingusStates.INFORMING:
         _inform_pingus(delta)
         while Udp.get_available_packet_count() > 0:
            var pkt := Udp.get_packet()
            # packet validation
            if pkt.size() < HEADER_SIZE: _emit_control("ERROR: undersized packet while informing."); continue
            var pkt_type : PingusTypes = pkt.decode_u32(0) as PingusTypes
            var sender_id: int         = pkt.decode_u32(TYPE_SIZE)
            var target_id: int         = pkt.decode_u32(TYPE_SIZE + ID_SIZE)
            if pkt_type != PingusTypes.INFORM: _emit_control("ERROR: incorrect packet type while informing."); continue
            if sender_id == NetworkID: continue # one of our own sockets (same-machine instance)
            if TargetID  != 0 and sender_id != TargetID: continue # not the peer this connection is for
            if target_id != 0 and target_id != NetworkID: continue # meant for a different instance at our address
            # data collection
            if pkt_type == PingusTypes.INFORM:
               if PingusState == PingusStates.CONNECTED: continue
               if pkt.size() < HEADER_SIZE + 2: _emit_control("ERROR: INFORM packet too small for port."); continue
               ExternPort = pkt.decode_u16(HEADER_SIZE)
               PingusState = PingusStates.CONNECTED
               _emit_control("Established connection to " + str(sender_id) + " (" + TargetAddr + ":" + str(TargetPort) + ") from local port " + str(ExternPort), sender_id)
               connection_established.emit(sender_id)
      # CONNECTED: both the OneTruePingus and the target are aware of each other.
      # continually send pings to keep the connection alive.
      PingusStates.CONNECTED:
         PingusTimer += delta
         if PingusTimer >= KEEP_ALIVE_TIME:
            PingusTimer -= KEEP_ALIVE_TIME
            _timed_pingus()

         while Udp.get_available_packet_count() > 0:
            var pkt := Udp.get_packet()
            # packet validation
            if pkt.size() < HEADER_SIZE:
               _emit_control("ERROR: undersized packet while connected.")
               continue
            if Udp.get_packet_ip() != TargetAddr or Udp.get_packet_port() != TargetPort:
               _emit_control("ERROR: packet from unidentified source.")
               continue
            var pkt_type : PingusTypes = pkt.decode_u32(0) as PingusTypes
            var sender_id: int         = pkt.decode_u32(TYPE_SIZE)
            var target_id: int         = pkt.decode_u32(TYPE_SIZE + ID_SIZE)
            if sender_id != TargetID or (target_id != 0 and target_id != NetworkID):
               _emit_control("ERROR: packet signed by unidentified sender.")
               continue
            # data handling
            match pkt_type:
               PingusTypes.INFORM:    _emit_control(str(sender_id) + " (" + TargetAddr + ":" + str(TargetPort) + ") re-confirmed connection", sender_id) 
               PingusTypes.KEEPALIVE: _emit_control(str(sender_id) + " (" + TargetAddr + ":" + str(TargetPort) + ") is keeping connection alive", sender_id)
               PingusTypes.DATA:
                  if pkt.size() < HEADER_SIZE + DATA_TYPE_SIZE: _emit_control("ERROR: DATA packet missing type byte."); continue
                  recieved_data.emit(sender_id, pkt.decode_u8(HEADER_SIZE), pkt.slice(HEADER_SIZE + DATA_TYPE_SIZE))
                  PingusTimer = 0.0
               _: _emit_control("ERROR: incorrect packet type while connected.")
# ============== #
# packet sending #
# ============== #
## send typed application data. data_type is a single byte; values other than
## OneTruePingus.DataTypes.CONTROL (0xC0) are free for the application to define.
func send_data(data_type: int, data: PackedByteArray = PackedByteArray()) -> void:
   Udp.set_dest_address(TargetAddr, TargetPort)
   var pkt := _make_header(PingusTypes.DATA)
   pkt.resize(HEADER_SIZE + DATA_TYPE_SIZE)
   pkt.encode_u8(HEADER_SIZE, data_type)
   pkt.append_array(data)
   var send_err = Udp.put_packet(pkt)
   if send_err != OK: _emit_control("ERROR: failed to send data to " + TargetAddr + ":" + str(TargetPort))
func _make_header(pkt_type: PingusTypes) -> PackedByteArray:
   var hdr := PackedByteArray()
   hdr.resize(HEADER_SIZE)
   hdr.encode_u32(0, pkt_type)
   hdr.encode_u32(TYPE_SIZE, NetworkID)
   hdr.encode_u32(TYPE_SIZE + ID_SIZE, TargetID)
   return hdr
func _emit_control(msg: String, sender_id: int = 0) -> void:
   recieved_data.emit(sender_id if sender_id else NetworkID, DataTypes.CONTROL, msg.to_utf8_buffer())
# PingusStates.INFORMING
func _inform_pingus(delta) -> void:
   Udp.set_dest_address(TargetAddr, TargetPort)
   var count = ceili((SprayRate/5.0) * delta)
   while count > 0:
      count -= 1
      var pkt := _make_header(PingusTypes.INFORM)
      pkt.resize(HEADER_SIZE + 2)
      pkt.encode_u16(HEADER_SIZE, TargetPort)
      var send_err = Udp.put_packet(pkt)
      if send_err != OK: _emit_control("ERROR: failed to send inform to " + TargetAddr + ":" + str(TargetPort))
   _emit_control("Informing " + TargetAddr + " at port: " + str(TargetPort))
# PingusStates.CONNECTED
func _timed_pingus() -> void:
   Udp.set_dest_address(TargetAddr, TargetPort)
   var send_err = Udp.put_packet(_make_header(PingusTypes.KEEPALIVE))
   if send_err != OK: _emit_control("ERROR: failed to send keepalive to " + TargetAddr + ":" + str(TargetPort))
   else: _emit_control("Preventing timeout with " + TargetAddr + ":" + str(TargetPort))
# ======================== #
# small utility class to   #
# fetch external facing IP #
# ======================== #
class IPGopher extends Node:
   const  IP_FETCHING_URL = "https://api.ipify.org"
   enum   IpFetchingErrs {OK, BAD_RESULT, BAD_RESPONSE, BAD_IP}
   signal ip_fetching_finished(err: IpFetchingErrs)
   var    Address: PackedInt32Array

   func get_address()           -> PackedInt32Array: return Address
   func get_address_as_string() -> String: return str(Address[0])+"."+str(Address[1])+"."+str(Address[2])+"."+str(Address[3])
   func _ready()                -> void: _attempt_addr_fetch()
   func _attempt_addr_fetch()   -> void:
      var http_req := HTTPRequest.new()
      add_child(http_req)
      http_req.request_completed.connect(
         func(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
            if result        != HTTPRequest.Result.RESULT_SUCCESS  : ip_fetching_finished.emit(IpFetchingErrs.BAD_RESULT)  ; http_req.queue_free(); return
            if response_code != HTTPClient.ResponseCode.RESPONSE_OK: ip_fetching_finished.emit(IpFetchingErrs.BAD_RESPONSE); http_req.queue_free(); return
            var IP_str: PackedStringArray = body.get_string_from_utf8().split(".")
            if IP_str.size() != 4                                  : ip_fetching_finished.emit(IpFetchingErrs.BAD_IP)      ; http_req.queue_free(); return
            Address = PackedInt32Array([int(IP_str[0]), int(IP_str[1]), int(IP_str[2]), int(IP_str[3])])
            ip_fetching_finished.emit(IpFetchingErrs.OK)
            http_req.queue_free()
      )
      http_req.request(IP_FETCHING_URL)
# ============================= #
# medium utility class to fetch #
# external facing IP/port combo #
# ============================= #
class AddressGopher extends Node:
   enum InfoFetchingResults { OK, BAD_SERVER_LIST_RESULT, BAD_SERVER_LIST_RESPONSE, BAD_SERVER_LIST_DATA, BAD_STUN_RESULT, BAD_STUN_RESPONSE, BAD_STUN_DATA }
   signal info_fetching_complete(result: InfoFetchingResults, ip: String, port: int)

   const SERVER_LIST_URL  : String = "https://raw.githubusercontent.com/pradt2/always-online-stun/master/valid_hosts.txt"
   const MAGIC_COOKIE     : int    = 0x2112A442
   const DEFAULT_STUN_PORT: int    = 3478
   var   custom_stun_url  : String = ""

   func _init(custom_stun_server_addr: String = "") -> void: custom_stun_url = custom_stun_server_addr
   func _ready() -> void: attempt_info_fetch()
   func attempt_info_fetch() -> void:
      var stun_server_url: String = custom_stun_url
      if not stun_server_url: stun_server_url = await _fetch_stun_server_addr_from_github_repo()
      if not stun_server_url: return
      
      var parts := stun_server_url.rsplit(":", true, 1)
      var host: String  = parts[0]
      var port: int     = int(parts[1]) if parts.size() > 1 else DEFAULT_STUN_PORT
      print("STUN target: %s:%d" % [host, port])

      _stun_request(host, port)
      
   func _fetch_stun_server_addr_from_github_repo() -> String:
      var http := HTTPRequest.new()
      add_child(http)
      if http.request(SERVER_LIST_URL) != OK:
         info_fetching_complete.emit(InfoFetchingResults.BAD_SERVER_LIST_RESULT)
         http.queue_free()
         return ""

      var res: Array = await http.request_completed   # [result, code, headers, data]
      http.queue_free()
      var result: int = res[0]
      var code:   int = res[1]
      var data: PackedByteArray = res[3]

      if result != HTTPRequest.RESULT_SUCCESS: info_fetching_complete.emit(InfoFetchingResults.BAD_SERVER_LIST_RESULT);   return ""
      if code   != HTTPClient.RESPONSE_OK    : info_fetching_complete.emit(InfoFetchingResults.BAD_SERVER_LIST_RESPONSE); return ""

      var server_list = data.get_string_from_utf8().split("\n", false)  # false = drop empty lines
      if server_list.is_empty(): info_fetching_complete.emit(InfoFetchingResults.BAD_SERVER_LIST_DATA); return ""

      # 2) Pick a server and run a STUN binding request over UDP
      var entry: String = server_list[randi() % server_list.size()].strip_edges()
      return entry

   func _stun_request(host: String, port: int, timeout := 3.0) -> void:
      var ip: String = host
      if not host.is_valid_ip_address(): ip = IP.resolve_hostname(host, IP.TYPE_IPV4)
      if ip.is_empty(): info_fetching_complete.emit(InfoFetchingResults.BAD_STUN_RESULT); return

      var udp := PacketPeerUDP.new()
      if udp.connect_to_host(ip, port) != OK: info_fetching_complete.emit(InfoFetchingResults.BAD_STUN_RESULT); return

      var txn := PackedByteArray()
      for i in 12: txn.append(randi() & 0xFF)   # 12-byte transaction id

      udp.put_packet(_build_binding_request(txn))

      var elapsed := 0.0
      while elapsed < timeout:
         if udp.get_available_packet_count() > 0:
            var packet := udp.get_packet()
            udp.close()
            var parsed := _parse_stun_response(packet)
            if not parsed.success:
               info_fetching_complete.emit(InfoFetchingResults.BAD_STUN_DATA); return
            info_fetching_complete.emit(InfoFetchingResults.OK, parsed.ip, parsed.port)
            return
         await get_tree().create_timer(0.05).timeout
         elapsed += 0.05

      udp.close()
      info_fetching_complete.emit(InfoFetchingResults.BAD_STUN_RESPONSE)

   func _build_binding_request(txn: PackedByteArray) -> PackedByteArray:
      var buf := StreamPeerBuffer.new()
      buf.big_endian = true
      buf.put_u16(0x0001)        # Binding Request
      buf.put_u16(0x0000)        # message length: no attributes
      buf.put_u32(MAGIC_COOKIE)
      buf.put_data(txn)
      return buf.data_array

   func _parse_stun_response(resp: PackedByteArray) -> Dictionary:
      var fail := {"success": false, "ip": "", "port": 0}
      if resp.size() < 20: return fail

      var buf := StreamPeerBuffer.new()
      buf.data_array = resp
      buf.big_endian = true
      var msg_type := buf.get_u16()
      var _msg_len := buf.get_u16()
      var cookie   := buf.get_u32()
      if cookie != MAGIC_COOKIE or msg_type != 0x0101:   # 0x0101 = Binding Success
         return fail

      var pos := 20
      while pos + 4 <= resp.size():
         buf.seek(pos)
         var attr_type := buf.get_u16()
         var attr_len  := buf.get_u16()
         var val := pos + 4
         if   attr_type == 0x0020: return _decode_addr(resp, val, true)   # XOR-MAPPED-ADDRESS
         elif attr_type == 0x0001: return _decode_addr(resp, val, false)  # MAPPED-ADDRESS (legacy)
         pos = val + attr_len
         if attr_len % 4 != 0: pos += 4 - (attr_len % 4)   # attrs are 4-byte padded
      return fail

   func _decode_addr(resp: PackedByteArray, i: int, xored: bool) -> Dictionary:
      var family := resp[i + 1]
      if family != 0x01: return {"success": false, "ip": "", "port": 0}   # IPv4 only here
      var raw_port := (resp[i + 2] << 8) | resp[i + 3]
      var port := raw_port ^ (MAGIC_COOKIE >> 16) if xored else raw_port  # XOR with 0x2112
      var ck := [0x21, 0x12, 0xA4, 0x42]
      var o := []
      for k in 4:
         o.append((resp[i + 4 + k] ^ ck[k]) if xored else resp[i + 4 + k])
      return {"success": true, "ip": "%d.%d.%d.%d" % o, "port": port}
