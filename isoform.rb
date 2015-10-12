require "mongoid"
require "uuid"
require_relative "helper"

Mongoid.load!("./mongoid.yml", :development)
Mongoid.logger.level = 5

class Isoform
	
	include Mongoid::Document

	MRNA = "MRNA"
	CDS = "CDS"	

	field :type
	field :start_position
	field :end_position

	field :starts
	field :ends

	field :gene_id, type: String
	field :exons_count
	field :error

	field :exons
	field :introns

	field :complement

	def self.parse(data,gene_id)
		positions = nil
		exons_count = 0
		type = nil
		data.each_with_index do |line,index|
			if index.zero?
				type = line.strip.start_with?(CDS) ? CDS : MRNA
				positions = Helper.get_positions(data,index)
				positions.delete("complement")
				exons_count = positions["starts"].count
				break
			end
			stripped_line = line.strip
		end
		return {"gene_id"=>gene_id, "exons_count" => exons_count,"type"=>type}.merge(positions)
	end

	def self.create_introns_and_exons(isoform)
		start_index = 
	end


	def self.prepare_data(data)
		return data
	end

end