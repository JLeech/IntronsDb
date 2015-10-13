require "uuid"
require_relative "gene"

require_relative "sequence"
require_relative "isoform"


class Gbkparser

	GENE = "gene"
	HEADER = "header"
	MISCRNA = "misc_RNA"
	PRECURSOR_RNA = "precursor_RNA"
	NCRNA = "ncRNA"
	CDS = "CDS"
	EXON = "exon"
	MRNA = "mRNA"
	LOCUS = "LOCUS"
	SEQUENCE_END = "//"
	MEANING_OFFSET = 5

	attr_accessor :file_path, :state, :current_block
	attr_accessor :last_sequance_id, :current_sequence_data
	attr_accessor :current_gene, :current_gene_data, :current_genes_ids
	attr_accessor :current_isoform, :current_isoform_data, :current_isoforms_ids

	attr_accessor :isoform_batch, :gene_batch

	attr_accessor :uid_generator

	def initialize(file_path = '/home/eve/Документы/best-introns-filler/subseq.gbk')
		@file_path = "/home/eve/Документы/bash_task/hs_ref_GRCh38.p2_chr1.gbk"
		#@file_path = file_path
		@current_block = []
		@state = HEADER
		
		@current_sequence_data = {}

		@current_gene_data = {}
		@current_genes_ids = []

		@current_isoform_data = {}
		@current_isoforms_ids = []

		@isoform_batch = []
		@gene_batch = []

		@uid_generator = UUID.new
	end

	def parse_file
		File.readlines(@file_path).each_with_index do |line,index|
			stripped_line = line.strip
			if stripped_line.start_with?(SEQUENCE_END)
				finalize_isoform
				finalize_gene
				finalize_sequence
			elsif stripped_line.start_with?(LOCUS)
				@state = LOCUS
				@current_sequence_data = Sequence.parse_locus(stripped_line)
				@current_sequence_id = add_and_return_id(@current_sequence_data)
			elsif stripped_line.start_with?(GENE)
				if start_of_new_gene?(line)
					parse_current_block(GENE,line)
				end
			elsif stripped_line.start_with?(MISCRNA)
				parse_current_block(MISCRNA,line)
			
			elsif stripped_line.start_with?(PRECURSOR_RNA)
				parse_current_block(PRECURSOR_RNA,line)
			
			elsif stripped_line.start_with?(NCRNA)
				parse_current_block(NCRNA,line)
			
			elsif stripped_line.start_with?(CDS)
				parse_current_block(CDS,line)

			elsif stripped_line.start_with?(EXON)
				parse_current_block(EXON,line)
			elsif stripped_line.start_with?(MRNA)
				parse_current_block(MRNA,line)
			else
				@current_block << line if block_data?(line) &&  @state != HEADER
			end
		end
	end

	def parse_current_block(new_block_type, line)
		case @state
		when GENE
			parse_gene
		when CDS
			parse_cds
		when MRNA
			parse_mrna
		end		
		@current_block = [line]
		@state = new_block_type
	end

	def parse_gene
		finalize_isoform unless first_isoform?
		finalize_gene unless first_gene?
		@current_gene_data = Gene.parse(@current_block,@current_sequence_id)
		id = add_and_return_id(@current_gene_data)
		@current_genes_ids << id
	end

	def parse_mrna
		finalize_isoform unless first_isoform?
		@current_isoform_data = Isoform.parse(@current_block,current_gene_id)
		id = add_and_return_id(@current_isoform_data)
		@current_isoforms_ids << id
	end

	def parse_cds
		gene_for_cds = get_gene_for_cds
		isoform_for_cds = get_isoform_for_cds
		@current_cds_data = Isoform.parse(@current_block,current_gene_id)
		id = add_and_return_id(@current_cds_data)
		@current_cds_data = Isoform.create_introns_and_exons(@current_cds_data)
	
	end

	def first_gene?
		@current_genes_ids.empty?
	end

	def first_isoform?
		@current_isoforms_ids.empty?		
	end

	def finalize_isoform
		@current_isoform_data = Isoform.prepare_data(@current_isoform_data)
		@isoform_batch << @current_isoform_data
	end

	def get_gene_for_cds
		@current_gene_data
	end

	def get_isoform_for_cds
		@current_isoform_data
	end

	def finalize_gene
		@current_gene_data = Gene.prepare_data(@current_gene_data,@current_isoforms_ids)
		Isoform.collection.insert_many(@isoform_batch) unless @current_isoforms_ids.empty?

		@current_isoforms_ids = []
		@isoform_batch = []
		@gene_batch << @current_gene_data
		if @gene_batch.count > 900
			Gene.collection.insert_many(@gene_batch)
			@gene_batch = []
		end
	end

	def finalize_sequence	
		@current_sequence_data = Sequence.prepare_data(@current_sequence_data, @current_genes_ids)
		Sequence.collection.insert_one(@current_sequence_data)
		if @current_genes_ids.empty?
			@gene_batch = []
			return 
		end
		Gene.collection.insert_many(@gene_batch)
		@current_genes_ids = []
		@gene_batch = []
	end

	def block_data?(line)
		line.start_with?(" "*2*(MEANING_OFFSET))
	end

	def start_of_new_gene?(line)
		!line.start_with?(" "*(MEANING_OFFSET+1))
	end

	def add_and_return_id(data)
		id = @uid_generator.generate
		data.merge!( "_id" => id)
		id
	end

	def current_gene_id
		@current_genes_ids.last
	end


end


gbk = Gbkparser.new
gbk.parse_file