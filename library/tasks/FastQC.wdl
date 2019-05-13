version 1.0

workflow testFastQC {
    input {
        Array[File] fastqs
    }

    call FastQC {
        input:
            fastq_files = fastqs
    }

}

task FastQC {
    input {
        Array[File] fastq_files
        String docker = "quay.io/biocontainers/fastqc:0.11.8--1"
        Int machine_mem_mb = 3850
        Int disk = ceil(size(fastq_files, "Gi") * 2.2)
        Int preemptible = 3
    }

    parameter_meta {
        fastq_files : "input fastq files"
        docker : "(optional) the docker image containing the runtime environment for this task"
        disk: "(optional) the amount of disk space (GiB) to provision for this task"
        preemptible: "(optional) if non-zero, request a pre-emptible instance and allow for this number of preemptions before running the task on a non preemptible machine"
        machine_mem_mb: "(optional) the amount of memory (MiB) to provision for this task"
    }

    command <<<
        set -e

        mkdir outputs
        fastqc ~{sep=' ' fastq_files} -o outputs
    >>>

    runtime {
        docker: docker
        memory: "${machine_mem_mb} MiB"
        disks: "local-disk ${disk} HDD"
        preemptible: preemptible
    }

    output {
        Array[File] fastqc_htmls = glob("outputs/*.html")
        Array[File] fastqc_zips = glob("outputs/*.zip")
    }
}