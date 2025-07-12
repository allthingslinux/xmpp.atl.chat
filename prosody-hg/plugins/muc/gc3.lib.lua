
local jid_bare = require "prosody.util.jid".bare;

local st = require "prosody.util.stanza";

local muc_util = module:require "muc/util";
local valid_affiliations = muc_util.valid_affiliations;

local xmlns_gc3 = "urn:xmpp:gc3:tmp"

--luacheck: ignore 113/get_room_from_jid

function fetch_participant_list(room, stanza, origin)
	local from_jid = stanza.attr.from;
	local from_aff = room:get_affiliation(from_jid);
	local from_rank = valid_affiliations[from_aff or "none"];

	local required_aff_rank = valid_affiliations[room:get_members_only() and "member" or "none"];
	if from_rank < required_aff_rank then
		origin.send(st.error_reply(stanza, "auth", "forbidden"));
		return true;
	end

	local can_see_real_jids = not room:is_anonymous_for(from_jid);

	local reply = st.reply(stanza)
		:tag("participants", { xmlns = xmlns_gc3 });

	for jid, aff in room:each_affiliation() do
		local nick = room:get_registered_nick(jid);
		local visible_jid = can_see_real_jids and jid or nil;
		reply:text_tag("item", nil, {
			affiliation = aff;
			jid = visible_jid;
			nick = nick;
			id = room:get_occupant_id_from_jid(jid);
		});
	end

	origin.send(reply);
	return true;
end

local function room_event_handler(handler, allow_nonexistent)
	return function (event)
		local origin, stanza = event.origin, event.stanza;
		local room_jid = jid_bare(stanza.attr.to);
		local room = get_room_from_jid(room_jid);
		if not room and allow_nonexistent ~= true then
			origin.send(st.error_reply(stanza, "cancel", "item-not-found"));
			return true;
		end
		return handler(room, stanza, origin);
	end;
end

module:hook("iq-get/bare/"..xmlns_gc3..":participants", room_event_handler(fetch_participant_list));
