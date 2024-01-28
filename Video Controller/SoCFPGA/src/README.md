Problème dans le script de synthèse : 

------------------------------------------------
invalid command name "/cal/exterieurs/lasri-22/Desktop/iliass-lasri/controleur_video/ips/interfaces/video_if.sv"
    while executing
"unknown_original /cal/exterieurs/lasri-22/Desktop/iliass-lasri/controleur_video/ips/interfaces/video_if.sv"
    ("eval" body line 1)
    invoked from within
"eval unknown_original $cmd $args"
    (procedure "::unknown" line 7)
    invoked from within
"$PROJECT_DIR/ips/interfaces/video_if.sv"
    (file "./scripts/project_list.tcl" line 5)
    invoked from within
"source ./scripts/project_list.tcl"
    (file "./scripts/create_project.tcl" line 42)
------------------------------------------------
Error (23031): Evaluation of Tcl script ./scripts/create_project.tcl unsuccessful
Error: Quartus Prime Shell was unsuccessful. 1 error, 0 warnings
    Error: Peak virtual memory: 535 megabytes
    Error: Processing ended: Sun Jan 28 13:11:16 2024
    Error: Elapsed time: 00:00:01
    Error: Total CPU time (on all processors): 00:00:01
make: *** [Makefile:46 : .create_project] Erreur 3
