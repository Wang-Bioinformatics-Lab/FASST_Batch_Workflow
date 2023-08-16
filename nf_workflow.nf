#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.usi_field = "mzspec:GNPS:GNPS-LIBRARY:accession:CCMSLIB00005436077"

// Search Type
params.entrymode = "file"

params.usi_file = "usi_to_search.tsv"

// Parameters
params.analog = "No"
params.precursor_tolerance = "0.02"
params.fragment_tolerance = "0.02"
params.cosine = "0.7"

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

process searchFASST {
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    file input 

    output:
    file 'output.tsv'

    """
    python $TOOL_FOLDER/masst_client.py $input output.tsv \
    --analog ${params.analog} \
    --precursor_tolerance ${params.precursor_tolerance} \
    --fragment_tolerance ${params.fragment_tolerance} \
    --cosine ${params.cosine}
    """
}

workflow {
    input_parameters_ch = Channel.fromPath(params.input_gnps2_parameters)

    if(params.entrymode == "file"){
        usi_to_search_ch = Channel.fromPath(params.usi_file)
    }
    else{
        usi_to_search_ch = prepData(input_parameters_ch)
    }

    searchFASST(usi_to_search_ch)
}