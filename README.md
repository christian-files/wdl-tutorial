# wdl-tutorial
A quick intro on how to use WDL

## Dependencies:
- The latest version of [cromwell and womtool](https://github.com/broadinstitute/cromwell/releases)
- Java
- Docker

## WDL Basics:
There are 5 basic components that form the core structure of a WDL script: 
- **workflow** - is a required top-level component of a WDL script. It contains call statements that invoke task components, as well as workflow-level input definitions
- **task** - contains all the information necessary to "do something" centering around a `command` accompanied by definitions of input files and parameters, as well as the explicit identification of its output(s) in the `output` component. It can also be given additional (optional) properties using the `runtime`, `meta` and `parameter_meta` components 
- **call** - is used within the workflow body to specify that a particular task should be executed. In its simplest form, a call just needs a task name 
- **command** - is a required property of a task. The body of the command block specifies the literal command line to run (basically any command that you could otherwise run in a terminal shell) 
- **output** - is used to explicitly identify the output(s) of the task command for the purpose of flow control. The outputs identified here will be used to build the workflow graph, so it is important to include all outputs that are used as inputs to other tasks in the workflow

## Further Documentation:
- [cromwell](https://cromwell.readthedocs.io/en/stable/)
- [wdl](https://github.com/openwdl/wdl/blob/main/versions/1.0/SPEC.md)

# Running a Basic Script
`hello_file.wdl` - copy and paste below script into your local machine and then run the following: `java -jar cromwell-XY.jar run hello_file.wdl` (XY being the version number).
```
version 1.0

workflow HelloWorld {
    input {
        String phrase = "Hello, World!"
        Int mem_gb = 5
    }

    call task_1 { 
      input: 
        phrase = phrase, 
        mem_gb = mem_gb 
    }
}


task task_1 {
    input {
      String phrase
      Int mem_gb
    }
    command {
        echo ${phrase} ${mem_gb}
    }
    output {
        File result = stdout()
    }
    runtime {
        docker: "ubuntu:latest"    
        memory: mem_gb + "GB"
    }
}
```

A directory named `cromwell-executions` will be created. In this directory you can find the script that run, stdout, stderr, inputs, and outputs.
You should see an output of the following in a similar directory structure `cromwell-executions/HelloWorld/0daeee3a-3e7c-4911-982c-b5743689ab4e/call-task_1/execution/stdout`:

`Hello, World! 5`


# Advanced WDL
In this section, we will create a workflow and tasks that utilise an `inputs.json`.
You do not have to run this part. This section is purely for reference.

## Step 1. Workflow:
Let's begin with the workflow skeleton. We will call our workflow `BWA` that calls two tasks: `align` and `sort`:
`main.wdl`
```
version 1.0

workflow BWA {
    call align { input: }
    call sort { input: }
}
```

Next, we want to link the tasks together. We can do this by taking the output from `align` and channeling that into `sort`:
`main.wdl`
```
version 1.0

workflow BWA {
    call align { input: }
    call sort { 
        input: 
            infile = align.out
    }
}
```

Now, let's add the inputs for our first task, as well as a few variables each task is going to need:
`main.wdl`
```
version 1.0

workflow BWA {
	input {
	    String sample_name
	    File r1fastq
	    File r2fastq
	    File ref_fasta
	    File ref_fasta_amb
	    File ref_fasta_sa
	    File ref_fasta_bwt
	    File ref_fasta_ann
	    File ref_fasta_pac
	}

    call align { 
        input:
            sample_name = sample_name,
            r1fastq = r1fastq,
            r2fastq = r2fastq,
            ref_fasta = ref_fasta,
            ref_fasta_amb = ref_fasta_amb,
            ref_fasta_sa = ref_fasta_sa,
            ref_fasta_bwt = ref_fasta_bwt,
            ref_fasta_ann = ref_fasta_ann,
            ref_fasta_pac = ref_fasta_pac
    }
    call sort { 
        input: 
            infile = align.out,
            sample_name = sample_name
    }
}
```
The workflow is now complete! Now, onto creating the tasks for the workflow to execute.

# Step 2. Tasks:
## 1. align
This task will align the reads, using bwa mem.
Here is the skeleton script for the task:
```
version 1.0

task align {
    Inputs/Variables
    command {...}
    runtime {...}
    output {...}
}
```
This skeleton will be the same for every task that is created using WDL.

Let's fill in the skeleton script:
```
version 1.0

task align {
	input {
		String sample_name
		File r1fastq
		File r2fastq
		File ref_fasta
		File ref_fasta_amb
		File ref_fasta_sa
		File ref_fasta_bwt
		File ref_fasta_ann
		File ref_fasta_pac
		Int threads
	}
	
	command {
		bwa mem -M -t ${threads} ${ref_fasta} ${r1fastq} ${r2fastq} > ${sample_name}.sam
	}

	runtime {
		cpus: threads
		memory: 16GB
	}
	
	output {
		File out = "${sample_name}.sam"
	}
```

## 2. sort
This task will take the output from the first task as an input
Task Skeleton:
```
version 1.0

task sort {
	Inputs/Variables
	command {...}
	runtime {...}
	output {...}
}
```

Add the variables:
```
version 1.0

task sort {
	input {
		String sample_name
		File infile
	}
	...
}
```

Add the command:
```
version 1.0

... 
	command <<<
		java -jar picard.jar \
			SortSam \
			I=${infile} \
			O=${sample_name}.sorted.bam \
			SORT_ORDER=coordinate \
			CREATE_INDEX=true
	>>>
...
}
```

Adding outputs:
```
version 1.0

...
	output {
		 File outbam = "${sample_name}.sorted.bam"
		 File outbamidx = "${sample_name}.sorted.bai"
	}
....
```

The complete task should look like:
```
version 1.0

task sort {
	input {
		String sample_name
		File infile
	}
	
	command <<<
		java -jar picard.jar \
			SortSam \
			I=${infile} \
			O=${sample_name}.sorted.bam \
			SORT_ORDER=coordinate \
			CREATE_INDEX=true
	>>>
	
	output {
		 File outbam = "${sample_name}.sorted.bam"
		 File outbamidx = "${sample_name}.sorted.bai"
	}
}
```

The complete script can be found in the root folder of this repo.


# Validate
Once the WDL pipeline has been created you can lint the code using womtool:
`java -jar womtool-XY.jar validate main.wdl`
This will return `Success!` if there are no syntax errors. The alternative is womtool returning an error message, suggesting that your syntax is not correct.

# Specify Inputs
The pipeline has been written and validated, it is now time to create an `inputs.json` that will populate the inputs and variables. Again, this is created using womtool:
`java -jar womtool-XY.jar inputs main.wdl > inputs.wdl`

You will be given a template of what the `inputs.json` should look like and the types of data that needs to go into each input.
Your output will look like something below:
```
{
  "BWA.ref_fasta_sa": "File",
  "BWA.r1fastq": "File",
  "BWA.sample_name": "String",
  "BWA.ref_fasta_amb": "File",
  "BWA.align.threads": "Int",
  "BWA.ref_fasta_ann": "File",
  "BWA.ref_fasta": "File",
  "BWA.ref_fasta_pac": "File",
  "BWA.r2fastq": "File",
  "BWA.ref_fasta_bwt": "File"
}
```

# Execute
The final thing to do is to execute and run your script:
`java -jar cromwell-XY.jar run main.wdl`
