require "mongoid"
Mongoid.load!("./mongoid.yml", :development)

class Intron

	include Mongoid::Document
	
	field :isoform_id, type: String
	field :prev_exon, type: String
	field :next_exon, type: String
	field :start, type: Integer
	field :end, type: Integer
	field :index, type: Integer
	field :rev_index, type: Integer
	field :phase, type: Integer
	field :length_phase, type: Integer

end