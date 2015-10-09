require "mongoid"

Mongoid.load!("./mongoid.yml", :development)

class Gene

	include Mongoid::Document

	field :start_pos, type: Integer
	field :end_pos, type: Integer
	field :pseudo, type: Boolean, default: false
	field :name, type: String

	def self.parse (data)
		start_pos = 0
		end_pos = 0
		name = ""
		pseudo = false
		data.each_with_index do |line,index|
			if index.zero?
				start_pos, end_pos = get_position(line)
				next
			end
			stripped_line = line.strip
			pseudo = true if stripped_line.start_with?("/pseudo")
			name = get_name(stripped_line) if stripped_line.start_with?("/gene=")
		end
		
		return {"start_pos"=>start_pos,"end_pos"=>end_pos,"pseudo"=>pseudo,"name"=>name}
	end

	def self.get_name(line)
		line.sub("/gene=\"","").sub("\"","")
	end

	def self.get_position(line)
		position = line.split(" ")[1]
		position = position.sub("complement(","").sub(")","").sub("<","")
		return position.split("..").map { |val| val.to_i }
	end

end