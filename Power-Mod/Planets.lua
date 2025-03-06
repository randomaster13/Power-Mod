--local discover_all = true

local planet_atlas = SMODS.Atlas{
    key = 'planets',
    px = 71,
    py = 95,
    path = 'Planets.png',
}

local p_empty_sky = SMODS.Consumable{
    --object_type = "Consumable",
	key = "p_empty_sky",
	loc_txt = {
        name = 'Empty Sky',
		text = {
            'Better description goes here',
        },
	},
    order = 24,
    discovered = true,
    cost = 4,
    consumeable = true,
    freq = 1,
    pos = {
        x=1,
        y=0,
    },
    set = "Planet",
    atlas = "planets",
    --effect = "Hand Upgrade",
    cost_mult = 1.0,
	can_use = function(self, card)
		return true
	end,
    config = {
        hand_types = {"High Card"}
    },
    loc_vars = function(self, info_queue, center)
		return { vars = { (G.GAME) } }
	end,
	use = function(self, card, area, copier)
		local used_consumable = copier or card
		update_hand_text(
			{ sound = "button", volume = 0.7, pitch = 0.8, delay = 0.3 },
			{ handname = localize("k_all_hands"), chips = "...", mult = "...", level = "" }
		)
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.2,
			func = function()
				play_sound("tarot1")
				used_consumable:juice_up(0.8, 0.5)
				G.TAROT_INTERRUPT_PULSE = true
				return true
			end,
		}))
		update_hand_text({ delay = 0 }, { mult = "+", StatusText = true })
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.9,
			func = function()
				play_sound("tarot1")
				used_consumable:juice_up(0.8, 0.5)
				return true
			end,
		}))
		update_hand_text({ delay = 0 }, { chips = "+", StatusText = true })
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.9,
			func = function()
				play_sound("tarot1")
				used_consumable:juice_up(0.8, 0.5)
				G.TAROT_INTERRUPT_PULSE = nil
				return true
			end,
		}))
		update_hand_text({ sound = "button", volume = 0.7, pitch = 0.9, delay = 0 }, { level = "+3" })
		delay(1.3)
		for k, v in pairs(G.GAME.hands) do
			level_up_hand(used_consumable, k, true, 2)
		end
		update_hand_text(
			{ sound = "button", volume = 0.7, pitch = 1.1, delay = 0 },
			{ mult = 0, chips = 0, handname = "", level = "" }
		)
	end,
	calculate = function(self, card, context)
		if
			G.GAME.used_vouchers.v_observatory
			and (
				context.scoring_name == "High Card"
			)
		then
			local value = G.P_CENTERS.v_observatory.config.extra
			return {
				message = localize({ type = "variable", key = "a_xmult", vars = { value } }),
				Xmult_mod = value,
			}
		end
	end,
}



local p_planet = SMODS.Consumable{
    --object_type = "Consumable",
	key = "p_planet",
	loc_txt = {
        name = 'Planet',
		text = {
            'Choose which hand to upgrade',
			'and the ammount to upgrade it.'
        },
	},
    order = 25,
    discovered = true,
    cost = 4,
    consumeable = true,
    freq = 1,
    pos = {
        x=2,
        y=0,
    },
    set = "Planet",
    atlas = "planets",
    --effect = "Hand Upgrade",
    cost_mult = 2.0,
	can_use = function(self, card)
		return true
	end,
    loc_vars = function(self, info_queue, center)
		return { vars = { (G.GAME) } }
	end,
	use = function(self, card, area, copier)
		-- have to add both ENTERED_HAND & ENTERED_NUM here because I don't know how to nest uis and send variables from one to another.
		G.GAME.USING_CODE = true
		G.ENTERED_HAND = ""
		G.ENTERED_NUM = ""
		G.CHOOSE_HAND = UIBox({
			definition = create_UIBox_Planet(card),
			config = {
				align = "cm",
				offset = { x = 0, y = 10 },
				major = G.ROOM_ATTACH,
				bond = "Weak",
				instance_type = "POPUP",
			},
		})
		G.CHOOSE_HAND.alignment.offset.y = 0
		G.ROOM.jiggle = G.ROOM.jiggle + 1
		G.CHOOSE_HAND:align_to_major()
	end,
	calculate = function(self, card, context)
		if
			G.GAME.used_vouchers.v_observatory
		then
			local value = G.P_CENTERS.v_observatory.config.extra
			return {
				message = localize({ type = "variable", key = "a_xmult", vars = { value } }),
				Xmult_mod = value,
			}
		end
	end,
}

function create_UIBox_Planet(card)
	G.E_MANAGER:add_event(Event({
		blockable = false,
		func = function()
			G.REFRESH_ALERTS = true
			return true
		end,
	}))
	local t = create_UIBox_generic_options({
		no_back = true,
		colour = HEX("04200c"),
		outline_colour = HEX("2babc4"),
		contents = {
			{
				n = G.UIT.R,
				nodes = {
					create_text_input({
						colour = HEX("2babc4"),
						hooked_colour = darken(HEX("2babc4"), 0.3),
						w = 4.5,
						h = 1,
						max_length = 24,
						extended_corpus = true,
						prompt_text = "ENTER POKER HAND",
						ref_table = G,
						ref_value = "ENTERED_HAND",
						keyboard_offset = 1,
					}),
				},
			},
			{
				--second input
				n = G.UIT.R,
				nodes = {
					create_text_input({
						colour = HEX("2babc4"),
						hooked_colour = darken(HEX("2babc4"), 0.3),
						w = 4.5,
						h = 1,
						max_length = 24,
						extended_corpus = true,
						prompt_text = "ENTER NUMBER OF UPGRADES",
						ref_table = G,
						ref_value = "ENTERED_NUM",
						keyboard_offset = 1,
					}),
				},
			},
			{
				n = G.UIT.R,
				nodes = {
					UIBox_button({
						colour = HEX("2babc4"),
						button = "planet_apply",
						label = { "UPGRADE" },
						minw = 4.5,
						focus_args = { snap_to = true },
					}),
				},
			},
			{
				n = G.UIT.R,
				nodes = {
					UIBox_button({
						colour = G.C.RED,
						button = "planet_apply_previous",
						label = { "APPLY PREVIOUS" },
						minw = 4.5,
						focus_args = { snap_to = true },
					}),
				},
			},
			{
				n = G.UIT.R,
				nodes = {
					UIBox_button({
						colour = G.C.RED,
						button = "planet_cancel",
						label = { "CANCEL" },
						minw = 4.5,
						focus_args = { snap_to = true },
					}),
				},
			},
		},
	})
	return t
end

-- function create_UIBox_Planet_Num(current_hand)
-- 	G.E_MANAGER:add_event(Event({
-- 		blockable = false,
-- 		func = function()
-- 			G.REFRESH_ALERTS = true
-- 			return true
-- 		end,
-- 	}))
-- 	local tu = create_UIBox_generic_options({
-- 		no_back = true,
-- 		colour = HEX("04200c"),
-- 		outline_colour = HEX("2babc4"),
-- 		contents = {
-- 			{
-- 				n = G.UIT.R,
-- 				nodes = {
-- 					create_text_input({
-- 						colour = HEX("2babc4"),
-- 						hooked_colour = darken(HEX("2babc4"), 0.3),
-- 						w = 4.5,
-- 						h = 1,
-- 						max_length = 24,
-- 						extended_corpus = true,
-- 						prompt_text = "ENTER NUMBER OF UPGRADES",
-- 						ref_table = G,
-- 						ref_value = "ENTERED_NUM",
-- 						keyboard_offset = 1,
-- 					}),
-- 				},
-- 			},
-- 			{
-- 				n = G.UIT.R,
-- 				nodes = {
-- 					UIBox_button({
-- 						colour = HEX("2babc4"),
-- 						button = "planet_num_apply",
-- 						label = { "APPLY" },
-- 						minw = 4.5,
-- 						focus_args = { snap_to = true },
-- 					}),
-- 				},
-- 			},
-- 			{
-- 				n = G.UIT.R,
-- 				nodes = {
-- 					UIBox_button({
-- 						colour = G.C.RED,
-- 						button = "planet_num_apply_previous",
-- 						label = { "APPLY PREVIOUS" },
-- 						minw = 4.5,
-- 						focus_args = { snap_to = true },
-- 					}),
-- 				},
-- 			},
-- 			{
-- 				n = G.UIT.R,
-- 				nodes = {
-- 					UIBox_button({
-- 						colour = G.C.RED,
-- 						button = "planet_num_cancel",
-- 						label = { "CANCEL" },
-- 						minw = 4.5,
-- 						focus_args = { snap_to = true },
-- 					}),
-- 				},
-- 			},
-- 		},
-- 	})
-- 	return tu
-- end

G.FUNCS.planet_apply_previous = function()
	if G.PREVIOUS_ENTERED_HAND then
		G.ENTERED_HAND = G.PREVIOUS_ENTERED_HAND or ""
	end
	G.FUNCS.planet_apply()
end
G.FUNCS.planet_apply = function()
	local hand_table = {
		["High Card"] = { "high card", "high", "1oak", "1 of a kind", "haha one" },
		["Pair"] = { "pair", "2oak", "2 of a kind", "m" },
		["Two Pair"] = { "two pair", "2 pair", "mm" },
		["Three of a Kind"] = { "three of a kind", "3 of a kind", "3oak", "trips", "triangle" },
		["Straight"] = { "straight", "lesbian", "gay", "bisexual", "asexual" },
		["Flush"] = { "flush", "skibidi", "toilet", "floosh" },
		["Full House"] = { "full house", "full", "that 70s show", "modern family", "family matters", "the middle" },
		["Four of a Kind"] = { "four of a kind", "4 of a kind", "4oak", "22oakoak", "quads", "four to the floor" },
		["Straight Flush"] = { "straight flush", "strush", "slush", "slushie", "slushy" },
		["Five of a Kind"] = { "five of a kind", "5 of a kind", "5oak", "quints" },
		["Flush House"] = { "flush house", "flouse", "outhouse" },
		["Flush Five"] = { "flush five", "fish", "you know what that means", "five of a flush" },
		["cry_Bulwark"] = { "bulwark", "flush rock", "stoned", "stone flush", "flush stone" },
		["cry_Clusterfuck"] = { "clusterfuck", "fuck", "wtf" },
		["cry_UltPair"] = { "ultimate pair", "ultpair", "ult pair", "pairpairpair" },
		["cry_WholeDeck"] = { "the entire fucking deck", "deck", "tefd", "fifty-two", "you are fuck deck" },
	}
	local current_hand = nil
	for k, v in pairs(SMODS.PokerHands) do
		local index = v.key
		local current_name = G.localization.misc.poker_hands[index]
		if not hand_table[v.key] then
			hand_table[v.key] = { current_name }
		end
	end
	for i, v in pairs(hand_table) do
		for j, k in pairs(v) do
			if string.lower(G.ENTERED_HAND) == string.lower(k) then
				current_hand = i
			end
		end
	end
	if current_hand and G.GAME.hands[current_hand].visible then
		G.PREVIOUS_ENTERED_HAND = G.ENTERED_HAND
		
		--this takes an extremely short amount of time to display, should probably fix that but I don't really care that much ¯\_(ツ)_/¯
		update_hand_text(
			{ sound = "button", volume = 0.7, pitch = 0.8, delay = 0.5 },
			{
				handname = localize(current_hand, "poker_hands"),
				chips = G.GAME.hands[current_hand].chips,
				mult = G.GAME.hands[current_hand].mult,
				level = G.GAME.hands[current_hand].level,
			}
		)
		local num = tonumber(G.ENTERED_NUM)

		level_up_hand(nil, current_hand, true, num)
		update_hand_text(
			{ sound = "button", volume = 0.7, pitch = 1.1, delay = 0.3 },
			{ mult = 0, chips = 0, handname = "", level = "" }
		)
		G.FUNCS.planet_cancel()
		return
	end
end

G.FUNCS.planet_cancel = function()
	G.CHOOSE_HAND:remove()
	G.GAME.USING_CODE = false
end



-- G.FUNCS.planet_num_apply_previous = function(current_hand)
-- 	if G.PREVIOUS_ENTERED_NUM then
-- 		G.ENTERED_NUM = G.PREVIOUS_ENTERED_NUM or ""
-- 	end
-- 	G.FUNCS.planet_num_apply(current_hand)
-- end
-- --Reason this does not work is because level_up_hand is called before this can trigger and return Entered Num, need to find a way to either make the previous function 
-- --wait or get current_hand here.
-- G.FUNCS.planet_num_apply = function(current_hand)
-- 	local entered_num = tonumber(G.ENTERED_NUM)
-- 	G.PREVIOUS_ENTERED_NUM = G.ENTERED_NUM
-- 	print(entered_num)

-- 	G.FUNCS.planet_num_cancel()
-- 	return G.ENTERED_NUM
-- end

-- G.FUNCS.planet_num_cancel = function()
-- 	G.CHOOSE_NUM:remove()
-- 	G.GAME.USING_CODE = false
-- end

local mod_path = "" .. SMODS.current_mod.path

--local planet_cards = { empty_sky }

-- if not (SMODS.Mods["jen"] or {}).can_load then
-- end

-- return { name = "Planets", init = function() end, items = planet_cards }