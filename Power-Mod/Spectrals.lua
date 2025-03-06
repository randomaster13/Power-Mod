local spectral_atlas = SMODS.Atlas{
    key = 'spectrals',
    px = 71,
    py = 95,
    path = 'Spectrals.png',
}

local p_planet = SMODS.Consumable{
    --object_type = "Consumable",
	key = "Voucherless",
	loc_txt = {
        name = 'Voucherless',
		text = {
            'Removes all Vouchers.',
        },
	},
    order = 0,
    discovered = true,
    cost = 4,
    consumeable = true,
    freq = 0,
    pos = {
        x=1,
        y=0,
    },
    set = "Spectral",
    atlas = "Spectrals",
    cost_mult = 0.5,
	can_use = function(self, card)
		local usable_count = 0
		for _, v in pairs(G.GAME.used_vouchers) do
			if v then
				usable_count = usable_count + 1
			end
		end
		if usable_count > 0 then
			return true
		else
			return false
		end
	end,
    loc_vars = function(self, info_queue, center)
		return { vars = { (G.GAME) } }
	end,
	use = function(self, card, area, copier)
        local used_consumable = copier or card
		local usable_vouchers = {}
		for k, _ in pairs(G.GAME.used_vouchers) do
			local can_use = true
			for kk, __ in pairs(G.GAME.used_vouchers) do
				local v = G.P_CENTERS[kk]
				if v.requires then
					for _, vv in pairs(v.requires) do
						if vv == k then
							can_use = false
							break
						end
					end
				end
			end
			if can_use then
				usable_vouchers[#usable_vouchers + 1] = k
			end
		end
		local unredeemed_voucher = pseudorandom_element(usable_vouchers, pseudoseed("cry_trade"))
		--redeem extra voucher code based on Betmma's Vouchers
		local area
		if G.STATE == G.STATES.HAND_PLAYED then
			if not G.redeemed_vouchers_during_hand then
				G.redeemed_vouchers_during_hand =
					CardArea(G.play.T.x, G.play.T.y, G.play.T.w, G.play.T.h, { type = "play", card_limit = 5 })
			end
			area = G.redeemed_vouchers_during_hand
		else
			area = G.play
		end
		local card = create_card("Voucher", area, nil, nil, nil, nil, unredeemed_voucher)

		if G.GAME.voucher_edition_index[card.ability.name] then
			local edition = cry_edition_to_table(G.GAME.voucher_edition_index[card.ability.name])
			if edition then
				card:set_edition(edition, true, true)
			end
		end
		if G.GAME.voucher_sticker_index.eternal[card.ability.name] then
			card:set_eternal(true)
			card.ability.eternal = true
		end
		if G.GAME.voucher_sticker_index.perishable[card.ability.name] then
			card:set_perishable(true)
			card.ability.perish_tally = G.GAME.voucher_sticker_index.perishable[card.ability.name]
			card.ability.perishable = true
			if G.GAME.voucher_sticker_index.perishable[card.ability.name] == 0 then
				card.debuff = true
			end
		end
		if G.GAME.voucher_sticker_index.rental[card.ability.name] then
			card:set_rental(true)
			card.ability.rental = true
		end
		if G.GAME.voucher_sticker_index.pinned[card.ability.name] then
			card.pinned = true
		end
		if G.GAME.voucher_sticker_index.banana[card.ability.name] then
			card.ability.banana = true
		end
		card:start_materialize()
		area:emplace(card)
		card.cost = 0
		card.shop_voucher = false
		local current_round_voucher = G.GAME.current_round.voucher
		card:unredeem()
		G.GAME.current_round.voucher = current_round_voucher
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0,
			func = function()
				card:start_dissolve()
				return true
			end,
		}))
		for i = 1, 2 do
			local area
			if G.STATE == G.STATES.HAND_PLAYED then
				if not G.redeemed_vouchers_during_hand then
					G.redeemed_vouchers_during_hand =
						CardArea(G.play.T.x, G.play.T.y, G.play.T.w, G.play.T.h, { type = "play", card_limit = 5 })
				end
				area = G.redeemed_vouchers_during_hand
			else
				area = G.play
			end
			local _pool = get_current_pool("Voucher", nil, nil, nil, true)
			local center = pseudorandom_element(_pool, pseudoseed("cry_trade_redeem"))
			local it = 1
			while center == "UNAVAILABLE" do
				it = it + 1
				center = pseudorandom_element(_pool, pseudoseed("cry_trade_redeem_resample" .. it))
			end
			local card = create_card("Voucher", area, nil, nil, nil, nil, center)
			card:start_materialize()
			area:emplace(card)
			card.cost = 0
			card.shop_voucher = false
			local current_round_voucher = G.GAME.current_round.voucher
			card:redeem()
			G.GAME.current_round.voucher = current_round_voucher
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0,
				func = function()
					card:start_dissolve()
					return true
				end,
			}))
		end
	end,
}