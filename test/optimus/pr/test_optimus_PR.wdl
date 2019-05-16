import "Optimus.wdl" as target
import "ValidateOptimus.wdl" as checker


# this workflow will be run by the jenkins script that gets executed by PRs.
workflow TestOptimusPR {

  # output hashes
  String expected_bam_hash
  String expected_matrix_hash
  String expected_gene_metric_hash
  String expected_cell_metric_hash
  Array[String] expected_fastqc_html_hashes
  Int expected_n_fastqc_zips

  # Optimus inputs
  Array[File] r1_fastq
  Array[File] r2_fastq
  Array[File]? i1_fastq

  File whitelist  # 10x genomics cell barcode whitelist for 10x V2
  File tar_star_reference  # star reference
  File annotations_gtf  # gtf containing annotations for gene tagging
  File ref_genome_fasta  # genome fasta file
  String sample_id  # name of sample matching this file, inserted into read group header

  call target.Optimus as target {
    input:
      r1_fastq = r1_fastq,
      r2_fastq = r2_fastq,
      i1_fastq = i1_fastq,
      whitelist = whitelist,
      tar_star_reference = tar_star_reference,
      annotations_gtf = annotations_gtf,
      ref_genome_fasta = ref_genome_fasta,
      sample_id = sample_id
  }

  call checker.ValidateOptimus as checker {
    input:
      bam = target.bam,
      matrix = target.matrix,
      gene_metrics = target.gene_metrics,
      cell_metrics = target.cell_metrics,
      fastqc_htmls = target.fastqc_htmls,
      n_fastqc_zips = length(target.fastqc_zips),
      expected_bam_hash = expected_bam_hash,
      expected_matrix_hash = expected_matrix_hash,
      expected_cell_metric_hash = expected_cell_metric_hash,
      expected_gene_metric_hash = expected_gene_metric_hash,
      expected_fastqc_html_hashes = expected_fastqc_html_hashes,
      expected_n_fastqc_zips = expected_n_fastqc_zips
  }

}
