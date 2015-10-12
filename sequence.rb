require "mongoid"
require "uuid"
Mongoid.load!("./mongoid.yml", :development)


class Sequence
	
	include Mongoid::Document

	field :ref_seq_id, type: String
	field :length, type: Integer
	field :genes_ids, type: Array, default: []

	def self.parse_locus(line)
		locus_data = line.split(" ")
		return { "ref_seq_id" => locus_data[1], "length" => locus_data[2].to_i}
	end

	def self.prepare_data(data,genes_ids)
		return data.merge({"genes_ids" => genes_ids})
	end

end
