class Helper

	def self.get_positions(data,index)
		positions_line = " "
		parsing_error_counter = 0
		error = ""
		start_positions = []
		end_positions = []
		while true do
			positions_line += data[index].strip
			break unless positions_line.strip.end_with?(",")
			index += 1
			parsing_error_counter += 1
			error="parsing position" && break if parsing_error_counter > 10
		end 

		position_data = positions_line.split(" ")[1]
		complement = position_data.start_with?("complement")
		position_data = position_data.gsub("complement(","").gsub(")","").gsub("<","").gsub(">","").gsub("(","")
		position_data.sub!("join","")
		position_data.split(",").each do |position_duplex|
			start_positions << position_duplex.split("..").first.to_i
			end_positions << position_duplex.split("..").last.to_i
		end
		return {"complement"=>complement, "starts"=> start_positions, "ends"=> end_positions,
				"start_position" => start_positions.first, "end_position" => end_positions.last, "error"=>error}
	end

end