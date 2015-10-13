require "mongoid"
Mongoid.load!("./mongoid.yml", :development)

class Exon

	include Mongoid::Document
	
	field :start, type: Integer
	field :end, type: Integer
	field :isoform_id, type: String
	field :start_phase, type: Integer
	field :end_phase, type: Integer
	field :index, type: Integer
	field :rev_index, type: Integer
	field :type, type: String
	field :prev_intron, type: String
	field :next_intron, type: String

end