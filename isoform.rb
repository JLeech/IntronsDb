require "mongoid"
require "uuid"
require_relative "helper"
require_relative "exon"
require_relative "intron"

Mongoid.load!("./mongoid.yml", :development)
Mongoid.logger.level = 5

class Isoform
	
	include Mongoid::Document

	MRNA = "MRNA"
	CDS = "CDS"
	ONEEXON = "ONEEXON"
	START_TYPE  = "START"
	END_TYPE = "END"
	INNER_TYPE = "INNER_TYPE"

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
		exons = []
		introns = []
		current_exon = {}
		current_intron = {}

		uid_generator = UUID.new

		starts = isoform["starts"]
		ends = isoform["ends"]
		# puts "\n"*3
		# puts "ST: #{starts}"
		# puts "EN: #{ends}"
		# puts "id: #{isoform['_id']}"
		# puts "id: #{isoform['id']}"
		# puts "\n"*3
		complement = isoform["complement"]

		start_index = complement ? (starts.count - 1) : 0
		end_index = isoform["complement"] ? -1 : starts.count
		increment = isoform["complement"] ? -1 : 1

		phase = 0
		
		(start_index..(end_index-1)).each do |exon_index|
			start_place = starts[exon_index]
			end_place = ends[exon_index]
			current_exon = {"_id" => uid_generator.generate,
											"start" => start_place, "end" => end_place,
											"isoform_id" => isoform["_id"], "start_phase" => phase}
			phase = (phase + end_place - start_place + 1)%3
			current_exon["end_phase"] = phase
			exons << current_exon
		end

		if exons.count == 1
			exon = exons.first
			exon["index"] = 0
			exon["rev_index"] = 0
			exon["type"] = ONEEXON
			Exon.collection.insert_one(exon)
		else
			exons.each_with_index do |exon,index|
				next if index.zero?
				current_intron["_id"] = uid_generator.generate
				current_intron["isoform_id"] = isoform["_id"]
				current_intron["prev_exon"] = exons[index-1]["_id"]
				current_intron["next_exon"] = exon["_id"]
				current_intron["start"] = complement ? (exon["end"] + 1) : (exons[index-1]["end"] + 1)
				current_intron["end"] = complement ? (exons[index-1]["start"] - 1) : (exon["start"] - 1)
				current_intron["index"] = index -1
				current_intron["rev_index"] = isoform["exons_count"] - index - 2
				current_intron["phase"] = exons[index-1]["end_phase"]
				current_intron["length_phase"] = exon["end_phase"]
				introns << current_intron
				exons[index-1]["next_intron"] = current_intron["_id"]
				exon["prev_exon"] = current_intron["_id"]
			end
			exons.first["type"] = START_TYPE
			exons.last["type"] = END_TYPE
			Exon.collection.insert_many(exons)
			puts
			puts "INTRO: #{introns}"
			puts
			Intron.collection.insert_many(introns)
		end
	end


	def self.prepare_data(data)
		return data
	end

end