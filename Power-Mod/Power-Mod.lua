--- STEAMODDED HEADER
--- MOD_NAME: PowerMod
--- MOD_ID: power_mod
--- PREFIX: random
--- MOD_AUTHOR: [randomaster13]
--- MOD_DESCRIPTION: adds stuff to the game, overpowered things

----------------------------------------------
------------MOD CODE -------------------------

-- variables

--local discover_all = false

-- ben (my testing helper)

function ben(info)
    if info then
        if type(info) == 'table' then
            sendTraceMessage('no', 'ben')
            for k, v in ipairs(info) do
                sendTraceMessage('yes', 'ben')
                sendTraceMessage(tostring(k), 'ben')
                sendTraceMessage(tostring(v), 'ben')
                sendTraceMessage('no', 'ben')
            end
        else
            sendTraceMessage(tostring(info), 'ben')
        end
    else
        sendTraceMessage('yes', 'ben')
    end
end

--initialize
assert(SMODS.load_file("Planets.lua"))()
assert(SMODS.load_file("localization/en-us.lua"))()

function pick_from_deck(seed)
    local valid_cards = {}
    for k, v in ipairs(G.playing_cards) do
        if v.ability.effect ~= 'Stone Card' then
            valid_cards[#valid_cards+1] = v
        end
    end
    if valid_cards[1] then
        local random_card = pseudorandom_element(valid_cards, pseudoseed(seed..G.GAME.round_resets.ante))
        return {
            rank = random_card.base.value,
            suit = random_card.base.suit,
            id = random_card.base.id,
        }
    else
        return {
            rank = 'Ace',
            suit = 'Spades',
            id = 14,
        }
    end
end

-- atlases

local joker_atlas = SMODS.Atlas{
    key = 'jokers',
    px = 71,
    py = 95,
    path = 'Jokers.png',
}

-- jokers

local j_unusedballot = SMODS.Joker{
    key = 'j_unusedballot',
    loc_txt = {
        name = 'Unused Ballot',
        text = {
            'Retrigger all played',
            'cards five times'
        },
    },
    config = {
        name = 'Unusedballot',
        extra = 5,
    },
    rarity = 3,
    pos = {
        x = 1,
        y = 0,
    },
    atlas = 'jokers',
    cost = 8,
    unlocked = true,
    discovered = false or discover_all,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    ability = {
        name = 'Unusedballot',
        extra = 5,
    },

    set_ability = function(self, card, initial, delay_sprites)
        self.ability = self.config
    end,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                self.ability.extra
            },
        }
    end,

    calculate = function(self, card, context)
        if context.repetition then
            if context.cardarea == G.play then
                if self.ability and self.ability.name == 'Unusedballot' then
                    return {
                        message = localize('k_again_ex'),
                        repetitions = self.ability.extra,
                        card = card
                    }
                end
            end
        end
        return nil
    end,
}

local j_redleather = SMODS.Joker{
    key = 'j_redleather',
    loc_txt = {
        name = 'Red Leather',
        text = {
            'This card is a cheating',
            'card which adds a {X:mult,C:white} X10 {}',
            'Mult to all cards when scored'
        },
    },
    config = {
        name = 'redleather',
        Xmult = 10,
    },
    rarity = 4,
    pos = {
        x = 2,
        y = 0,
    },
    atlas = 'jokers',
    cost = 15,
    unlocked = true,
    discovered = false or discover_all,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    ability = {
        name = 'redleather',
        Xmult = 10,
    },

    set_ability = function(self, card, initial, delay_sprites)
        self.ability = self.config
    end,

    loc_vars = function(self, info_queue, center)
        return {
            vars = {
				center.ability.Xmult,
                self.ability
            },
        }
    end,

    calculate = function(self, card, context)
        if context.individual then
            if context.cardarea == G.play then
                if self.ability and self.ability.name == 'redleather' and
                (context.other_card:get_id() > 0 or context.other_card:get_id() < 0) then
                    return {
                        Xmult_mod = card.ability.Xmult,
                        card = card
                    }
                end
            end
        end
        return nil
    end,
}


local j_power_two = SMODS.Joker{
    key = 'j_power_two',
    loc_txt = {
        name = 'Power To Two',
        text = {
            'Once a Card is triggered',
            'this card adds a {X:dark_edition,C:white}^#2# {}',
            'Mult to all cards when scored'
        },
    },
    config = {
        extra = {
            name = 'power_two',
            Emult = 2,
        }
    },
    rarity = 4,
    pos = {
        x = 3,
        y = 0,
    },
    atlas = 'jokers',
    cost = 50,
    unlocked = true,
    discovered = false or discover_all,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    ability = {
        extra = {
            name = 'power_two',
            Emult = 2,
        }
    },

    set_ability = function(self, card, initial, delay_sprites)
        self.ability = self.config
    end,

    loc_vars = function(self, info_queue, center)
		return { vars = { self.ability.extra.Emult, center.ability.extra.Emult, self.ability.extra } }
	end,
    calculate = function(self, card, context)
		if context.joker_main
        then
            return {
                message = localize({ type = "variable", key = "a_powmult", vars = { card.ability.extra.Emult } }),
				Emult_mod = card.ability.extra.Emult,
                card = card
            }
        end
        return nil
    end,
}

local j_power_one_five = SMODS.Joker{
    key = 'j_power_one_five',
    loc_txt = {
        name = 'Power To One Point Five',
        text = {
            'this card adds a {X:dark_edition,C:white}^#2# {}',
            'Mult to every hand'
        },
    },
    config = {
        extra = {
            name = 'power_one_five',
            Emult = 1.5,
			chips = 2,
        }
    },
    rarity = 3,
    pos = {
        x = 4,
        y = 0,
    },
    atlas = 'jokers',
    cost = 25,
    unlocked = true,
    discovered = false or discover_all,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    ability = {
        extra = {
            name = 'power_one_five',
            Emult = 1.5,
			chips = 2,
        }
    },

    set_ability = function(self, card, initial, delay_sprites)
        self.ability = self.config
    end,

    loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.Emult, center.ability.extra.Emult, center.ability.extra } }
	end,
    calculate = function(self, card, context)
		if context.joker_main
        then
            return {
                message = localize({ type = "variable", key = "a_powmult", vars = { card.ability.extra.Emult } }),
				Emult_mod = card.ability.extra.Emult,
				chip_mod = card.ability.extra.chips,
                card = card
            }
        end
        return nil
    end,
}

--### RETURN TO THIS ###
--### RETURN TO THIS ###
--### RETURN TO THIS ###

local j_scaling_chips = SMODS.Joker{
    key = 'j_scaling_chips',
    loc_txt = {
        name = 'The {C:chips}Chips{}',
        text = {
            'This joker gains {X:chips,C:white}X#1#{} Chips on',
            'every second card scored, and {C:chips}+#2#{} Chips',
            'on every card scored.',
            '{C:inactive}(Currently{} {X:chips,C:white}X#3#{} {C:inactive}and {C:chips}+#4#{} {C:inactive}Chips){}',
            --'{C:inactive,s:0.8}check is #5#{}'
        },
    },
    config = {
        extra = {
            name = 'the_chips',
            xchips = 1.0,
			achips = 5,
            extra_xchips = 0.1,
            extra = 5,
            check = 0,
        }
    },
    rarity = 2,
    pos = {
        x = 5,
        y = 0,
    },
    atlas = 'jokers',
    cost = 8,
    unlocked = true,
    discovered = false or discover_all,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    ability = {
        extra = {
            name = 'the_chips',
            xchips = 1.0,
			achips = 5,
            extra_xchips = 0.1,
            extra = 5,
            check = 0,
        }
    },

    set_ability = function(self, card, initial, delay_sprites)
        self.ability = self.config
    end,

    loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.extra_xchips, center.ability.extra.extra, center.ability.extra.xchips, center.ability.extra.achips, center.ability.extra.check } }
	end,
    calculate = function(self, card, context)
		if context.joker_main then
            return {
                message = localize({ type = "variable", key = "a_chips", vars = { card.ability.extra.xchips } }),
                chip_mod = card.ability.extra.achips,
                Xchip_mod = card.ability.extra.xchips,
                card = card
            }
        end
        if context.cardarea == G.play and context.individual and not context.blueprint then
            if card.ability.extra.check >= 1 then
                card.ability.extra.xchips = card.ability.extra.xchips + card.ability.extra.extra_xchips
                card.ability.extra.check = 0
            else
                card.ability.extra.check = card.ability.extra.check + 1
            end
			card.ability.extra.achips = card.ability.extra.achips + card.ability.extra.extra
			return {
				extra = { focus = card, message = localize("k_upgrade_ex") },
				card = card,
				colour = G.C.MULT,
			}
		end
        return nil
    end,
}

----------------------
--### GAMBA Jokers ###
----------------------

local j_j_lotto_ticket = SMODS.Joker{
    key = 'j_j_lotto_ticket',
    loc_txt = {
        name = 'Lottery Ticket',
        text = {
            'This card has a {C:green}#1# in #2#{} chance',
            'of paying out {C:money}$#3#{} at the',
            'end of a round.',
            '{C:red,E:2}self destructs{}',
            '{C:inactive,S:0.75}destroyed in{} {C:attention,S:0.75}#4#{} {C:inactive,S:0.75}round#s2#{}',
        },
    },
    config = {
        extra = {
            name = 'j_lotto_ticket',
            money = 1e6,
            chances = 2,
            odds = 15
        }
    },
    rarity = 2,
    pos = {
        x = 6,
        y = 0,
    },
    atlas = 'jokers',
    cost = 2,
    unlocked = true,
    discovered = false or discover_all,
    blueprint_compat = false,
    immutable = true,
    eternal_compat = true,
    perishable_compat = false,
    ability = {
        extra = {
            name = 'j_lotto_ticket',
            money = 1e6,
            chances = 2,
            odds = 15
        }
    },

    set_ability = function(self, card, initial, delay_sprites)
        self.ability = self.config
    end,

    loc_vars = function(self, info_queue, center)
		return { vars = { ''..(G.GAME and (G.GAME.probabilities.normal * 2) or 2), center.ability.extra.odds, center.ability.extra.money, center.ability.extra.chances } }
	end,
    calculate = function(self, card, context)
        if
			context.end_of_round
			and not context.blueprint
			and not context.individual
			and not context.repetition
			and not context.retrigger_joker
        then
            if 2*pseudorandom('j_lotto_ticket') < (G.GAME.probabilities.normal*2)/card.ability.extra.odds then
                card.ability.extra.chances = 0
                return {
                    card.ability.extra.money
                },
                G.E_MANAGER:add_event(Event({
					func = function()
						play_sound("coin6")
						card.T.r = -0.2
						card:juice_up(0.3, 0.4)
						card.states.drag.is = true
						card.children.center.pinch.x = true
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.3,
							blockable = false,
							func = function()
								G.jokers:remove_card(card)
								card:remove()
								card = nil
								return true
							end,
						}))
						return true
					end,
				}))
            else
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card_eval_status_text(card, "extra", nil, nil, nil, {
                            message = localize("k_nope_ex"),
                            colour = G.C.GOLD,
                        })
                        return true
                    end,
                }))
            end

            if card.ability.extra.chances > 1 then
                card.ability.extra.chances = card.ability.extra.chances - 1
            else
                G.E_MANAGER:add_event(Event({
					func = function()
						play_sound("tarot1")
						card.T.r = -0.2
						card:juice_up(0.3, 0.4)
						card.states.drag.is = true
						card.children.center.pinch.x = true
						G.E_MANAGER:add_event(Event({
							trigger = "after",
							delay = 0.3,
							blockable = false,
							func = function()
								G.jokers:remove_card(card)
								card:remove()
								card = nil
								return true
							end,
						}))
						return true
					end,
				}))
            end
        end
    end,
}

local j_scratch_off = SMODS.Joker {
    key = 'j_scratch_off',
    loc_txt = {
        name = 'Scratch Off Ticket',
        text = {
            'Has a random chance to earn between',
            '{C:money}0 and 1000{} dollars each round!'
        }
    },
    config = {
        extra = {
            name = 'j_scratch_off',
            random = 0,
            money = 0
        }
    },
    rarity = 2,
    pos = {
        x = 5,
        y = 1,
    },
    atlas = 'jokers',
    cost = 2,
    unlocked = true,
    discovered = false or discover_all,
    blueprint_compat = false,
    immutable = true,
    eternal_compat = true,
    perishable_compat = true,
    ability = {
        extra = {
            name = 'j_scratch_off',
            random = 0,
            money = 0
        }
    },

    set_ability = function(self, card, initial, delay_sprites)
        self.ability = self.config
    end,

    loc_vars = function(self, info_queue, center)
        return {}
    end,
    -- calculate = function(self, card, context) --move all of this to calc dollar bonus -.- am eepy.
	-- 	if
    --     context.end_of_round
    --     and not context.blueprint
	-- 	and not context.individual
	-- 	and not context.repetition
	-- 	and not context.retrigger_joker
    --     then
    --         card.ability.extra.random = math.random(1,100)
    --         print (card.ability.extra.random)
    --         --random rewards, probably best to redo this with pseudorandom odds like with the lottery ticket above.
    --         --35%
    --         if card.ability.extra.random <= 35 then
    --             G.E_MANAGER:add_event(Event({
    --                 func = function()
    --                     card_eval_status_text(card, "extra", nil, nil, nil, {
    --                         message = localize("pow_freeplay"),
    --                         colour = G.C.RED,
    --                     })
    --                     return true
    --                 end,
    --             }))
    --         --25%
    --         elseif card.ability.extra.random <= 60 then
    --             card.ability.extra.money = 4
    --             -- G.E_MANAGER:add_event(Event({
    --             --     func = function()
    --             --         play_sound("coin5")
    --             --         return true
    --             --     end,
    --             -- }))
    --         --20%
    --         elseif card.ability.extra.random <= 80 then
    --             card.ability.extra.money = 8
    --             -- G.E_MANAGER:add_event(Event({
    --             --     func = function()
    --             --         play_sound("coin6")
    --             --         return true
    --             --     end,
    --             -- }))
    --         --10%
    --         elseif card.ability.extra.random <= 90 then
    --             card.ability.extra.money = 20
    --             -- G.E_MANAGER:add_event(Event({
    --             --     func = function()
    --             --         play_sound("coin6")
    --             --         return true
    --             --     end,
    --             -- }))
    --         --6%
    --         elseif card.ability.extra.random <= 96 then
    --             card.ability.extra.money = 40
    --             -- G.E_MANAGER:add_event(Event({
    --             --     func = function()
    --             --         play_sound("coin6")
    --             --         return true
    --             --     end,
    --             -- }))
    --         --3%
    --         elseif card.ability.extra.random <= 99 then
    --             card.ability.extra.money = 100
    --             -- G.E_MANAGER:add_event(Event({
    --             --     func = function()
    --             --         play_sound("coin6")
    --             --         return true
    --             --     end,
    --             -- }))
    --         --1%
    --         else
    --             card.ability.extra.money = 1000
    --             -- G.E_MANAGER:add_event(Event({
    --             --     func = function()
    --             --         play_sound("coin6")
    --             --         play_sound("coin5")
    --             --         return true
    --             --     end,
    --             -- }))
    --         end
    --     end
    --     return nil
    -- end,
    calc_dollar_bonus = function(self, card)
        card.ability.extra.random = math.random(1,22)
        --random rewards, probably best to redo this with pseudorandom odds like with the lottery ticket above.
        --print (card.ability.extra.random)
        if to_big(card.ability.extra.random) <= to_big(35) then
            -- G.E_MANAGER:add_event(Event({
            --     func = function()
            --         card_eval_status_text(card, "extra", nil, nil, nil, {
            --             message = localize("pow_freeplay"),
            --             colour = G.C.RED,
            --         })
            --         return true
            --     end,
            -- }))
            --card.ability.extra.money = 1
            print("aaa")
        -- elseif to_big(card.ability.extra.random) <= to_big(60) then
        --     --card.ability.extra.money = 4
        -- --20%
        -- elseif to_big(card.ability.extra.random) <= to_big(80) then
        --     --card.ability.extra.money = 8
        -- --10%
        -- elseif to_big(card.ability.extra.random)  <= to_big(90) then
        --     --card.ability.extra.money = to_big(20)
        -- --6%
        -- elseif to_big(card.ability.extra.random) <= to_big(96) then
        --     --card.ability.extra.money = to_big(40)
        -- --3%
        -- elseif to_big(card.ability.extra.random) <= to_big(99) then
        --     --card.ability.extra.money = to_big(100)
        -- --1%
        -- else
        --     --card.ability.extra.money = to_big(1000)
        end
        --if to_big(card.ability.extra.money) ~= to_big(0) then
            return {
                --card.ability.extra.money
            }
        --end
    end
}

local j_odium = SMODS.Joker{
    key = 'j_odium',
    loc_txt = {
        name = 'Odium',
        text = {
            'Odium Reigns',
			'This card adds {X:dark_edition,C:white}^#1#{} Mult and',
			'{X:dark_edition,C:white}^#2#{} Chips at the end of the round',
			'and adds a {X:mult,C:white} X#3# {} mult to every card scored.',
        },
    },
    config = {
        extra = {
            name = 'odium',
            Emult = 1.75,
			Echips = 2,
			Achips = 6,
			Xmult = 3.5,
			Amult = 25,
			dollars = 3
        }
    },
	rarity = 4,
    pos = {
        x = 1,
        y = 1,
    },
    atlas = 'jokers',
    cost = 125,
    unlocked = true,
    discovered = false or discover_all,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    ability = {
        extra = {
            name = 'odium',
            Emult = 1.75,
			Echips = 2,
			Achips = 6,
			Xmult = 3.5,
			Amult = 25,
			dollars = 3
        }
    },

    set_ability = function(self, card, initial, delay_sprites)
        self.ability = self.config
    end,

    loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.Emult, center.ability.extra.Echips, center.ability.extra.Xmult, center.ability.extra.Amult } }
	end,
    calculate = function(self, card, context)
		if
            context.cardarea == G.jokers
            and not context.before
			and not context.after
        then
            return {
                message = localize({ type = "variable", key = "a_powmult", vars = { card.ability.extra.emult } }),
				Emult_mod = card.ability.extra.Emult,
				Echip_mod = card.ability.extra.Echips,
                card = card
            }
        end
		if context.individual then
            if context.cardarea == G.play then
                if self.ability.extra.name == 'odium' then
					return {
						x_mult = card.ability.extra.Xmult,
						mult_mod = card.ability.extra.Amult,
						chips = card.ability.extra.Achips,
						dollars = card.ability.extra.dollars,
						card = card
					}
				end
			end
		end
        return nil
    end,
}

local j_cardid = SMODS.Joker{
    key = 'j_cardid',
    loc_txt = {
        name = 'Card Mult',
        text = {
            '{X:dark_edition,C:white}^#1#{} mult at the end of the round,',
			'{X:dark_edition,C:white}^#2#{} mult, {X:mult,C:white} X#3#{} mult,',
			'{C:mult}+#4#{} mult, and {C:money}$#5#{} for each card scored.',
        },
    },
    config = {
        extra = {
            name = 'cardid',
            Emult = 1.25,
			Emult2 = 1.1,
			Xmult = 1.667,
			Achips = 5,
			Amult = 20,
			dollars = 1
        }
    },
	rarity = 3,
    pos = {
        x = 2,
        y = 1,
    },
    atlas = 'jokers',
    cost = 65,
    unlocked = true,
    discovered = false or discover_all,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    -- ability = {
    --     extra = {
    --         name = 'cardid',
    --         Emult = 1.25,
	-- 		Emult2 = 1.1,
	-- 		Xmult = 1.667,
	-- 		Achips = 5,
	-- 		Amult = 20,
	-- 		dollars = 1
    --     }
    -- },

    set_ability = function(self, card, initial, delay_sprites)
        self.ability = self.config
    end,

    loc_vars = function(self, info_queue, center)
		return {
			vars = {
				center.ability.extra.Emult,
				center.ability.extra.Emult2,
				center.ability.extra.Xmult,
				center.ability.extra.Amult,
				center.ability.extra.dollars
		}
	}
	end,
    calculate = function(self, card, context)
		if
		context.joker_main and (to_big(card.ability.extra.Emult) > to_big(1))
        then
            return {
                message = localize(
					{
						type = "variable", key = "a_powmult", vars = { card.ability.extra.Emult }
					}
				),
				Emult_mod = card.ability.extra.Emult,
                card = card
            }
        end
		if context.individual and (to_big(card.ability.extra.Emult2) > to_big(1)) then
            if context.cardarea == G.play then
                if card.ability.extra.name == 'cardid' then
					--print(card.ability.extra.Emult2)
					return {
						message = localize(
							{ type = "variable", key = "a_powmult", vars = { card.ability.extra.Emult2 } }
						),
						Emult_mod = card.ability.extra.Emult2,
						Xmult_mod = card.ability.extra.Xmult,
						mult_mod = card.ability.extra.Amult,
						chips = card.ability.extra.Achips,
						dollars = card.ability.extra.dollars,
						card = card
					}
				end
			end
		end
        return nil
    end,
}

local j_slowandsteady = SMODS.Joker{
    key = 'j_slowandsteady',
    loc_txt = {
        name = 'Slow And Steady',
        text = {
            'Makes later hands more viable.',
 			'{X:mult,C:white}X#1#{} mult (2/hands remaining).',
 			'{X:mult,C:white}X#2#{} mult and {X:chips,C:white}X#3#{} chips on final hand.'
        },
    },
    config = {
        extra = {
            name = 'slow-and-steady',
			Xmult = 2,
			Xmult2 = 3,
			Xchips = 2,
        }
    },
	rarity = 3,
    pos = {
        x = 3,
        y = 1,
    },
    atlas = 'jokers',
    cost = 6,
    unlocked = true,
    discovered = false or discover_all,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    ability = {
        extra = {
            name = 'slow-and-steady',
			Xmult = 2,
			Xmult2 = 3,
			Xchips = 2,
        }
    },

    set_ability = function(self, card, initial, delay_sprites)
        self.ability = self.config
    end,

    loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.Xmult, center.ability.extra.Xmult2, center.ability.extra.Xchips} }
	end,
    calculate = function(self, card, context)
		--print(G.GAME.current_round.hands_left)
		if G.GAME.current_round.hands_left > 0 then
			card.ability.extra.Xmult = 2 / (tonumber(G.GAME.current_round.hands_left) + 1)
		else
			card.ability.extra.Xmult = 2
		end
		if
            context.cardarea == G.jokers
            and not context.before
			and not context.after
        then
			if G.GAME.current_round.hands_left ~= 0 then
            	return {
					message = localize{type='variable',key='a_xmult',vars={card.ability.extra.Xmult}},
					Xmult_mod = card.ability.extra.Xmult,
                	card = card
            	}
			end
			if G.GAME.current_round.hands_left == 0 then
				return {
					message = localize({type='variable',key='a_xmult',vars={card.ability.extra.Xmult2}},{type='variable',key='a_xchips',vars={card.ability.extra.Xchips}}),
					Xmult_mod = card.ability.extra.Xmult2,
					Xchip_mod = card.ability.extra.Xchips,
					card = card
				}
			end
        end
        return nil
    end,
}

-- local j_power_two = SMODS.Joker{
--     key = 'j_power_one_five',
--     loc_txt = {
--         name = 'Power To One Point Five',
--         text = {
--             'this card adds a {X:dark_edition,C:white}^1.5 {}',
--             'Mult to every hand'
--         },
--     },
--     config = {
--         extra = {
--             name = 'power_one_five',
--             Echip = 1.5,
--         }
--     },
--     rarity = 3,
--     pos = {
--         x = 4,
--         y = 0,
--     },
--     atlas = 'jokers',
--     cost = 25,
--     unlocked = true,
--     discovered = false or discover_all,
--     blueprint_compat = true,
--     eternal_compat = true,
--     perishable_compat = true,
--     ability = {
--         extra = {
--             name = 'power_one_five',
--             Echip = 1.5,
--         }
--     },

--     set_ability = function(self, card, initial, delay_sprites)
--         self.ability = self.config
--     end,

--     loc_vars = function(self, info_queue, center)
-- 		return { vars = { self.ability.extra.Emult, center.ability.extra.Emult, self.ability.extra } }
-- 	end,
--     calculate = function(self, card, context)
-- 		if
--             context.cardarea == G.jokers
--             and not context.before
-- 			and not context.after
--         then
--             return {
--                 message = localize({ type = "variable", key = "a_powchip", vars = { card.ability.extra.emult } }, { type = "variable", key = "a_chips", vars = { card.ability.extra.chips } }),
-- 				Emult_mod = self.ability.extra.Emult,
-- 				chip_mod = self.ability.extra.chips,
--                 card = card

--             }
--         end
--         return nil
--     end,
-- }

-----------------------------------------------
---Planets
-----------------------------------------------

-- local planet_atlas = SMODS.Atlas{
--     key = 'planets',
--     px = 71,
--     py = 95,
--     path = 'Planets.png',
-- }

-- local p_empty_sky = SMODS.Consumable{
--     --object_type = "Consumable",
-- 	key = "p_empty_sky",
-- 	loc_txt = {
--         name = 'Empty Sky',
-- 		text = {
--             'Better description goes here',
--         },
-- 	},
--     order = 24,
--     discovered = true,
--     cost = 4,
--     consumeable = true,
--     freq = 1,
--     pos = {
--         x=1,
--         y=0,
--     },
--     set = "Planet",
--     atlas = "planets",
--     effect = "Hand Upgrade",
--     cost_mult = 1.0,
-- 	can_use = function(self, card)
-- 		return true
-- 	end,
--     config = {
--         hand_types = {"High Card"}
--     },
--     loc_vars = function(self, info_queue, center)
-- 		local levelone = G.GAME.hands["High Card"].level or 1
-- 		local planetcolourone = G.C.HAND_LEVELS[math.min(levelone, 7)]
-- 		if levelone == 1 then
-- 			if levelone == 1 then
-- 				planetcolourone = G.C.UI.TEXT_DARK
-- 			end
-- 		end
-- 		return {
-- 			vars = {
-- 				localize("High Card", "poker_hands"),
-- 				G.GAME.hands["High Card"].level,
-- 				colours = { planetcolourone, },
-- 			},
-- 		}
-- 	end,
-- 	calculate = function(self, card, context)
-- 		if
-- 			G.GAME.used_vouchers.v_observatory
-- 			and (
-- 				context.scoring_name == "High Card"
-- 			)
-- 		then
-- 			local value = G.P_CENTERS.v_observatory.config.extra
-- 			return {
-- 				message = localize({ type = "variable", key = "a_xmult", vars = { value } }),
-- 				Xmult_mod = value,
-- 			}
-- 		end
-- 	end,
-- }


-----------------------------------------------
-------------  CREDIT TO CRYPTID  -------------
-----------------------------------------------

local mod_path = "" .. SMODS.current_mod.path

---- Rarity ----

SMODS.Rarity{
    key = "Shardic",
    loc_txt = {},
    badge_colour = HEX('d7caeb'),
}

---- Code ----

-- local cj = Card.calculate_joker

-- function Card:calculate_joker(context)
-- 	--Calculate events
-- 	if self == G.jokers.cards[1] then
-- 		for k, v in pairs(SMODS.Events) do
-- 			if G.GAME.events[k] then
-- 				context.pre_jokers = true
-- 				v:calculate(context)
-- 				context.pre_jokers = nil
-- 			end
-- 		end
-- 	end
-- 	local active_side = self
-- 	if next(find_joker("cry-Flip Side")) and not context.dbl_side and self.edition and self.edition.cry_double_sided then
-- 		self:init_dbl_side()
-- 		active_side = self.dbl_side
-- 		if context.callback then
-- 			local m = context.callback
-- 			context.callback = function(card,a,b)
-- 				m(self,a,b)
-- 			end
-- 			context.dbl_side = true
-- 		end
-- 	end
-- 	if active_side.will_shatter then
-- 		return
-- 	end
-- 	local ggpn = G.GAME.probabilities.normal
-- 	if not G.GAME.cry_double_scale then
-- 		G.GAME.cry_double_scale = { double_scale = true } --doesn't really matter what's in here as long as there's something
-- 	end
-- 	if active_side.ability.cry_rigged then
-- 		G.GAME.probabilities.normal = 1e9
-- 	end
-- 	local orig_ability = active_side:cry_copy_ability()
-- 	local in_context_scaling = false
-- 	local callback = context.callback
-- 	if active_side.ability.cry_possessed then
-- 		if not ((context.individual and not context.repetition) or (context.joker_main) or (context.other_joker and not context.post_trigger)) then
-- 			return
-- 		end
-- 		context.callback = nil
-- 	end
-- 	local in_context_scaling = false
-- 	local callback = context.callback
-- 	local ret, trig = cj(active_side, context)
-- 	if active_side.ability.cry_possessed and ret then
-- 		if ret.mult_mod then ret.mult_mod = ret.mult_mod * -1 end
-- 		if ret.Xmult_mod then ret.Xmult_mod = ret.Xmult_mod ^ -1 end
-- 		if ret.mult then ret.mult = ret.mult * -1 end
-- 		if ret.x_mult then ret.x_mult = ret.x_mult ^ -1 end
-- 		ret.e_mult = nil
-- 		ret.ee_mult = nil
-- 		ret.eee_mult = nil
-- 		ret.hyper_mult = nil
-- 		ret.Emult_mod = nil
-- 		ret.EEmult_mod = nil
-- 		ret.EEEmult_mod = nil
-- 		ret.hypermult_mod = nil
-- 		if ret.chip_mod then ret.chip_mod = ret.chip_mod * -1 end
-- 		if ret.Xchip_mod then ret.Xchip_mod = ret.Xchip_mod ^ -1 end
-- 		if ret.chips then ret.chips = ret.chips * -1 end
-- 		if ret.x_chips then ret.x_chips = ret.x_chips ^ -1 end
-- 		ret.e_chips = nil
-- 		ret.ee_chips = nil
-- 		ret.eee_chips = nil
-- 		ret.hyper_chips = nil
-- 		ret.Echip_mod = nil
-- 		ret.EEchip_mod = nil
-- 		ret.EEEchip_mod = nil
-- 		ret.hyperchip_mod = nil
-- 		if ret.message then
-- 			-- TODO - this is a hacky way to do this, but it works for now
-- 			if type(ret.message) == "table" then
-- 				ret.message = ret.message[1]
-- 			end
-- 			if ret.message:sub(1,1) == "+" then
-- 				ret.message = "-" .. ret.message:sub(2)
-- 			elseif ret.message:sub(1,1) == "X" then
-- 				ret.message = "/" .. ret.message:sub(2)
-- 			else
-- 				ret.message = ret.message .. "?"
-- 			end
-- 		end
-- 		callback(context.blueprint_card or self, ret, context.retrigger_joker)
-- 	end
-- 	if not context.blueprint and (active_side.ability.set == "Joker") and not active_side.debuff then
-- 		if ret or trig then
-- 			in_context_scaling = true
-- 		end
-- 	end
-- 	if active_side.ability.cry_rigged then
-- 		G.GAME.probabilities.normal = ggpn
-- 	end
-- 	active_side:cry_double_scale_calc(orig_ability, in_context_scaling)
-- 	--Calculate events
-- 	if self == G.jokers.cards[#G.jokers.cards] then
-- 		for k, v in pairs(SMODS.Events) do
-- 			if G.GAME.events[k] then
-- 				context.post_jokers = true
-- 				v:calculate(context)
-- 				context.post_jokers = nil
-- 			end
-- 		end
-- 	end
-- 	return ret, trig
-- end

-- -- Make tags fit if there's more than 13 of them
-- local at = add_tag
-- function add_tag(tag)
-- 	at(tag)
-- 	if #G.HUD_tags > 13 then
-- 		for i = 2, #G.HUD_tags do
-- 			G.HUD_tags[i].config.offset.y = 0.9 - 0.9 * 13 / #G.HUD_tags
-- 		end
-- 	end
-- end

-- --add calculation context and callback to tag function
-- local at2 = add_tag
-- function add_tag(tag, from_skip, no_copy)
-- 	if no_copy then
-- 		at2(tag)
-- 		return
-- 	end
-- 	local added_tags = 1
-- 	for i = 1, #G.jokers.cards do
-- 		local ret = G.jokers.cards[i]:calculate_joker({ cry_add_tag = true })
-- 		if ret and ret.tags then
-- 			added_tags = added_tags + ret.tags
-- 		end
-- 	end
-- 	if added_tags >= 1 then
-- 		at2(tag)
-- 	end
-- 	for i = 2, added_tags do
-- 		local tag_table = tag:save()
-- 		local new_tag = Tag(tag.key)
-- 		new_tag:load(tag_table)
-- 		at2(new_tag)
-- 	end
-- end

-- local tr = Tag.remove
-- function Tag:remove()
-- 	tr(self)
-- 	if #G.HUD_tags >= 13 then
-- 		for i = 2, #G.HUD_tags do
-- 			G.HUD_tags[i].config.offset.y = 0.9 - 0.9 * 13 / #G.HUD_tags
-- 		end
-- 	end
-- end

to_big = to_big or function(num)
    return num
end


----------------------------------------------
------------MOD CODE END----------------------