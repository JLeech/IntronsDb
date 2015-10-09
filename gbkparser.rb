require_relative "gene"

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
	MEANING_OFFSET = 5

	attr_accessor :file_path, :state, :current_block

	def initialize(file_path = '/home/eve/Документы/bash_task/subseq.gbk')
		@file_path = "/home/eve/Документы/bash_task/hs_ref_GRCh38.p2_chr1.gbk"
		#@file_path = file_path
		@current_block = []
		@state = HEADER
	end

	def parse_file
		File.readlines(@file_path).each do |line|
			stripped_line = line.strip
			if stripped_line.start_with?(GENE)
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
			
			elsif stripped_line.start_with?(LOCUS)
				@state = HEADER
			else
				@current_block << line if block_data?(line) &&  @state != HEADER
			end
		end
	end

	def parse_current_block(new_block_type, line)
		case @state
		when GENE
			gene = Gene.new( Gene.parse(@current_block) ).save
		end		
		@current_block = [line]
		@state = new_block_type
	end

	def block_data?(line)
		line.start_with?(" "*2*(MEANING_OFFSET))
	end

	def start_of_new_gene?(line)
		!line.start_with?(" "*(MEANING_OFFSET+1))
	end

end

gbk = Gbkparser.new
gbk.parse_file