_boundary_targets() {
  dbs=( "my-db" "my-sql-db" "my-postgres-db")
  local options=()
  for db in "${dbs[@]}"; do
    options+=("${db}-read-only")
    options+=("${db}-read-write")
  done
  options+=("staging" "testing")

  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "${options[*]}" -- "$cur") )
}

#source boundary-autocomplete.sh
#complete -F _boundary_targets ./boundary-connect.sh