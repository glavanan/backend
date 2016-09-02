require "json"
require "date"
	def get_days(data)
		start = Date.strptime(data["start_date"])
		ends = Date.strptime(data["end_date"])
		days = ((ends - start).to_i) + 1
		return days
	end

	def get_cars(id, data)
		i = 0
		while data["cars"][i] do
			if data["cars"][i]["id"] == id
				return data["cars"][i]
			end
		i = i + 1
		end
		return nil
	end

	def get_price(days, p_per_day, distance, p_per_km)
		p_day = 0
		while days > 0 do
			reduc = 1.0
			if days > 1
				reduc = 0.90
				if days > 4
					reduc = 0.70
				end
				if days > 10
					reduc = 0.50
				end
			end
		p_day = p_day + (p_per_day * reduc)
		days = days - 1
		end
		return ((p_day + distance * p_per_km)).to_i
	end

	def get_comission(price, days)
		com = price * 0.30
		insu = com / 2
		com = com / 2
		assi = days * 100
		drivy = com - days * 100
		obj_com = {"insurance_fee" => insu.to_i, "assistance_fee" => assi.to_i, "drivy_fee" => drivy.to_i}
		return obj_com
	end

	def get_actions(who, type, amount)
		return {"who" => who,"type" => type, "amount" => amount}
	end

	def get_json_obj(data)
		i = 0
		json_obj = {"rentals" => []}
		json_obj.to_json
		while data["rentals"][i] do
			days = get_days(data["rentals"][i])
			car = get_cars(data["rentals"][i]["car_id"], data)
			price = get_price(days, car["price_per_day"], data["rentals"][i]["distance"], car["price_per_km"])
			if (data["rentals"][i]["deductible_reduction"])
				deduc = days * 400
			else
				deduc = 0
			end
			commission = get_comission(price, days)
			obj = {"id" => data["rentals"][i]["id"], "actions" => []}
			obj["actions"] << get_actions("driver", "debit", price + deduc)
			obj["actions"] << get_actions("owner", "credit", price - (price * 0.30).to_i)
			obj["actions"] << get_actions("inssurance", "credit", commission["insurance_fee"])
			obj["actions"] << get_actions("assistance", "credit", commission["assistance_fee"])
			obj["actions"] << get_actions("drivy", "credit", commission["drivy_fee"] + deduc)
			json_obj["rentals"] << obj
			i = i + 1
		end
		return json_obj
	end

	def change_line(data, rent)
		i = 0
		while data["rentals"][i]["id"] != rent["rental_id"] do
			i = i + 1
		end
		if rent["start_date"]
			data["rentals"][i]["start_date"] = rent["start_date"]
		end
		if rent["end_date"]
			data["rentals"][i]["end_date"] = rent["end_date"]
		end
		if rent["distance"]
			data["rentals"][i]["distance"] = rent["distance"]
		end
		return data
	end

	def change_data(data)
		i = 0;
		while data["rental_modifications"][i] do
			data = change_line(data, data["rental_modifications"][i])
			i = i + 1
		end
		return data
	end

	def create_rent_dif(base, modif)
		i = 0
		rentals = {"rentals_modifications" => []}
		id = 1
		while base["rentals"][i] do
			actions = {"actions" => [], "rental_id" => i + 1, "id" => id}
			j = 0
			while base["rentals"][i]["actions"][j] do
				dif = base["rentals"][i]["actions"][j]["amount"] - modif["rentals"][i]["actions"][j]["amount"]
				if dif != 0
					if dif > 0 and base["rentals"][i]["actions"][j]["type"] == "debit"
						actions["actions"] << {"who" => base["rentals"][i]["actions"][j]["who"], "type" => "credit", "amount" => dif}
					end
					if dif < 0 and base["rentals"][i]["actions"][j]["type"] == "debit"
						actions["actions"] << {"who" => base["rentals"][i]["actions"][j]["who"], "type" => "debit", "amount" => dif * -1}
					end
					if dif > 0 and base["rentals"][i]["actions"][j]["type"] == "credit"
						actions["actions"] << {"who" => base["rentals"][i]["actions"][j]["who"], "type" => "debit", "amount" => dif}
					end
					if dif < 0 and base["rentals"][i]["actions"][j]["type"] == "credit"
						actions["actions"] << {"who" => base["rentals"][i]["actions"][j]["who"], "type" => "credit", "amount" => dif * -1}
					end
				end
				j = j + 1
			end
			i = i+ 1
			if actions["actions"].length > 0
			rentals["rentals_modifications"] << actions
			id = id + 1
			end
		end
		return rentals
	end

	file = File.read(ARGV[0])
	data = JSON.parse(file)
	json_obj = get_json_obj(data)
	if data["rental_modifications"].length > 0
		data = change_data(data)
	end
	json_obj2 = get_json_obj(data)

	rental_modi = create_rent_dif(json_obj, json_obj2)
	File.open("output2.json", 'w') do |file|
		file.puts JSON.pretty_generate(rental_modi)
	end
# your code

