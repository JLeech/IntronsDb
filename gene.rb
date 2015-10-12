require "mongoid"
require "uuid"
require_relative "helper"

Mongoid.load!("./mongoid.yml", :development)
Mongoid.logger.level = 5

class Gene

	include Mongoid::Document

	field :start_position, type: Integer
	field :end_position, type: Integer
	field :pseudo, type: Boolean, default: false
	field :name, type: String
	field :starts, type: Array
	field :ends, type: Array
	field :error, type: String
	field :complement, type: Boolean
	field :sequence_id
	field :isoforms_ids


	def self.parse (data,sequence_id)
		name = ""
		pseudo = false
		positions = nil
		data.each_with_index do |line,index|
			if index.zero?
				positions = Helper.get_positions(data,index)
				next
			end
			stripped_line = line.strip
			pseudo = true if stripped_line.start_with?("/pseudo")
			name = get_name(stripped_line) if stripped_line.start_with?("/gene=")
		end
		
		return {"pseudo"=>pseudo,"name"=>name,"sequence_id"=>sequence_id}.merge(positions)
	end

	def self.get_name(line)
		line.sub("/gene=\"","").sub("\"","")
	end

	def self.prepare_data(data,isoforms_ids)
		return data.merge({"isoforms_ids" => isoforms_ids})
	end

end



