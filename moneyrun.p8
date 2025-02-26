pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
function _init()
	prev_scene = nil
	current_scene = "main"
end

function _update60()
	--the goal is to always allow each init_ for each screen to run once on a single frame in update.
	--and we have previous scene and current scene to make this happen .. how do we do it?
			
	if current_scene == "main" then
		update_main()
	elseif current_scene == "game" then
		update_game()
	elseif current_scene == "win" then
		update_win()
	end
	prev_scene = current_scene 
end

function _draw()
	if current_scene == "main" then
		draw_main()
	elseif current_scene == "game" then
		draw_game()
	elseif current_scene == "win" then
		draw_win()
	end
end
-->8
wins = 0
choice = {
	options = { "speed", "gain", "win" },
	num = 1,
}
moneyman = {
	tile = 24, --default 17
	x = 2 * 8,
	y = 6 * 8,
	speed = 0.4,-- default 0.4 max speed=10
}
money = {
	amount = 30000,
	amount_color = 7,
	gain = 1,  -- max amount 30000
	maxamount = 32767,
	maxed = ""
}
boundery = {
	l = 2 * 8,
	r = 14 * 8,
}
store = {
	speed_cost = {5, 25, 85, 360, 950, 1250, 2000, 5000, 7500, 0},
	gain_cost = {10, 20, 110, 450, 1150, 1750, 2250, 6500, 8000, 0},
	win_cost = {10000, 15000, 20000, 25000, 30000, 32767, 0},
	speed_amount = {0.2, 0.2, 0.4, 0.4, 0.5, 0.7, 1, 1.6, 2, 0},
	gain_amount = {2, 5, 8, 15, 30, 60, 85, 105, 170, 0},
	win_amount = {1, 1, 1, 1, 1, 1, 0},
	speed_count = 1,
	gain_count = 1,
	win_count = 1,
	color_num = 8,
	amount = 0,

	speed_btn = 2,
	gain_btn = 2,
	win_btn = 2,
	btn_x = 11 * 8,
	btn_y = 8 * 8,
	cost = "",
	speed_display = "",
	gain_display = "",
	win_display = "",
	win_display_label = "win:   ",
	win_display_label_color = 7,
	speed_display_color = 7,
	gain_display_color = 7,
	win_display_color = 7,
	maxed = "max"
}

function update_game()
	local nextposval = nextpos(moneyman.x, moneyman.speed)
	if nextposval <= boundery.l then
		moneyman.x = boundery.l
		moneyman.speed *= -1
		update_money()
	elseif nextposval >= boundery.r - 8 then
		moneyman.x = boundery.r - 8
		moneyman.speed *= -1
		update_money()
	else
		moneyman.x += moneyman.speed
	end
	
	if money.amount == money.maxamount then
		money.maxed = "max"
	else
		money.maxed = ""
	end
	
	if store.speed_count < #store.speed_amount then
		store.speed_display = "+"..store.speed_amount[store.speed_count]	
	else 
		store.speed_display = store.maxed
		store.speed_display_color = 2
	end
	if store.gain_count < #store.gain_amount then
		store.gain_display = "+$"..store.gain_amount[store.gain_count]	
	else 
		store.gain_display = store.maxed
		store.gain_display_color = 2
	end
	if store.win_count < #store.win_amount - 1 then
		store.win_display = "+"..store.win_amount[store.win_count]	
	else 
		store.win_display = ""
		store.win_display_label = "become a money god"
		store.win_display_label_color = 10
	end

	if choice.options[choice.num] == "speed" then
		store.speed_btn = 5
		store.amount = store.speed_cost[store.speed_count]
		if store.speed_count < #store.speed_amount then
			store.color_num = check_cost(store.speed_cost[store.speed_count], money.amount)
			store.cost = "$"..store.amount
		else
			store.color_num = 2 
			store.cost = ""
		end
	else
		store.speed_btn = 2
	end
	if choice.options[choice.num] == "gain" then
		store.gain_btn = 5
		store.amount = store.gain_cost[store.gain_count]
		if store.gain_count < #store.gain_amount then
			store.color_num = check_cost(store.gain_cost[store.gain_count], money.amount)
			store.cost = "$"..store.amount
		else
			store.color_num = 2 
			store.cost = ""
		end
	else
		store.gain_btn = 2
	end
	if choice.options[choice.num] == "win" then
		store.win_btn = 5
		store.amount = store.win_cost[store.win_count]
		if store.win_count < #store.win_amount - 1 then
			store.color_num = check_cost(store.win_cost[store.win_count], money.amount)
			store.cost = "$"..store.amount
		elseif store.win_count == #store.win_amount - 1 then
			store.cost = "$"..store.amount
			if store.speed_count == #store.speed_amount and store.gain_count == #store.gain_amount and check_cost_bool(store.win_cost[store.win_count], money.amount) then
				store.color_num = 10
			else
				store.color_num = 8
			end
		else
			store.color_num = 2 
			store.cost = ""
		end
	else
		store.win_btn = 2
	end
	if store.speed_count == #store.speed_amount and store.gain_count == #store.gain_amount and store.win_count == #store.win_amount - 1 then
		money.amount_color = 10	
	else
		money.amount_color = 7
	end

	if btnp(⬆️) and choice.num > 1 then
		choice.num -= 1
	elseif btnp(⬇️) and choice.num < 3 then
		choice.num += 1
	end
	
	if btn(❎) and choice.options[choice.num] == "speed" then
		store.speed_btn = 21
	elseif choice.options[choice.num] == "speed" then
		store.speed_btn = 5
	end

	if btn(❎) and choice.options[choice.num] == "gain" then
		store.gain_btn = 21
	elseif choice.options[choice.num] == "gain" then
		store.gain_btn = 5
	end

	if btn(❎) and choice.options[choice.num] == "win" then
		store.win_btn = 21
	elseif choice.options[choice.num] == "win" then
		store.win_btn = 5
	end

	if btnp(❎) and choice.options[choice.num] == "speed" then
		if check_cost_bool(store.speed_cost[store.speed_count], money.amount) then
			if store.speed_count < #store.speed_amount then
				money.amount -= store.speed_cost[store.speed_count]
				if moneyman.speed < 0 then
					moneyman.speed -= store.speed_amount[store.speed_count]
				else
					moneyman.speed += store.speed_amount[store.speed_count]
				end
				store.speed_count += 1
				sfx(4)
			end
		else	
			sfx(3)	
		end

	elseif btnp(❎) and choice.options[choice.num] == "gain" then
		if check_cost_bool(store.gain_cost[store.gain_count], money.amount) then
			if store.gain_count < #store.gain_amount then
				money.amount -= store.gain_cost[store.gain_count]
				money.gain += store.gain_amount[store.gain_count]
				store.gain_count += 1
				sfx(4)
			end
		else
			sfx(3)
		end
	elseif btnp(❎) and choice.options[choice.num] == "win" then
		if check_cost_bool(store.win_cost[store.win_count], money.amount) then
			if store.win_count < #store.win_amount-1 then
				money.amount -= store.win_cost[store.win_count]
				wins += store.win_amount[store.win_count]
				store.win_count += 1
				money.amount = 32767 
				moneyman.x = 2 * 8
				moneyman.speed = 1 * wins
				money.gain = 4 * wins 
				store.speed_count = 1
				store.gain_count = 1
				store.speed_display_color = 7
				store.gain_display_color = 7
				store.win_display_color = 7
				sfx(6)
			else
				if store.speed_count == #store.speed_amount and store.gain_count == #store.gain_amount and money.amount == 32767 then
					current_scene = "win"
				end
			end
		else
			sfx(3)
		end
	end
end

function draw_game()
	cls()
	map(16, 0, 0, 0, 16, 16, 0)	
	map(0, 0, 0, 0, 16, 16, 0)
	spr(moneyman.tile, moneyman.x, moneyman.y, 1, 1)
	print("$" .. money.amount, 2 * 8, 2 * 8, money.amount_color)
	print(money.maxed, 5.5 * 8, 2 * 8, 2)
	print("speed:", 2 * 8, 8 * 8, 7)
	print("gain: ", 2 * 8, 8 * 9, 7)
	print(store.win_display_label, 2 * 8, 8 * 10, store.win_display_label_color)
	print(store.speed_display, 5.5 * 8, 8 * 8, store.speed_display_color)
	print(store.gain_display, 5.5 * 8, 8 * 9, store.gain_display_color)
	print(store.win_display, 5.5 * 8, 8 * 10, store.win_display_color)
	print("total speed: " .. round_to_tenth(abs(moneyman.speed)), 2 * 8, 8 * 12, 7)
	print("total gain:  $" .. money.gain, 2 * 8, 13 * 8, 7)
	print("total wins:  " .. wins, 2 * 8, 14 * 8, 7)

	spr(store.speed_btn, store.btn_x, store.btn_y, 3, 1)
	spr(store.gain_btn, store.btn_x, store.btn_y + 8, 3, 1)
	spr(store.win_btn, store.btn_x, store.btn_y + 16, 3, 1)
	--debug

	print(store.cost, 11 * 8, 12 * 8, store.color_num)
end

function nextpos(x, speed)
	return x + speed
end

function update_money()
	if money.amount + money.gain > 0 then
		money.amount += money.gain
	else
		money.amount = money.maxamount - money.amount + money.amount
	end
	sfx(00)
	-- money sound
end

function check_cost(cost, amount)
	if cost <= amount then
		return 11 -- return green
	end
	return 8
	-- return red
end

function check_cost_bool(cost, amount)
	if cost <= amount then
		return true
	end
	return false
end

function round_to_tenth(number)
	return flr(number * 10 + 0.5) / 10
end

-->8
tile_size = 8
main_draw = {
	start_x = 1.5 * tile_size,
	start_y = 9 * tile_size,
}

function update_win()
end

function draw_win()
	cls()
end
-->8
function update_main()
	if btnp(❎) then
		sfx(5)
		current_scene = "game"
	end
end

function draw_main()
	cls()
	map(16, 0, 0, 0, 16, 16)	
	spr(32, 3.5*8, 5*8, 9, 2)
	--print("press ❎ to start the game", 1.4*8, 9.1*8, 2)
	print("press ❎ to start the game", main_draw.start_x, main_draw.start_y, 9)
end

__gfx__
0000000077777777000ddddddddddddddddd11000777ddddd777777ddddd77702222222222222222200000000000000000000000000000000000000000000000
000000007777777700ddd111dd1dd1d1dd1dd11070ddd111dd1dd1d1dd1dd1172222222222222222200000000100000000000000000000000000000000000000
00700700000000000dddd1d1dd1dd1d1dd1ddd117dddd1d1dd1dd1d1dd1ddd172222222222222222200000000000000000000000000000000000700000000000
00077000000000000dddd1111d1dd1d1111ddd117dddd1111d1dd1d1111ddd172222222222222222200000000000000000007000000000000000000000000000
00077000000000000dddd1dd1d1dd1dd11dddd117dddd1dd1d1dd1dd11dddd172222222222222222200000000000000000000000000000000000000000000000
007007000000000000ddd1111d1111dd11ddd11070ddd1111d1111dd11ddd1172220222222222222200000000000000000000000010000000000000000000000
0000000000000000000ddddddddddddddddd11000777ddddd777777ddddd77702220222222222222200000000000000000000000000000000000000000000700
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000aaaaaaaa000011111111111111111d00055511111555555111115550000aaa0000000000000000000000000000000000000000000000000000000000
00000000aaaaaaaa0001110001101101011011d0500111000110110101101115000aa00000000000000000000000000000000000000000000000000000000000
00000000aa1aa1aa00111101011011010110111d5011110101101101011011150000aa0000000000000000000000000000000000000000000000000000000000
00000000aaaaaaaa00111100001011010000111d501111000010110100001115000aaa0000000000000000000000001000000000000000000000000000000000
00000000aa1111aa00111101101011011001111d5011110110101101100111150000a00000000000000000000000000000000000000000000000000000000000
00000000aaa88aaa0001110000100001100111d05001110000100001100111150aaaaaa000000000000000000000000000000000000000000000000000000000
00000000aaaaaaaa000011111111111111111d00055511111555555111115550aaaaaaaa00000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000aaaaaaaa00000000000000000000000000000000000000000000000000000000
000aa0aa000aaaaaa0aa00aa0aaaaaa0aa00aa000aaaaa00aa00aa0aa00aa000aaa0000000000000000000000000000000000000000000000000000000000000
000aaaaa009aaaaaa9aaa9aa9a999909aa09aa009a9990a9aa09aa9aaa9aa009aa00000000000000000000000000000000000000000000000000000000000000
00aaaaaaa09aa99aa9aaaaaa9aaaa009aaaaaa009aaaaaa9aa09aa9aaaaaa0099aa0000000000000000000000000000000000000000000000000000000000000
0aa9aaa9aa9aa09aa9aaaaaa9a9900099aaaa0009aa9aa09aa09aa9aaaaaa000aaa0000000000000000000000000000000000000000000000000000000000000
9aa99a09aa9aaaaaa9aa9aaa9aaaaaa099aa00009aa99aa9aaaaaa9aa9aaa0099a00000000000000000000000000000000000000000000000000000000000000
9aa09009aa9aaaaaa9aa99aa9aaaaaa009aa00009aa09aa9aaaaaa9aa99aa00aaaaa000000000000000000000000000000000000000000000000000000000000
990000099099999909900990999999000990000099009909999990990099009aaaaa000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000009aaaaa000000000000000000000000000000000000000000000000000000000000
0a0aa0aaa0aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000
90990999099999999999999999999999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa0000aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa0000aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa0000aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a0000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999000009990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a9a000099990a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a9a000aa00a0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a9a000a0000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a088a000aa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a088a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a888a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a88800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a00a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aa00a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a00a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07700770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007770777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007700707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000770777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007770007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000aaaa00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000888800000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000aaaa00000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000aaaa00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000999000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000a9a000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000a9a000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000a9a000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000a088a00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000a088a00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000a888a00000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000aaa00000000000888800000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000aa000000000000888000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000aa00000000000a88800000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000aaa00000000000a00a00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000a00000000000aa00a00000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000aaaaaa000000000a00a000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000aaaaaaaa000000008008000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000aaaaaaaa000000007700770000000000000000000000000000000000000000000000000
00000000000000007777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777770000000000000000
00000000000000007777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777770000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000770777077707770770000000000000077700000777000000000000000000000000000000777ddddd777777ddddd77700000000000000000
000000000000000070007070700070007070070000000700707000000070000000000000000000000000000070ddd111dd1dd1d1dd1dd1170000000000000000
00000000000000007770777077007700707000000000777070700000777000000000000000000000000000007dddd1d1dd1dd1d1dd1ddd170000000000000000
00000000000000000070700070007000707007000000070070700000700000000000000000000000000000007dddd1111d1dd1d1111ddd170000000000000000
00000000000000007700700077707770777000000000000077700700777000000000000000000000000000007dddd1dd1d1dd1dd11dddd170000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070ddd1111d1111dd11ddd1170000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777ddddd777777ddddd77700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000077077707770770000000000000000007770777000000000000000000000000000000000000ddddddddddddddddd11000000000000000000
000000000000000070007070070070700700000000000700770000700000000000000000000000000000000000ddd111dd1dd1d1dd1dd1100000000000000000
00000000000000007000777007007070000000000000777007707770000000000000000000000000000000000dddd1d1dd1dd1d1dd1ddd110000000000000000
00000000000000007070707007007070070000000000070077707000000000000000000000000000000000000dddd1111d1dd1d1111ddd110000000000000000
00000000000000007770707077707070000000000000000007007770000000000000000000000000000000000dddd1dd1d1dd1dd11dddd110000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddd1111d1111dd11ddd1100000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddddddddddd11000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000707077707700000000000000000000007700000000000000000000000000000000000000000ddddddddddddddddd11000000000000000000
000000000000000070700700707007000000000000000700070000000000000000000000000000000000000000ddd111dd1dd1d1dd1dd1100000000000000000
00000000000000007070070070700000000000000000777007000000000000000000000000000000000000000dddd1d1dd1dd1d1dd1ddd110000000000000000
00000000000000007770070070700700000000000000070007000000000000000000000000000000000000000dddd1111d1dd1d1111ddd110000000000000000
00000000000000007770777070700000000000000000000077700000000000000000000000000000000000000dddd1dd1d1dd1dd11dddd110000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddd1111d1111dd11ddd1100000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddddddddddd11000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000777007707770777070000000077077707770777077000000000077700000707000000000bbb0bbb000000000000000000000000000000000
0000000000000000070070700700707070000000700070707000700070700700000070700000707000000000bb00b00000000000000000000000000000000000
00000000000000000700707007007770700000007770777077007700707000000000707000007770000000000bb0bbb000000000000000000000000000000000
0000000000000000070070700700707070000000007070007000700070700700000070700000007000000000bbb000b000000000000000000000000000000000
00000000000000000700770007007070777000007700700077707770777000000000777007000070000000000b00bbb000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007770077077707770700000000770777077707700000000000000777077000000000000000000000000000000000000000000000000000000
00000000000000000700707007007070700000007000707007007070070000000000770007000000000000000000000000000000000000000000000000000000
00000000000000000700707007007770700000007000777007007070000000000000077007000000000000000000000000000000000000000000000000000000
00000000000000000700707007007070700000007070707007007070070000000000777007000000000000000000000000000000000000000000000000000000
00000000000000000700770007007070777000007770707077707070000000000000070077700000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007770077077707770700000007070777077000770000000000000777000000000000000000000000000000000000000000000000000000000
00000000000000000700707007007070700000007070070070707000070000000000707000000000000000000000000000000000000000000000000000000000
00000000000000000700707007007770700000007070070070707770000000000000707000000000000000000000000000000000000000000000000000000000
00000000000000000700707007007070700000007770070070700070070000000000707000000000000000000000000000000000000000000000000000000000
00000000000000000700770007007070777000007770777070707700000000000000777000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010001000000d00000f0000000000000b000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000b0e0000000f00000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000b0000001b000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000e000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000400000000000000000000000000c00000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000500000000000000b00000000000000000e00000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000600000000000000000000f001b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000101010101010101010101010000000c00000000000e0000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000001b000000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000e0000000000000c0000000e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000b000000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000d00000000000f0000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000e0000000000000c000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000d00000c00000b00000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001905019050140501c0501d05021050200501a0500f0502970029700287002770025700216002370021700267000900029700000000000000000000000000000000000000000000000000000000000000
491001000d25001200092000020003250002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000273502735027350273502c3002e3002b3502c3502e3202c3002e300263002735027350223001b300263502635026350263500000000000293502b3502935029350000000000000000000000000000000
00010000187501675015750157501375011750117501075010750107500f7500a7500b7000b700007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000019550195501955019550195501955023050230502605027050280502a0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001d1501d1501e1501e1501f150251502115022150241502615028150291502b1502b1502b1502b1503770034700347003570035700357003870035600387003060037700367002d700000000000000000
000200001f350223502435023350213501d3501835015350143501435016350193501d35022350243502535025350160001c300183001630016300173001a3001e30025300253002530000300000000000000000
000700000060000600006000060000600006000060000600006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41024344

