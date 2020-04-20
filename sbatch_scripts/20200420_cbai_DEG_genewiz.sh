comparisons=(infected-uninfected D9-D12 D9-D26 D12-D26 ambient-cold ambient-warm cold-warm)

for comparison in ${!comparisons[@]}
do
  comparison=${comparisons[${comparison}]}
  mkdir ${comparison}
  cd ${comparison} || exit
  if [[ "${comparison}" == "infected-uninfected" ]]; then
    rsync --archive --verbose ${transcripts_dir}*.fq .
  fi

  if [[ "${comparison}" == "D9-D12" ]]; then
    #statements
  fi

  if [[ "${comparison}" == "D9-D26" ]]; then
    #statements
  fi

  if [[ "${comparison}" == "D12-D26" ]]; then
    #statements
  fi

  if [[ "${comparison}" == "ambient-cold" ]]; then
    #statements
  fi

  if [[ "${comparison}" == "ambient-warm" ]]; then
    #statements
  fi

  if [[ "${comparison}" == "cold-warm" ]]; then
    #statements
  fi

done
