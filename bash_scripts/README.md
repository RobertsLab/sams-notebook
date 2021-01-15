#### Bash scripts

Files beginning with a date (YYYYMMDD) can be crossed reference with a notebook entry with the same date. Please see the notebook entry on that date for more information.

---

- `append_dbxref_to_gff.sh`: Incomplete. Intended to append database cross-reference info to GFFs.

- `busco_comparison_plotting.sh`: SLURM script (i.e. Mox) to generate comparative plots of BUSCO scores.

- `busco_number_substitution.sh`: Incomplete. Intended to identify and use the Augustus output file number assigned during a run. The number appears to be arbitrary to the user, so is difficult to predict/use for downstream actions. Primarily intended to help when using MAKER for genome (re-)annotation.

- `circos_pgen_karyotype.sh`: Used to generate a karyotype file for use with Circos using the FASTA index file, `Panopea-generosa-v1.0.fa.fai`, as input.

- `code_block_reformatting.sh`: Used to convert leftover `<code></code>` tags when converting old Wordpress notebook site to markdown.

- `eagle_files_gt_100MB.sh`: Used to identify all files on Eagle (Roberts Lab Synology server) that are >100MB in size. Intended for use as a list of reject files in creating a `wget` mirror of notebooks, but list ends up being too long.

- `fasta_from_gff.sh`: Script to extract FastA sequences from GFF3 (specifically, those produced by MAKER).

- `krona_tax_plots_blast.sh`: Parse list of unique NCBI taxon IDs from a BLAST output file (format: `6 std staxids`) to use as input for generating Krona taxonomy plots.

- `notebook_backups_github.sh`: Incomplete. Intended to create `wget` mirror of Roberts Lab GitHub notebooks. Abandoned due to inability to avoid downloading files >100MB (reject list too long).

- `owl_files_gt_100MB.sh`: Used to identify all files on Owl (Roberts Lab Synology server) that are >100MB in size. Intended for use as a list of reject files in creating a `wget` mirror of notebooks, but list ends up being too long.

- `trinity_deg_to_go.sh`: Script to "flatten" Trinity edgeR GOseq enrichment format so each line contains a single gene/transcript ID and associated GO term.

- `uniprot2go.sh`: Batch retrieval of Gene Ontology terms from uniprot.org using a newline-delimited list of UniProt accessions.
