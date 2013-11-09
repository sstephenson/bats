@test "set_run_vars sets variables from run" {
  odd_characters="'(')'"'!@#$$%^&*~`{}[]:;"<>,./\'
  normal_var=1
  
  change_vars() {
    normal_var=3
    new_var=4
    new_array=()
    new_array[0]="  item  with  spaces  "
    new_array[3]="item after gap"
    new_array[4]="$odd_characters"
  }
  
  run change_vars

  [ "$normal_var" -eq 1 ]
  set_run_vars normal_var
  [ "$normal_var" -eq 3 ]

  [ -z "$new_var" ]
  set_run_vars new_var
  [ "$new_var" -eq 4 ]

  [ -z "$new_array" ]
  set_run_vars new_array
  [ "${new_array[0]}" == "  item  with  spaces  " ]
  [ "${new_array[3]}" == "item after gap" ]
  [ "${new_array[4]}" == "$odd_characters" ]
}

@test "set_run_vars handles readonly variables" {
  readonly readonly_var=2
  
  change_vars() {
    :
  }

  run change_vars

  [ "$readonly_var" -eq 2 ]
  set_run_vars readonly_var
  [ "$readonly_var" -eq 2 ]
}

@test "local variables are not available after run" {
  change_vars() {
    local local_var="local"
    global_var=1
  }

  run change_vars

  [ -z "$local_var" ]
  set_run_vars local_var
  [ -z "$local_var" ]

  [ -z "$global_var" ]
  set_run_vars global_var
  [ "$global_var" -eq 1 ]
}

@test "set_run_vars accepts multiple variables" {
   change_vars() {
     var1=1
     var2=2
     var3=3
   }

   run change_vars

   [ -z "$var1" ]
   [ -z "$var2" ]
   [ -z "$var3" ]
   set_run_vars var1 var2 var3
   [ "$var1" -eq 1 ]
   [ "$var2" -eq 2 ]
   [ "$var3" -eq 3 ]
}
