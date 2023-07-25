#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.usi_field = "mzspec:GNPS:GNPS-LIBRARY:accession:CCMSLIB00005436077"

TOOL_FOLDER = "$baseDir/bin"

// Boilerplate for GNPS2
params.OMETAPARAM_YAML = "job_parameters.yaml"
params.input_gnps2_parameters = params.OMETAPARAM_YAML

process prepData {
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    file input_parameters

    output:
    file 'usi_to_search.tsv'

    """
    python $TOOL_FOLDER/prep_input.py $input_parameters usi_to_search.tsv
    """
}

// process processData {
//     publishDir "./nf_output", mode: 'copy'

//     conda "$TOOL_FOLDER/conda_env.yml"

//     input:
//     file input 

//     output:
//     file 'output.tsv'

//     """
//     python $TOOL_FOLDER/script.py $input output.tsv
//     """
// }

workflow {
    input_parameters_ch = Channel.fromPath(params.input_gnps2_parameters)
    prepData(input_parameters_ch)
}