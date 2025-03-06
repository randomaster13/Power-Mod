local pow_double_gold = SMODS.Enhancement{
    object_type = "Seal",
    key = 'd_gold',
    loc_txt = {
        name = 'Double Gold Seal',
        text = {
            "Earn {C:money}$#1#{} when this",
            "card is played",
            "and scores"
        },
    },
    badge_colour = G.C.GOLD,
    config = {
        money = 6
    },
	loc_vars = function(self, info_queue)
		return { vars = { self.config.money } }
	end,
	atlas = "Enhancers",
	pos = { x = 2, y = 0 },

    calculate = function(self, card, context)
        return {
            dollars = card.config.money
        }
    end

}