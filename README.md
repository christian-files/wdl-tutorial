# wdl-tutorial
A quick intro on how to use WDL

## Dependencies:
- The latest version of [cromwell and womtool](https://github.com/broadinstitute/cromwell/releases)
- Java

## WDL Basics:
There are 5 basic components that form the core structure of a WDL script: 
- **workflow** - is a required top-level component of a WDL script. It contains call statements that invoke task components, as well as workflow-level input definitions
- **task** - contains all the information necessary to "do something" centering around a `command` accompanied by definitions of input files and parameters, as well as the explicit identification of its output(s) in the `output` component. It can also be given additional (optional) properties using the `runtime`, `meta` and `parameter_meta` components 
- **call** - is used within the workflow body to specify that a particular task should be executed. In its simplest form, a call just needs a task name 
- **command** - is a required property of a task. The body of the command block specifies the literal command line to run (basically any command that you could otherwise run in a terminal shell) 
- **output** - is used to explicitly identify the output(s) of the task command for the purpose of flow control. The outputs identified here will be used to build the workflow graph, so it is important to include all outputs that are used as inputs to other tasks in the workflow


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



