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

	file = File.read(ARGV[0])
	data = JSON.parse(file)
	i = 0
	json_obj = {"rentals" => []}
	json_obj.to_json
	while data["rentals"][i] do
		days = get_days(data["rentals"][i])
		car = get_cars(data["rentals"][i]["car_id"], data)
		price = get_price(days, car["price_per_day"], data["rentals"][i]["distance"], car["price_per_km"])
		obj = {"id" => data["rentals"][i]["id"], "price" => price}
		json_obj["rentals"] << obj
		i = i + 1
	end
	File.open("output2.json", 'w') do |file|
		file.puts JSON.pretty_generate(json_obj)
	end
# your code

