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

	file = File.read(ARGV[0])
	data = JSON.parse(file)
	puts data
	i = 0
	json_obj = {"rentals" => []}
	json_obj.to_json
	while data["rentals"][i] do
		days = get_days(data["rentals"][i])
		car = get_cars(data["rentals"][i]["car_id"], data)
		price = days * car["price_per_day"] + data["rentals"][i]["distance"] * car["price_per_km"]
		obj = {"id" => data["rentals"][i]["id"], "price" => price}
		json_obj["rentals"] << obj
		puts json_obj
		i = i + 1
	end
	File.open("output2.json", 'w') do |file|
		file.puts JSON.pretty_generate(json_obj)
	end
# your code

