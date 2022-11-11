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
