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

	file = File.read(ARGV[0])
	data = JSON.parse(file)
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
		obj = {"id" => data["rentals"][i]["id"], "price" => price,"deductible_reduction" => deduc, "commission" => commission}
		json_obj["rentals"] << obj
		i = i + 1
	end
	File.open("output2.json", 'w') do |file|
		file.puts JSON.pretty_generate(json_obj)
	end
# your code

